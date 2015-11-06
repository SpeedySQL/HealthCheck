/**********************************************************************
	Filename:	LatchStats.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		10/09/15								
	Comments:	Returns latch wait statistics.
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 latch_class
	,SUM(wait_time_ms) wait_time_ms
	,SUM(max_wait_time_ms) max_wait_time_ms
	,CAST(100. * wait_time_ms / SUM(wait_time_ms) OVER () AS DECIMAL(12, 2)) AS [%]
FROM sys.dm_os_latch_stats
WHERE latch_class NOT IN ('BUFFER')
	AND wait_time_ms > 0
GROUP BY latch_class
		,wait_time_ms
ORDER BY 'wait_time_ms' DESC;