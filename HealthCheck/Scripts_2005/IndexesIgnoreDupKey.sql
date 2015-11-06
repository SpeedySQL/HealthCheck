/**********************************************************************
	Filename:	IndexesIgnoreDupKey.sql					 
	Author:		Omid Afzalalghom							 
	Date:		10/09/15								
	Comments:	Returns list of tables with nonclustered indexes that  
				have the ignore_dup_key option enabled. This option 
				harms performance of inserts and updates as described
				in Craig Freedman's article on MSDN:
				http://blogs.msdn.com/b/craigfr/archive/2008/01/30/maintaining-unique-indexes-with-ignore-dup-key.aspx						 
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 OBJECT_SCHEMA_NAME(object_id) AS 'Schema_Name'
	,OBJECT_NAME(object_id) AS 'Table_Name'
	,name AS 'Index_Name'
FROM sys.indexes
WHERE ignore_dup_key = 1 
		AND type = 2
ORDER BY 'Schema_Name', 'Table_Name', 'Index_Name';
		 
		  