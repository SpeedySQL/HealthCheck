/********************************************************************
	Filename:	TablesWithMoreIndexesThanColumns.sql					 
	Author:		Omid Afzalalghom							 
	Date:		11/09/15								
	Comments:	Returns a list of tables that have more indexes
				than columns.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH cte 
AS (
	SELECT	
		 SCHEMA_NAME(t.schema_id) 'Schema_Name'
		,OBJECT_NAME(i.object_id) 'Table_Name'
		,COUNT(*) 'Index_Count'
		,(SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = i.object_id) 'Cols_Count'
	FROM sys.indexes i
	INNER JOIN sys.tables t on i.object_id = t.object_id
	WHERE index_id > 0
	GROUP BY t.schema_id, i.object_id
)
SELECT 
	 [Schema_Name]
	,[Table_Name]
	,[Index_Count]
	,[Cols_Count]		
FROM cte 
WHERE Index_Count > Cols_Count;