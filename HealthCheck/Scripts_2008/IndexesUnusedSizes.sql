/**********************************************************************
	Filename:	IndexesUnusedSizes.sql					 
	Author:		Omid Afzalalghom							 
	Date:		10/09/15								
	Comments:	Returns list of tables that have unused indexes. Before
				removing indexes, bear in mind that the index usage 
				stats DMV is cleared upon server restart.					 
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Indexes updated but not read.
SELECT 
	 OBJECT_SCHEMA_NAME(i.object_id)	AS 'Schema_Name'
	,OBJECT_NAME(i.object_id, DB_ID())  AS 'Table_Name'
	,i.name								AS 'Index_Name'
	,SUM(p.rows)						AS 'Rows'
	,(SUM(a.total_pages) * 8) / 1024	AS 'Index_MB'
	,'No user reads'					AS 'Status'
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s ON s.object_id = i.object_id
	AND s.index_id = i.index_id
	AND s.database_id = DB_ID()
INNER JOIN sys.partitions p ON i.object_id = p.object_id
	AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
	AND i.index_id > 0									 --Exclude heaps.
	AND s.user_lookups + s.user_scans + s.user_seeks = 0 --No user reads.
	AND s.user_updates > 0								 --Index being updated.
	AND i.is_primary_key = 0							 --Exclude primary keys.
	AND i.is_unique = 0									 --Exclude unique constraints.
GROUP BY i.object_id
	,i.index_id
	,i.name
HAVING SUM(p.rows) > 0

UNION

--Indexes without usage stats.
SELECT 
	 OBJECT_SCHEMA_NAME(i.object_id)	AS 'Schema_Name'
	,OBJECT_NAME(i.object_id, DB_ID())  AS 'Table_Name'
	,i.name								AS 'Index_Name'
	,SUM(p.rows)						AS 'Rows'
	,(SUM(a.total_pages) * 8) / 1024	AS 'Index_MB'
	,'No usage stats'					AS 'Status'
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s ON s.object_id = i.object_id
	AND s.index_id = i.index_id
	AND s.database_id = DB_ID()
INNER JOIN sys.partitions p ON i.object_id = p.object_id
	AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
	AND i.index_id > 0        --Exclude heaps.
	AND is_primary_key = 0	  --Exclude primary keys.
	AND s.object_id IS NULL
GROUP BY i.object_id
	,i.index_id
	,i.name
HAVING SUM(p.rows) > 0
ORDER BY 'Index_MB' DESC;