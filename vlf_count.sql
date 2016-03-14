SET NOCOUNT ON;

CREATE TABLE #to
(
  DBName SYSNAME,
  FileCount INT
);

DECLARE @v INT;
SELECT @v = CONVERT(INT, PARSENAME(CONVERT(VARCHAR(32), 
  SERVERPROPERTY('ProductVersion')), 4));

DECLARE @sql NVARCHAR(MAX);

SET @sql = N'CREATE TABLE #ti
  (
    ' + CASE WHEN @v >= 11 THEN 'RecoveryUnitId INT,' ELSE '' END + '    
    FileId int
    , FileSize nvarchar(255)
    , StartOffset nvarchar(255)
    , FSeqNo nvarchar(255)
    , Status int
    , Parity int
    , CreateLSN nvarchar(255)
);';

SELECT @sql = @sql + N'
  INSERT #ti EXEC ' + QUOTENAME(name) 
    + '.sys.sp_executesql N''DBCC LOGINFO WITH NO_INFOMSGS'';
  INSERT #to(DBName,FileCount) SELECT N''' + name + ''', COUNT(*) FROM #ti;
  TRUNCATE TABLE #ti;'
FROM sys.databases
WHERE database_id > 4 AND [state] = 0;

EXEC sp_executesql @sql;

SELECT DBName, FileCount FROM #to -- WHERE FileCount > [some threshold];

DROP TABLE #to;