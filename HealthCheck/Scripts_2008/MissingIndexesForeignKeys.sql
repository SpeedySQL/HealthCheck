/********************************************************************
	Filename:	MissingIndexesForeignKeys.sql					 
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Returns FKs on unindexed columns.  Deletes on the 
				the referenced tables will result in scans on the 
				parent tables. Evaluate whether indexes on the 
				parent tables are required. 
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(f.schema_id) AS 'Schema_Name'
	,OBJECT_NAME(f.parent_object_id) AS 'Parent_Table_Name'
	,COALESCE((
			SELECT SUM(s.rows)
			FROM sys.partitions s
			WHERE s.object_id = f.parent_object_id
				AND s.index_id < 2
			GROUP BY s.object_id
			), 0) AS 'Rows'
	,f.name AS 'FK_Name'
	,c.name AS 'Column_Name'
	,OBJECT_NAME(f.referenced_object_id) AS 'Referenced_Table_Name'
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc ON f.object_id = fc.constraint_object_id
INNER JOIN sys.columns AS c ON 	fc.parent_object_id = c.object_id
							AND fc.parent_column_id = c.column_id
WHERE NOT EXISTS (
					SELECT 1
					FROM sys.indexes AS i
					INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id
					WHERE   f.parent_object_id = i.object_id
						AND i.index_id = ic.index_id
						AND fc.constraint_column_id = ic.key_ordinal
						AND fc.parent_column_id = ic.column_id
						AND i.is_hypothetical = 0
				)
	AND f.is_ms_shipped = 0
ORDER BY 'Rows' DESC;