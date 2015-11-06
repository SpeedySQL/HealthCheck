/********************************************************************
	Filename:	MissingIndexesProcsByReads.sql					 
	Author:		Omid Afzalalghom
				(Adapated from Jonathan Kehayias' script: 
				http://sqlblog.com/blogs/jonathan_kehayias/archive/2009/07/27/digging-into-the-sql-plan-cache-finding-missing-indexes.aspx)										 
	Date:		10/09/15								
	Comments:	Returns missing index information for the 10 
				stored procedures that consume most I/O. Filtered
				on missing index impact > 70.				  
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID('tempdb..#highReads') IS NOT NULL
  DROP TABLE #highReads;
SELECT TOP 10 
	(total_logical_reads + total_physical_reads) / execution_count reads
	,OBJECT_NAME(object_id, database_id) Proc_Name
	,plan_handle
	,query_plan
INTO #highReads
FROM sys.dm_exec_procedure_stats ps
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
WHERE query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
  /ShowPlanXML/BatchSequence/Batch/Statements//StmtSimple/QueryPlan/MissingIndexes') = 1
	AND query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
  (/ShowPlanXML/BatchSequence/Batch/Statements//StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]', 'float') > 70
	AND DB_NAME(database_id) = DB_NAME()
ORDER BY (total_logical_reads + total_physical_reads) / execution_count DESC;        
			          
WITH xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') , 
CachedPlans AS (
	SELECT 
	 Proc_Name, 
	 reads avg_reads,
	 n.value('@Impact' ,'decimal(3,0)') AS Impact,
	 n.value('MissingIndex[1]/@Table' ,'varchar(128)') AS [Table_Name],
	(
	 SELECT (SELECT c.value('@Name' ,'varchar(128)') + ', ' 
	 FROM n.nodes('MissingIndex/ColumnGroup[@Usage="EQUALITY"][1]') AS t(cg) 
	 CROSS APPLY cg.nodes('Column') AS r(c) FOR XML PATH(''))
	 )AS 'Equality_Columns',
	 
	 (
	  SELECT (SELECT c.value('@Name' ,'varchar(128)') + ', ' 
	  FROM n.nodes('MissingIndex/ColumnGroup[@Usage="INEQUALITY"][1]') AS t(cg)
	  CROSS APPLY cg.nodes('Column') AS r(c) FOR XML PATH(''))
	 ) AS 'Inequality_Columns',
	 (
	  SELECT (SELECT c.value('@Name' ,'varchar(128)') + ', ' 
	  FROM n.nodes('MissingIndex/ColumnGroup[@Usage="INCLUDE"][1]') AS t(cg)
	  CROSS APPLY cg.nodes('Column') AS r(c) FOR XML PATH(''))
	 ) AS 'Include_Columns',
	 plan_handle
	FROM #highReads 
	CROSS APPLY query_plan.nodes('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
	/ShowPlanXML/BatchSequence/Batch/Statements//StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup') AS q(n)
) SELECT DISTINCT 
	 Proc_Name
	,avg_reads
	,Table_Name
	,Impact
	,LEFT(Equality_Columns,LEN(Equality_Columns)-1) Equality_Columns
	,LEFT(Inequality_Columns,LEN(Inequality_Columns)-1) Inequality_Columns
	,LEFT(Include_Columns,LEN(Include_Columns)-1) Include_Columns
	,'0x' + cast('' as xml).value('xs:hexBinary(sql:column("plan_handle"))', 'varchar(max)') 
		AS 'plan_handle' --required for correct format from export-csv cmdlet.  Otherwise, exported as System.Byte[].plan_handle
FROM CachedPlans
ORDER BY Impact DESC;

DROP TABLE #highReads;