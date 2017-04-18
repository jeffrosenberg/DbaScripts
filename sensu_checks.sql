USE master;

-------------------------------------------------------------------------------
-- Databases on C: (except master/model/msdb)
------------------------------------------------------------------------------- 
SELECT database_name = DB_NAME(f.database_id)
      , file_name = f.name
FROM master.sys.master_files AS f
CROSS APPLY master.sys.dm_os_volume_stats(f.database_id, f.file_id) AS s
WHERE s.volume_mount_point like 'C:%'
  AND DB_NAME(f.database_id) NOT IN ('master', 'model', 'msdb')

-------------------------------------------------------------------------------
-- Databases without backups
-------------------------------------------------------------------------------
IF OBJECT_ID('sys.dm_hadr_database_replica_states') IS NOT NULL
AND OBJECT_ID('sys.dm_hadr_availability_replica_states') IS NOT NULL
	Select database_name = d.name
	from sys.databases d
		LEFT OUTER JOIN sys.dm_hadr_database_replica_states D2
			ON d.database_id = d2.database_id
		LEFT OUTER JOIN sys.dm_hadr_availability_replica_states A
			ON a.replica_id = d2.replica_id and a.group_id = d2.group_id
	Where 
	d.name <> 'tempDB'
	And d.state = 0 -- online
	And d.source_database_id Is Null
	And Not Exists (
		Select 1 From msdb.dbo.backupset
		Where database_name = d.name
		And type In ('D', 'I')
		And DateDiff(hh, backup_finish_date, getdate()) < 168)
	AND ISNULL(A.role_desc,'PRIMARY') = 'PRIMARY'
	;
ELSE
	Select database_name = d.name
	from sys.databases d
	Where 
	d.name <> 'tempDB'
	And d.state = 0 -- online
	And d.source_database_id Is Null
	And Not Exists (
		Select 1 From msdb.dbo.backupset
		Where database_name = d.name
		And type In ('D', 'I')
		And DateDiff(hh, backup_finish_date, getdate()) < 168)
		;


-------------------------------------------------------------------------------
-- DB owner is not SA
-------------------------------------------------------------------------------
DECLARE @serviceAccount AS sysname;

SELECT @serviceAccount = service_account 
FROM sys.dm_server_services 
WHERE  servicename = 'SQL Server (MSSQLSERVER)';

SELECT database_name = d.name
     , owner_name = sp.name
FROM master.sys.databases AS d
LEFT JOIN master.sys.server_principals AS sp
  ON d.owner_sid = sp.sid
WHERE sp.name NOT IN ('sa', @serviceAccount)
   OR sp.name IS NULL;

-------------------------------------------------------------------------------
-- Job owner is not SA
-------------------------------------------------------------------------------
DECLARE @serviceAccount AS sysname, @agentAccount AS sysname;

SELECT @serviceAccount = service_account 
FROM sys.dm_server_services 
WHERE  servicename = 'SQL Server (MSSQLSERVER)';

SELECT @agentAccount = service_account 
FROM sys.dm_server_services 
WHERE  servicename = 'SQL Server Agent (MSSQLSERVER)';

SELECT job_name = j.name
     , owner_name = sp.name
FROM msdb.dbo.sysjobs AS j
LEFT JOIN master.sys.server_principals AS sp
  ON j.owner_sid = sp.sid
WHERE sp.name NOT IN ('sa', @serviceAccount, @agentAccount)
   OR sp.name IS NULL;

-------------------------------------------------------------------------------
-- Confirm that SQL Agent alerts are configured
-------------------------------------------------------------------------------
DECLARE @enabled int, @hasNotification int, @totalAlerts int;
SELECT @enabled = SUM(CASE WHEN s.enabled = 1 THEN 1 ELSE 0 END)
     , @hasNotification = SUM(CASE WHEN s.enabled = 1 AND s.has_notification > 0 THEN 1 ELSE 0 END)
     , @totalAlerts = COUNT(*)
FROM msdb.dbo.sysalerts AS s;

SELECT [Status] = 
  CASE 
    WHEN @totalAlerts = 0 THEN 'No SQL Agent alerts have been created'
    WHEN @enabled = 0 THEN 'All SQL Agent alerts are disabled'
    WHEN @hasNotification = 0 THEN 'All SQL Agent alerts are missing notifications'
    ELSE 'OK'
    END;
  

-------------------------------------------------------------------------------
-- Confirm that SQL Agent operators are configured
-------------------------------------------------------------------------------
SELECT [Status] = 
  CASE 
    WHEN COUNT(*) = 0 THEN 'No SQL Agent operators have been created'
    ELSE 'OK'
    END
FROM msdb.dbo.sysoperators AS s
WHERE s.enabled = 1;

-- Confirm that SQL Agent mail profile is enabled
-- Need to use PowerShell
/*
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
$server = New-Object 'Microsoft.SqlServer.Management.SMO.Server' ('localhost')
if ([String]::IsNullOrEmpty($server.JobServer.AgentMailType) -eq $true) {
  throw "SQL Agent mail is disabled";
}
if ([String]::IsNullOrEmpty($server.JobServer.DatabaseMailProfile) -eq $true) {
  throw "Database Mail profile is not set";
}
*/