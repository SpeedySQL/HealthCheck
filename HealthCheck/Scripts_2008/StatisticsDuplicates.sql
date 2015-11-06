/********************************************************************
	Filename:	StatisticsDuplicates.sql					 
	Author:		Omid Afzalalghom (Statistics size query adapted from
									Fabiano Amorim's script:
				https://www.simple-talk.com/sql/sql-training/questions-about-sql-server-distribution-statistics/)
	Date:		11/09/15								
	Comments:	Returns list of duplicate statistics with their sizes.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID('tempdb.dbo.#TMP') IS NOT NULL
  DROP TABLE #TMP;
GO
CREATE TABLE #TMP (ID INT IDENTITY(1,1) PRIMARY KEY,
				   SchemaName	   VARCHAR(256),
                   Table_Name      VARCHAR(256),
                   Column_Name     VARCHAR(256),
                   Stats_Name      VARCHAR(256),
                   Duplicate_Name  VARCHAR(256),
                   ColStats_Stream VARBINARY(MAX),
                   ColRows         BIGINT,
                   ColData_Pages   BIGINT,
                   Stats_Updated   DATETIME);
GO

DECLARE @Tab TABLE (ROWID			INT IDENTITY(1,1) PRIMARY KEY,
					SchemaName		VARCHAR(256),
                    Table_Name		VARCHAR(256),
                    Column_Name		VARCHAR(256),
                    Stats_Name		VARCHAR(256),
                    Duplicate_Name	VARCHAR(256),
                    Stats_Updated	DATETIME);
 
DECLARE @i           INT = 0,
        @Schema_Name  VARCHAR(256) = '',
        @Table_Name  VARCHAR(256) = '',
        @Column_Name VARCHAR(256) = '',
        @Stats_Name  VARCHAR(256) = '',
        @Duplicate_Name	VARCHAR(256) = '',
        @Stats_Updated DATETIME;
		 
--Index-based statistics.
WITH index_stats
AS (
	SELECT  
		 s.object_id
		,s.stats_id
		,sc.column_id
		,s.name AS stats_name
		,c.name AS column_name
	FROM sys.stats AS s
	INNER JOIN sys.stats_columns AS sc ON s.stats_id = sc.stats_id
		AND s.object_id = sc.object_id
	INNER JOIN sys.columns AS c ON c.object_id = sc.object_id
		AND c.column_id = sc.column_id
	INNER JOIN sys.indexes i ON s.name = i.name
		AND i.object_id = s.object_id
	INNER JOIN sys.index_columns ic ON ic.object_id = s.object_id
		AND i.index_id = ic.index_id
		AND sc.column_id = ic.column_id
	WHERE s.has_filter = 0
		AND ic.key_ordinal = 1  --First column in index.
		AND OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
	)	
INSERT INTO @Tab (SchemaName, Table_Name, Column_Name, Stats_Name, Duplicate_Name, Stats_Updated)
SELECT 
	 OBJECT_SCHEMA_NAME(s1.object_id)
	,OBJECT_NAME(s1.object_id) AS table_name
	,s1.column_name
	,s1.stats_name AS stats_name
	,s2.name AS identical_stats_name
	,STATS_DATE(s2.object_id, s2.stats_id) 
FROM index_stats s1
INNER JOIN sys.stats s2 ON s1.object_id = s2.object_id
INNER JOIN sys.stats_columns sc ON s2.stats_id = sc.stats_id
	AND s2.object_id = sc.object_id
	AND s1.column_id = sc.column_id
WHERE s2.auto_created = 1
	AND sc.stats_column_id = 1;
 
SELECT TOP 1 @i = ROWID,
	   @Schema_Name = SchemaName,
       @Table_Name = Table_Name,
       @Column_Name = Column_Name,
       @Stats_Name = Stats_Name,
       @Duplicate_Name = Duplicate_Name,
       @Stats_Updated = Stats_Updated
  FROM @Tab
WHERE ROWID > @i;
 
WHILE @@ROWCOUNT > 0
BEGIN;

  --Get statistics sizes.	
  INSERT INTO #TMP(ColStats_Stream, ColRows, ColData_Pages)
  EXEC ('DBCC SHOW_STATISTICS ("' + @Schema_Name + '.' + @Table_Name + '", "'+ @Stats_Name +'") WITH STATS_STREAM, NO_INFOMSGS');

  WITH CTE_Temp AS (SELECT TOP (@@ROWCOUNT) * FROM #TMP ORDER BY ID DESC)
  UPDATE CTE_Temp
     SET SchemaName = @Schema_Name,
		 Table_Name = @Table_Name,
         Column_Name = @Column_Name,
         Stats_Name = @Stats_Name,
         Duplicate_Name = @Duplicate_Name,
         Stats_Updated = @Stats_Updated;
 
  SELECT TOP 1 
		 @Schema_Name = SchemaName,
		 @i = ROWID,
         @Table_Name = Table_Name,
         @Column_Name = Column_Name,
         @Stats_Name = Stats_Name,
         @Duplicate_Name = Duplicate_Name,
         @Stats_Updated = Stats_Updated
    FROM @Tab
   WHERE ROWID > @i;
END

SELECT 
	   SchemaName AS 'Schema_Name',
	   Table_Name,
       Column_Name,
       Stats_Name,
       Duplicate_Name,
       CAST(DATALENGTH(ColStats_Stream) / 1024. AS DECIMAL(8,2)) AS [Size_KB],
       CAST(Stats_Updated AS DATE) Stats_Updated
FROM #TMP
ORDER BY [Size_KB] DESC;   
 