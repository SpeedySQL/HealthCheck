/**********************************************************************
	Filename:	MemoryClerks.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		10/09/15								
	Comments:	Returns top 10 memory clerks and total memory usage.
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH mem
AS (
	SELECT [type] = COALESCE([type], 'Total')
		,SUM(virtual_memory_committed_kb + shared_memory_committed_kb + awe_allocated_kb) / 1024 Virt_MB
		,SUM(single_pages_kb + multi_pages_kb) / 1024 Pages_MB
		,(SUM(virtual_memory_committed_kb + shared_memory_committed_kb + awe_allocated_kb + single_pages_kb + multi_pages_kb)) / 1024 Total_MB
	FROM sys.dm_os_memory_clerks
	GROUP BY GROUPING SETS(([type]), ())
	)
SELECT TOP 11 
	 [type]
	,Virt_MB
	,Pages_MB
	,Total_MB
	,CAST((
		SELECT Total_MB / (
							SELECT Total_MB * 1.
							FROM mem
							WHERE [type] = 'total'
							) * 100
		FROM mem a
		WHERE a.[type] = mem.[type]
		) AS DECIMAL(5,2)) [%]
FROM mem
ORDER BY Total_MB DESC;