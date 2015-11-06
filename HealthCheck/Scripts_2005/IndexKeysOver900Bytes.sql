/**********************************************************************
	Filename:	IndexKeysOver900Bytes.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		10/09/15								
	Comments:	Returns list of indexes that have a maximum key width
				over 900 bytes which could result in error 1946 during
				an insert or update operation.					 
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(t.schema_id) Schema_Name
	,OBJECT_NAME(t.object_id) Table_Name
	,ix.NAME Index_Name
	,SUM(c.max_length) AS Key_Width_Bytes
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
INNER JOIN sys.index_columns ic ON ic.object_id = t.object_id
	AND c.column_id = ic.column_id
INNER JOIN sys.indexes ix ON ic.index_id = ix.index_id
	AND ic.object_id = ix.object_id
WHERE ic.is_included_column = 0
GROUP BY t.object_id
	,ix.NAME
	,t.schema_id
HAVING SUM(max_length) > 900
ORDER BY SUM(max_length) DESC;

