/**********************************************************************
	Filename:	HypotheticalIndexes.sql					 
	Author:		Omid Afzalalghom							 
	Date:		10/09/15								
	Comments:	Returns list of hypothetical indexes. It is best to 
				ensure these are removed to avoid clutter.  Also, 
				there have been bugs related to these such as the 
				following: http://blogs.msdn.com/b/sqlserverfaq/archive/2009/06/25/exception-when-selecting-from-sysindexes-in-sql-server-2005.aspx
	Revisions:											 
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(t.schema_id) Schema_Name
	,t.Name AS 'Table_Name'
	,i.Name AS 'Index_Name'
FROM sys.indexes i 
INNER JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.is_hypothetical = 1
ORDER BY 'Schema_Name', 'Table_Name', 'Index_Name';