/********************************************************************
	Filename:	UniqueIdentifierClusterKey.sql					 
	Author:		Omid Afzalalghom							 
	Date:		11/09/15								
	Comments:	Returns a list of tables that have a unique 
				identifier as the first column of the clustered index.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(t.schema_id) AS 'Schema_Name'
	,t.name AS 'Table_Name'
	,i.name AS 'Index_Name'
	,c.name AS 'Column_Name'
FROM sys.tables t
INNER JOIN sys.indexes i ON i.object_id = t.object_id
INNER JOIN sys.index_columns ic ON ic.index_id = i.index_id
	AND ic.object_id = i.object_id
INNER JOIN sys.columns c ON c.object_id = t.object_id
	AND c.column_id = ic.column_id
INNER JOIN sys.types ty ON c.system_type_id = ty.system_type_id
WHERE i.index_id = 1
	AND ty.name = 'uniqueidentifier'
	AND ic.key_ordinal = 1
ORDER BY t.name
		,i.name;

	 