/********************************************************************
	Filename:	CacheHitRatios.sql
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Returns hit ratios for the various SQL cache stores.	
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH hitcount 
     AS (SELECT [instance_name],  [cntr_value] 
         FROM   sys.dm_os_performance_counters s 
         WHERE  [counter_name] = 'Cache Hit Ratio' 
                AND [object_name] LIKE '%:Plan Cache%'), 
     total 
     AS (SELECT [instance_name],  [cntr_value] 
         FROM   sys.dm_os_performance_counters 
         WHERE  [counter_name] = 'Cache Hit Ratio Base' 
                AND [object_name] LIKE '%:Plan Cache%'), 
     pages 
     AS (SELECT [instance_name], [cntr_value] 
         FROM   sys.dm_os_performance_counters 
         WHERE  [object_name] LIKE '%:Plan Cache%' 
                AND [counter_name] = 'Cache Pages')
SELECT 
	RTRIM(hitcount.[instance_name]) AS 'Instance_Name'
    ,CAST((hitcount.[cntr_value] * 1.0 / (1+total.[cntr_value])) * 100.0 AS DECIMAL(5, 2)) AS 'Hit_Ratio %'
    ,( [pages].[cntr_value] * 8 / 1024 ) AS 'Cache_MB' 
FROM   hitcount 
       INNER JOIN total 
               ON hitcount.[instance_name] = [total].[instance_name] 
       INNER JOIN pages 
               ON hitcount.[instance_name] = [pages].[instance_name] 
ORDER  BY 'Hit_Ratio %';  