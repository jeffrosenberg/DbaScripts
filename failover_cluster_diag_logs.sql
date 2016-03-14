--Get list of log filese
CREATE TABLE #DirTree (
	Id int IDENTITY(1,1),
	SubDirectory nvarchar(255),
	Depth smallint,
	FileFlag bit
);
INSERT INTO #DirTree (SubDirectory, Depth, FileFlag)
EXEC xp_dirtree 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\', 2, 1

SELECT * 
FROM #DirTree
WHERE SubDirectory LIKE '%SQLDIAG%'

SELECT TOP 10 
xml_data.value('(event/@name)[1]','varchar(max)') AS 'Name'
,xml_data.value('(event/@package)[1]','varchar(max)') AS 'Package'
,xml_data.value('(event/@timestamp)[1]','datetime') AS 'Time'
,xml_data.value('(event/data[@name=''state'']/value)[1]','int') AS 'State'
,xml_data.value('(event/data[@name=''state_desc'']/text)[1]','varchar(max)') AS 'State Description'
,xml_data.value('(event/data[@name=''failure_condition_level'']/value)[1]','int') AS 'Failure Conditions'
,xml_data.value('(event/data[@name=''node_name'']/value)[1]','varchar(max)') AS 'Node_Name'
,xml_data.value('(event/data[@name=''instancename'']/value)[1]','varchar(max)') AS 'Instance Name'
,xml_data.value('(event/data[@name=''creation time'']/value)[1]','datetime') AS 'Creation Time'
,xml_data.value('(event/data[@name=''component'']/value)[1]','varchar(max)') AS 'Component'
,xml_data.value('(event/data[@name=''data'']/value)[1]','varchar(max)') AS 'Data'
,xml_data.value('(event/data[@name=''info'']/value)[1]','varchar(max)') AS 'Info'
FROM
 ( SELECT object_name AS 'event'
  ,CONVERT(xml,event_data) AS 'xml_data'
  FROM sys.fn_xe_file_target_read_file('C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\SGAGRSQLPY02_MSSQLSERVER_SQLDIAG_0_130958601427500000.xel',NULL,NULL,NULL) 
) 
AS XEventData
--WHERE xml_data.value('(event/data[@name=''state_desc'']/text)[1]','varchar(max)') = 'error'
ORDER BY Time; 