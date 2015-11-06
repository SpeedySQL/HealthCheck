/********************************************************************
	Filename:	ServerConfig.sql					 
	Author:		Omid Afzalalghom							 
	Date:		09/09/15								
	Comments:	Returns non-default server configurations for 
				SQL 2005\2008.	
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE master;

DECLARE @cfg TABLE (nm nvarchar (70), value sql_variant);

INSERT @cfg SELECT 'access check cache bucket count',     0					
INSERT @cfg SELECT 'access check cache quota',            0					
INSERT @cfg SELECT 'Ad Hoc Distributed Queries',          0					
INSERT @cfg SELECT 'affinity I/O mask',                   0					
INSERT @cfg SELECT 'affinity mask',                       0					
INSERT @cfg SELECT 'affinity64 I/O mask',                 0					
INSERT @cfg SELECT 'affinity64 mask',                     0					
INSERT @cfg SELECT 'Agent XPs',                           0					
INSERT @cfg SELECT 'allow updates',                       0					
INSERT @cfg SELECT 'awe enabled',					      0
INSERT @cfg SELECT 'backup checksum default',			  0		
INSERT @cfg SELECT 'backup compression default',          0					
INSERT @cfg SELECT 'blocked process threshold (s)',       0					
INSERT @cfg SELECT 'c2 audit mode',                       0					
INSERT @cfg SELECT 'clr enabled',                         0					
INSERT @cfg SELECT 'common criteria compliance enabled',  0					
INSERT @cfg SELECT 'contained database authentication',   0					
INSERT @cfg SELECT 'cost threshold for parallelism',      5					
INSERT @cfg SELECT 'cross db ownership chaining',         0					
INSERT @cfg SELECT 'cursor threshold',                    -1					
INSERT @cfg SELECT 'Database Mail XPs',                   0					
INSERT @cfg SELECT 'default full-text language',          1033					
INSERT @cfg SELECT 'default language',                    0					
INSERT @cfg SELECT 'default trace enabled',               1					
INSERT @cfg SELECT 'disallow results from triggers',      0					
INSERT @cfg SELECT 'EKM provider enabled',                0					
INSERT @cfg SELECT 'filestream access level',             0					
INSERT @cfg SELECT 'fill factor (%)',                     0					
INSERT @cfg SELECT 'ft crawl bandwidth (max)',            100					
INSERT @cfg SELECT 'ft crawl bandwidth (min)',            0					
INSERT @cfg SELECT 'ft notify bandwidth (max)',           100					
INSERT @cfg SELECT 'ft notify bandwidth (min)',           0					
INSERT @cfg SELECT 'index create memory (KB)',            0					
INSERT @cfg SELECT 'in-doubt xact resolution',            0					
INSERT @cfg SELECT 'lightweight pooling',                 0					
INSERT @cfg SELECT 'locks',                               0					
INSERT @cfg SELECT 'max degree of parallelism',           0					
INSERT @cfg SELECT 'max full-text crawl range',           4					
INSERT @cfg SELECT 'max server memory (MB)',              2147483647					
INSERT @cfg SELECT 'max text repl size (B)',              65536					
INSERT @cfg SELECT 'max worker threads',                  0					
INSERT @cfg SELECT 'media retention',                     0					
INSERT @cfg SELECT 'min memory per query (KB)',           1024					
INSERT @cfg SELECT 'min server memory (MB)',              0					
INSERT @cfg SELECT 'nested triggers',                     1					
INSERT @cfg SELECT 'network packet size (B)',             4096					
INSERT @cfg SELECT 'Ole Automation Procedures',           0					
INSERT @cfg SELECT 'open objects',                        0					
INSERT @cfg SELECT 'optimize for ad hoc workloads',       0					
INSERT @cfg SELECT 'PH timeout (s)',                      60					
INSERT @cfg SELECT 'precompute rank',                     0					
INSERT @cfg SELECT 'priority boost',                      0					
INSERT @cfg SELECT 'query governor cost limit',           0					
INSERT @cfg SELECT 'query wait (s)',                      -1					
INSERT @cfg SELECT 'recovery interval (min)',             0					
INSERT @cfg SELECT 'remote access',                       1					
INSERT @cfg SELECT 'remote admin connections',            0					
INSERT @cfg SELECT 'remote login timeout (s)',            10					
INSERT @cfg SELECT 'remote proc trans',                   0					
INSERT @cfg SELECT 'remote query timeout (s)',            600					
INSERT @cfg SELECT 'Replication XPs',                     0					
INSERT @cfg SELECT 'scan for startup procs',              0					
INSERT @cfg SELECT 'server trigger recursion',            1					
INSERT @cfg SELECT 'set working set size',                0					
INSERT @cfg SELECT 'show advanced options',               0					
INSERT @cfg SELECT 'SMO and DMO XPs',                     1					
INSERT @cfg SELECT 'SQL Mail XPs',					      0
INSERT @cfg SELECT 'transform noise words',               0					
INSERT @cfg SELECT 'two digit year cutoff',               2049					
INSERT @cfg SELECT 'user connections',                    0					
INSERT @cfg SELECT 'user options',                        0		
INSERT @cfg SELECT 'Web Assistant Procedures',		      0		
INSERT @cfg SELECT 'xp_cmdshell',                         0;			

WITH a 
AS (
	SELECT d.name, d.value, (SELECT value FROM @cfg e WHERE nm = d.name)  Default_Value
	FROM @cfg c 
	RIGHT JOIN sys.configurations d 
	  ON c.nm = CASE WHEN  d.name = 'blocked process threshold' THEN 'blocked process threshold (s)' ELSE  d.name END
	   AND c.value = d.value_in_use
	WHERE c.value IS NULL
)
SELECT 
   name as 'Name'
  ,Default_Value
  ,value as Current_Value
FROM a
ORDER BY name;  
