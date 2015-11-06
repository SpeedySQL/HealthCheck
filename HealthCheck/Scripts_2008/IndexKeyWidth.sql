/**********************************************************************
	Filename:	IndexKeyWidth.sql					 
	Author:		Omid Afzalalghom (Adapted from Paul Randal's script:
	http://www.sqlskills.com/blogs/paul/code-to-list-potential-cluster-key-space-savings-per-table/)						 
	Date:		10/09/15								
	Comments:	Returns list of tables with large cluster keys
				and the possibility of saving space. 					 
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID ('tempdb..#IndexKeySize') IS NOT NULL
	DROP TABLE #IndexKeySize;
CREATE TABLE #IndexKeySize (
	 Schema_Name SYSNAME
	,Object_Name SYSNAME
	,Index_Name VARCHAR(128)
	,ObjectID INT
	,Index_Count SMALLINT DEFAULT(0)
	,[Rows] BIGINT DEFAULT(0)
	,Key_Count SMALLINT DEFAULT(0)
	,Key_Width SMALLINT DEFAULT(0)
	);

INSERT INTO #IndexKeySize (
	Schema_Name
	,Object_Name
	,ObjectID
	)
SELECT SCHEMA_NAME(o.[schema_id])
	,OBJECT_NAME(o.[object_id])
	,o.[object_id]
FROM sys.objects o
WHERE o.[type_desc] IN ('USER_TABLE', 'VIEW')
	AND o.[is_ms_shipped] = 0
	AND EXISTS (
				SELECT *
				FROM sys.indexes
				WHERE [index_id] = 1
				    AND [type] = 1
					AND [object_id] = o.[object_id]
				);

UPDATE #IndexKeySize
SET [Rows] = (
		SELECT SUM([rows])
		FROM sys.partitions p
		WHERE p.[object_id] = [ObjectID]
			AND p.[index_id] = 1
		)
	,[Index_Name] = (
		SELECT NAME
		FROM sys.indexes i
		WHERE i.[object_id] = [ObjectID]
			AND i.index_id = 1
			AND i.[type] = 1
		)
	,[Index_Count] = (
		SELECT COUNT(*)
		FROM sys.indexes i
		WHERE i.[object_id] = [ObjectID]
			AND i.[is_hypothetical] = 0
			AND i.[is_disabled] = 0
			AND i.[index_id] != 0
		)
	,[Key_Count] = (
		SELECT COUNT(*)
		FROM sys.index_columns ic
		WHERE ic.[object_id] = [ObjectID]
			AND ic.[index_id] = 1
		)
	,[Key_Width] = (
		SELECT SUM(c.[max_length])
		FROM sys.columns c
		INNER JOIN sys.index_columns ic ON c.[object_id] = ic.[object_id]
			AND c.[object_id] = [ObjectID]
			AND ic.[column_id] = c.[column_id]
			AND ic.[index_id] = 1
		);

SELECT 
	 [Schema_Name]
	,[Object_Name]
	,[Index_Name]
	,[Index_Count]
	,[Key_Count]
	,[Key_Width]
	,[Rows]
	,[Index_Count] * [Rows] * [Key_Width] / 1024 / 1024 AS [Key_Space_MB]
	,([Index_Count] * [Rows] * ([Key_Width] - 8)) / 1024 / 1024 AS [Potential_Savings_MB]
FROM #IndexKeySize
WHERE [Key_Count] > 1
	AND [Key_Width] > 8
ORDER BY [Potential_Savings_MB] DESC
		,[Rows] DESC;

DROP TABLE #IndexKeySize;