/********************************************************************
	Filename:	TablesManyIndexes.sql					 
	Author:		Omid Afzalalghom							 
	Date:		11/09/15								
	Comments:	Returns a list of tables with more than five indexes
				and an index count greater than half the column count.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH IndexColCount 
AS (
	SELECT 
		 SCHEMA_NAME(t.schema_id) AS 'Schema_Name'
		,OBJECT_NAME(i.object_id) AS 'Table_Name'
		,COUNT(DISTINCT i.index_id) AS 'Index_Count'
		,(SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = i.object_id) 'Cols_Count'
		,COALESCE((
				SELECT SUM(s.rows)
				FROM sys.partitions s
				WHERE s.object_id = i.object_id
					AND s.index_id < 2
				), 0) 'Rows'
	FROM sys.indexes i
	INNER JOIN sys.tables t ON i.object_id = t.object_id
	WHERE i.index_id >= 1
	GROUP BY 
		 t.object_id
		,t.schema_id
		,i.object_id
	HAVING COUNT(*) >= 5
)
SELECT 
	 [Schema_Name]
	,[Table_Name]
	,[Index_Count]
	,[Cols_Count]
FROM IndexColCount
WHERE [Cols_Count]/[Index_Count] < 2
ORDER BY [Index_Count] DESC
		,[Cols_Count];

		 
	