/**********************************************************************
	Filename:	HeapsNoIndexes.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		10/09/15								
	Comments:	Returns list of tables that have no indexes.
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(t.schema_id) AS 'Schema_Name'
	,name AS 'Table_Name'
	,COALESCE((
			SELECT SUM(s.rows)
			FROM sys.partitions s
			WHERE s.object_id = t.object_id
				AND s.index_id < 2
			), 0) AS 'Rows'
FROM sys.tables t
WHERE OBJECTPROPERTY(object_id, 'TableHasIndex') = 0
ORDER BY 'Rows' DESC;
 