/********************************************************************
	Filename:	ForeignKeysUntrusted.sql					 
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Returns untrusted foreign keys.  These constraints
				will not be considered by the query optimizer.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 SCHEMA_NAME(SCHEMA_ID) 'Schema_Name'
	,OBJECT_NAME(parent_object_id) 'Table_Name'
	,name AS 'FK_Name'
FROM sys.foreign_keys
WHERE is_not_trusted = 1
ORDER BY 'Schema_Name', 'Table_Name', 'FK_Name';