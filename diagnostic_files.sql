--
-- Get list of SQL Diagnostic log files
--

-- Get MSSQL log path (depends on version number)
DECLARE @sqlVersion AS varchar(2) = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(255)), 2)
DECLARE @sqlDiagDir AS varchar(2000) = 'C:\Program Files\Microsoft SQL Server\MSSQL' + @sqlVersion + '.MSSQLServer\MSSQL\Log\'

-- Use xp_cmdshell with "dir" command to do a wildcard search
DECLARE @cmd varchar(4000);
SET @cmd = 'dir "' + @sqlDiagDir + '*SQLDIAG*.xel"';
EXEC xp_cmdshell @cmd;