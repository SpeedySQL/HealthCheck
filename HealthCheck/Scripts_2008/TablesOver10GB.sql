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
	,(
		SELECT  CASE 
					WHEN MAX([data_compression]) = 0 
						THEN 'Uncompressed'
					WHEN MIN([data_compression]) = 0 AND MAX([data_compression]) > 0
						THEN 'Partially Compressed'  
					WHEN MIN([data_compression]) = 1 AND MAX([data_compression]) = 1
					   THEN  'Row Compressed'
					WHEN MIN([data_compression]) = 2 AND MAX([data_compression]) = 2
					   THEN  'Page Compressed'
					WHEN MIN([data_compression]) = 1 AND MAX([data_compression]) = 2
					   THEN  'Row & Page Compressed'
					WHEN MIN([data_compression]) IN (3,4)
						THEN 'ColumnStore Compression'
				END 
		FROM sys.partitions p
		INNER JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
			WHERE p.object_id = t.object_id
		) AS 'Compression'

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