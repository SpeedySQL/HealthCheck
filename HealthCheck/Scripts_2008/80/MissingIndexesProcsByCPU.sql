/********************************************************************
	Filename:	MissingIndexesProcsByCPU.sql					 
	Author:		Omid Afzalalghom
				(Adapated from Jonathan Kehayias' script: 
				http://sqlblog.com/blogs/jonathan_kehayias/archive/2009/07/27/digging-into-the-sql-plan-cache-finding-missing-indexes.aspx)										 
	Date:		09/09/15								
	Comments:	Returns missing index information for the 10 
				stored procedures that consume most CPU.				  
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID('tempdb..#highCPU') IS NOT NULL
  DROP TABLE #highCPU;
SELECT TOP 10 
	 total_worker_time / execution_count worker
	,OBJECT_NAME(object_id, database_id) Proc_Name
	,plan_handle
	,query_plan
INTO #highCPU
FROM sys.dm_exec_procedure_stats ps
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
WHERE query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
  /ShowPlanXML/BatchSequence/Batch/Statements//StmtSimple/QueryPlan/MissingIndexes') = 1
	AND query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
  (/ShowPlanXML/BatchSequence/Batch/Statements//StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]', 'float') > 70
	AND DB_NAME(database_id) = $(DB)
ORDER BY total_worker_time / execution_count DESC;
                  
WITH xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') , 
CachedPlans AS (
	SELECT 
	 Proc_Name, 
	 worker/1000 CPU_ms,
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
	FROM #highCPU 
	CROSS APPLY query_plan.nodes('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
	/ShowPlanXML/BatchSequence/Batch/Statements//StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup') AS q(n)
) SELECT DISTINCT 
	 Proc_Name
	,CPU_ms
	,Table_Name
	,Impact
	,LEFT(Equality_Columns,LEN(Equality_Columns)-1) Equality_Columns
	,LEFT(Inequality_Columns,LEN(Inequality_Columns)-1) Inequality_Columns
	,LEFT(Include_Columns,LEN(Include_Columns)-1) Include_Columns
	,'0x' + cast('' as xml).value('xs:hexBinary(sql:column("plan_handle"))', 'varchar(max)') 
		AS 'plan_handle' --required for correct format from export-csv cmdlet.  Otherwise, exported as System.Byte[].plan_handle
FROM CachedPlans
ORDER BY Impact DESC;

DROP TABLE #highcpu;