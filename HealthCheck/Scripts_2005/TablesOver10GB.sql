/********************************************************************
	Filename:	TablesOver10GB.sql					 
	Author:		Omid Afzalalghom							 
	Date:		11/09/15								
	Comments:	Returns a list of tables larger than 10 GB.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT  
	 OBJECT_SCHEMA_NAME(t.object_id) AS 'Schema_Name'
	,t.name AS 'Table_Name'
	,(
		SELECT sum(a.total_pages) / 128 / 1024
		FROM sys.partitions AS p
		INNER JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
		WHERE p.object_id = t.object_id
		) AS 'GB'
FROM sys.tables t
GROUP BY 
	 t.name
	,t.object_id
HAVING (
		SELECT SUM(a.total_pages) / 128 / 1024
		FROM sys.partitions AS p
		INNER JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
		WHERE p.object_id = t.object_id
		) > 10 
ORDER BY 'GB' DESC;