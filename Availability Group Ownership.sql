USE [master]
GO
SELECT ag.[name] AS AG_name, ag.group_id, r.replica_id, r.owner_sid, p.[name] as owner_name 
FROM sys.availability_groups ag 
   JOIN sys.availability_replicas r ON ag.group_id = r.group_id
   JOIN sys.server_principals p ON r.owner_sid = p.[sid]


/*  TO FIX 
 USE [master]
GO
ALTER AUTHORIZATION ON AVAILABILITY GROUP::[AGName] TO [public];
GO
*/



--https://www.mssqltips.com/sqlservertip/5201/drop-login-issues-for-logins-tied-to-sql-server-availability-groups/