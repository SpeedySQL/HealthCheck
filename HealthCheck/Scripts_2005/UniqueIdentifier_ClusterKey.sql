SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT o.NAME objectName
	,i.NAME indexName
	,c.NAME AS columnName
FROM sys.objects o
INNER JOIN sys.indexes i ON i.object_id = o.object_id
INNER JOIN sys.index_columns ic ON ic.index_id = i.index_id
	AND ic.object_id = i.object_id
INNER JOIN sys.columns c ON c.object_id = o.object_id
	AND c.column_id = ic.column_id
INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
WHERE o.is_ms_shipped = 0
	AND i.type_desc = 'CLUSTERED'
	AND t.NAME = 'uniqueidentifier'
ORDER BY o.NAME
	,i.NAME;

