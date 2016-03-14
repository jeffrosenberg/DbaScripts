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
ORDER BY Depth, FileFlag, SubDirectory