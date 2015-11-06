/**********************************************************************
	Filename:	ServerAudits.sql					 
	Author:		Omid Afzalalghom 		 
	Date:		10/09/15								
	Comments:	Returns list of server audits.
	Revisions:	
**********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 name 
	,status_desc
	,status_time
	,audit_file_path
	,audit_file_size/1048576 size_MB
FROM sys.dm_server_audit_status
ORDER BY name;