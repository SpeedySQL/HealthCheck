/**********************************************************************
	Filename:	HeapsWithNCIndex.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		10/09/15								
	Comments:	Returns list of tables that have a non-clustered index
				but do not have a clustered index.
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH cte
AS (
	SELECT 
		 SCHEMA_NAME(t.schema_id) AS [Schema_Name]
		,NAME AS Table_Name
		,COALESCE((
				SELECT SUM(s.rows)
				FROM sys.partitions s
				WHERE s.object_id = t.object_id
					AND s.index_id < 2
				), 0) AS 'Rows'
	FROM sys.tables t
	WHERE OBJECTPROPERTY(object_id, 'TableHasIndex') = 1
		AND OBJECTPROPERTY(object_id, 'TableHasClustIndex') = 0
	)
SELECT *
FROM cte
WHERE [Rows] > 1000
ORDER BY 'Rows' DESC;