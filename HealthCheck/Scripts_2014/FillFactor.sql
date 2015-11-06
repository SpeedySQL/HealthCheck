/**********************************************************************
	Filename:	FillFactor.sql					 
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Returns list of indexes with fill factors less than 90.	
	Revisions:											 
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
     OBJECT_SCHEMA_NAME(object_id) 'Schema_Name'
	,OBJECT_NAME(object_id) 'Table_Name'
	,i.NAME 'Index_Name'
	,Coalesce((
			SELECT SUM(s.rows)
			FROM sys.partitions s
			WHERE s.object_id = i.object_id
				AND s.index_id < 2
			), 0) 'Rows'
	,Fill_Factor
FROM sys.indexes i
WHERE object_id >= 100
	AND fill_factor > 0
	AND fill_factor < 90
	AND OBJECT_SCHEMA_NAME(object_id) != 'sys'
ORDER BY Fill_Factor DESC, 'Rows' DESC;