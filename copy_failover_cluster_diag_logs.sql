--Get list of log files
CREATE TABLE #DirTree (
	Id int IDENTITY(1,1),
	SubDirectory nvarchar(255),
	Depth smallint,
	FileFlag bit
);
INSERT INTO #DirTree (SubDirectory, Depth, FileFlag)
EXEC xp_dirtree 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\', 3, 1

SELECT * 
FROM #DirTree
WHERE SubDirectory LIKE '%SQLDIAG%'

SELECT * 
FROM #DirTree
ORDER BY Depth

DECLARE @cmd varchar(8000);
SET @cmd = 'copy "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\*SQLDIAG*.xel" "\\commvault\SQLDump\DiagnosticLogs\"'
EXEC sys.xp_cmdshell @cmd;