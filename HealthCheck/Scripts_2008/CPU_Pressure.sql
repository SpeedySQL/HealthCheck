/********************************************************************
	Filename:	CPU_Pressure.sql					 
	Author:		https://technet.microsoft.com/en-us/magazine/dn383732.aspx   							 
	Date:		09/09/15								
	Comments:	Calculates signal waits and resource waits as a 
				percentage of the overall wait time, in order to 
				diagnose potential CPU pressure.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT '% Signal (CPU) Waits' = CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
       ,'% Resource Waits' = CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
FROM sys.dm_os_wait_stats;
