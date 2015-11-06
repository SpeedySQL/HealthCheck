/********************************************************************
	Filename:	sp_xml_removedocument.sql					 
	Author:		Omid Afzalalghom (Adapted from Paul Randal's script:
				http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/							 
	Date:		11/09/15								
	Comments:	Returns a list of objects that prepare XML 
				documents but do not remove them.
	Revisions:											 
********************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT 
	 SCHEMA_NAME(o.schema_id) AS 'Schema_Name'
	,OBJECT_NAME(o.OBJECT_ID) AS 'Object_Name'
	,o.type_desc AS 'Object_Type'
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE   m.definition LIKE '%sp_xml_preparedocument%' 
	AND m.definition NOT LIKE '%sp_xml_removedocument%'; 							 
	 