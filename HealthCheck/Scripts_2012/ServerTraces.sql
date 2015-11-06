/********************************************************************
	Filename:	ServerTraces.sql					 
	Author:		Omid Afzalalghom							 
	Date:		11/09/15								
	Comments:	Returns a list of active traces.
	Revisions:											 
********************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	 id
	,status
	,path
	,is_rowset
	,event_count 
FROM sys.traces;