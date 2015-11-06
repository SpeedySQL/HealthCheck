/********************************************************************
	Filename:	CursorsWithoutCloseDeallocate.sql					 
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Finds objects with cursors that have not been 
				closed or deallocated.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 o.type_desc AS 'Object_Type'
	,OBJECT_SCHEMA_NAME(m.object_id) 'Schema_Name'
	,OBJECT_NAME(m.object_id) 'Object_Name'
	,'Missing CLOSE CURSOR' AS 'Problem'
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE UPPER(DEFINITION) LIKE '%DECLARE % CURSOR%'
	AND UPPER(DEFINITION) NOT LIKE '%CLOSE %' --Space
	AND UPPER(DEFINITION) NOT LIKE '%CLOSE	%' --Tab

UNION

SELECT 
	 o.type_desc AS 'Object_Type'
	,OBJECT_SCHEMA_NAME(m.object_id) 'Schema_Name'
	,OBJECT_NAME(m.object_id) 'Object_Name'
	,'Missing DEALLOCATE CURSOR' AS 'Problem'  
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE UPPER(DEFINITION) LIKE '%DECLARE % CURSOR%'
	AND UPPER(DEFINITION) NOT LIKE '%DEALLOCATE %' --Space
	AND UPPER(DEFINITION) NOT LIKE '%DEALLOCATE	%' --Tab
ORDER BY 'Object_Type', 'Schema_Name', 'Object_Name'


