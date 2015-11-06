/**********************************************************************
	Filename:	MissingIndexes.sql					 
	Author:		Omid Afzalalghom 					 
	Date:		10/09/15								
	Comments:	Returns missing indexes for current database with 
				estimated impact > 70 and index advantage > 1000.
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH cte
AS (
	SELECT DB_NAME(mid.database_id) 'DATABASE'
		,CAST(avg_user_impact AS DECIMAL(3, 0)) avg_user_impact
		,CAST(index_advantage AS BIGINT) index_advantage
		,mid.STATEMENT AS table_name
		,mid.equality_columns
		,mid.inequality_columns
		,mid.included_columns
	FROM (
		SELECT (user_seeks + user_scans) * avg_total_user_cost * (avg_user_impact * 0.01) AS index_advantage
			,migs.*
		FROM sys.dm_db_missing_index_group_stats migs WITH (NOLOCK)
		) AS migs_adv
		,sys.dm_db_missing_index_groups mig WITH (NOLOCK)
		,sys.dm_db_missing_index_details mid WITH (NOLOCK)
	WHERE DB_NAME(mid.database_id) = DB_NAME()
		AND migs_adv.group_handle = mig.index_group_handle
		AND mig.index_handle = mid.index_handle
	)
SELECT PARSENAME(table_name, 2) AS 'Schema_Name'
	,PARSENAME(table_name, 1)   AS 'Table_Name'
	,avg_user_impact			AS 'Impact'
	,FLOOR(index_advantage)		AS 'Index_Advantage'
	,equality_columns
	,inequality_columns
	,included_columns
FROM cte
WHERE avg_user_impact > 70
	AND index_advantage > 1000
ORDER BY index_advantage DESC;
