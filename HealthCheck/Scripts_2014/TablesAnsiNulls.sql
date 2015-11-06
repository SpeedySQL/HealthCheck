/********************************************************************
	Filename:	TablesAnsiNulls.sql					 
	Author:		Omid Afzalalghom							 
	Date:		11/09/15								
	Comments:	Returns a list of tables created with ANSI NULLs off.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(schema_id) AS 'Schema_Name'
	,name AS 'Table_Name'
FROM sys.tables 
WHERE uses_ansi_nulls = 0
ORDER BY 'Schema_Name', 'Table_Name';
 