/********************************************************************
	Filename:	ColumnTypesVarchar255.sql					 
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Finds tables that have more than one column 
				defined as varchar(255).	
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		
SELECT 
	 OBJECT_SCHEMA_NAME(object_id) AS 'Schema_Name'
	,OBJECT_NAME(object_id) 'Table_Name'
	,COUNT(*) Num_Cols
FROM sys.columns
WHERE OBJECTPROPERTY(object_id, 'IsUserTable') = 1
GROUP BY object_id
HAVING SUM(system_type_id) % 167 = 0
	AND SUM(max_length) % 255 = 0
	AND COUNT(*) > 1
ORDER BY 'Schema_Name', 'Table_Name';

	 