/**********************************************************************
	Filename:	PlanCacheByType.sql					 
	Author:		Omid Afzalalghom (adapted from Kimberly Tripp's script:
				http://www.sqlskills.com/blogs/kimberly/plan-cache-and-optimizing-for-adhoc-workloads/)				 
	Date:		10/09/15								
	Comments:	Returns plan cache size broken down by type.
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH cache 
AS(
	SELECT 
			  objtype  AS Cache_Type
			, COUNT_BIG(*) AS Total_Plans
			, CAST(SUM(CAST(size_in_bytes AS DECIMAL(18,2)))/1024/1024 AS DECIMAL(8,2)) AS Total_MB        
			, AVG(CAST(usecounts AS BIGINT)) AS Avg_Use_Count
			, CAST(SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) AS DECIMAL(18,2)))/1024/1024 AS DECIMAL(8,2)) 
			     AS [Total MBs - USE Count 1]
			, SUM(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
	FROM sys.dm_exec_cached_plans  
	GROUP BY objtype
)
SELECT 
	 Cache_Type
	,Total_Plans
	,Total_MB
	,Avg_Use_Count
	,[Total MBs - USE Count 1]
	,[Total Plans - USE Count 1]
	,CAST(([Total Plans - USE Count 1]*1./Total_Plans)*100 AS DECIMAL(5,2)) AS Single_Use_Pct 
FROM cache
ORDER BY Total_MB DESC;




