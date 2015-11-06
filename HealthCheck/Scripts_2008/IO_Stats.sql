/**********************************************************************
	Filename:	IO_Stats.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		10/09/15								
	Comments:	Returns IO stall statistics for all databases.  					 
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 DB_NAME(database_id) AS [DB_Name]
	,file_id
	,io_stall_read_ms
	,num_of_reads
	,CAST(io_stall_read_ms / (1.0 + num_of_reads) AS NUMERIC(10, 1)) AS [avg_read_stall_ms]
	,io_stall_write_ms
	,num_of_writes
	,CAST(io_stall_write_ms / (1.0 + num_of_writes) AS NUMERIC(10, 1)) AS [avg_write_stall_ms]
	,io_stall_read_ms + io_stall_write_ms AS [io_stalls]
	,num_of_reads + num_of_writes AS [total_io]
	,CAST((io_stall_read_ms + io_stall_write_ms) / (1.0 + num_of_reads + num_of_writes) AS NUMERIC(10, 1)) AS [avg_io_stall_ms]
FROM sys.dm_io_virtual_file_stats(NULL, NULL)
ORDER BY 
	CASE 
		WHEN DB_NAME(database_id) = DB_NAME()
			THEN 0
		ELSE 1
	END
	,(io_stall_read_ms + io_stall_write_ms) / (1.0 + num_of_reads + num_of_writes) DESC;