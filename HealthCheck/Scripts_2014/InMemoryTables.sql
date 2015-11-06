/**********************************************************************
	Filename:	InMemoryTables.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		08/10/15								
	Comments:	Returns list of in-memory tables and memory used. 					 
	Revisions:	
**********************************************************************/

 SELECT 
	 t.name AS Table_Name
	,ISNULL((CONVERT(DECIMAL(8,2),(x.memory_used_by_table_kb)/1024.00)), 0.00) AS Table_Used_Memory_In_MB
	,ISNULL((CONVERT(DECIMAL(8,2),(x.memory_allocated_for_table_kb - x.memory_used_by_table_kb)/1024.00)), 0.00) AS Table_Unused_Memory_In_MB
	,ISNULL((CONVERT(DECIMAL(8,2),(x.memory_used_by_indexes_kb)/1024.00)), 0.00) AS Index_Used_Memory_In_MB
	,ISNULL((CONVERT(DECIMAL(8,2),(x.memory_allocated_for_indexes_kb - x.memory_used_by_indexes_kb)/1024.00)), 0.00) AS Index_Unused_Memory_In_MB
	,t.Durability_Desc
	,t.Create_Date
FROM sys.tables t 
JOIN sys.dm_db_xtp_table_memory_stats x ON (t.object_id = x.object_id)
ORDER BY Table_Used_Memory_In_MB DESC;

 