/********************************************************************
	Filename:	DataTypes_Deprecated.sql					 
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Returns tables with columns that use deprecated types
				text, ntext and image. (n)varchar(max) and 
				varbinary(max) should be used instead.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(o.schema_id) AS 'Schema_Name'
	,OBJECT_NAME(c.object_id) AS 'Table_Name'
	,c.NAME AS 'Column_Name'
	,t.NAME 'Data_Type'
FROM sys.columns c
INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
INNER JOIN sys.objects o ON c.object_id = o.object_id
WHERE  t.NAME IN ('text', 'ntext', 'image')
	AND o.type_desc = 'USER_TABLE'
ORDER BY 'Schema_Name', 'Table_Name';
	