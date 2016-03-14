
-- Stats dates by index operational stats
-- Jeff Rosenberg, 1/5/2016
SELECT o.name, i.name AS [Index Name],  
       STATS_DATE(i.[object_id], i.index_id) AS [Statistics Date], 
       s.auto_created, s.no_recompute, s.user_created,
       reads = (os.range_scan_count + os.singleton_lookup_count),
       updates = os.leaf_update_count,
       other_dml = (os.leaf_insert_count + os.leaf_ghost_count + os.leaf_delete_count)
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
  ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK)
  ON i.[object_id] = s.[object_id] 
    AND i.index_id = s.stats_id
INNER JOIN sys.dm_db_index_operational_stats(db_id(), NULL, NULL, NULL) AS os
  ON os.object_id = i.object_id
    AND os.index_id = i.index_id
WHERE o.[type] = 'U'
  AND (STATS_DATE(i.[object_id], i.index_id) < '1/5/2016'
       OR STATS_DATE(i.[object_id], i.index_id) IS NULL)
ORDER BY STATS_DATE(i.[object_id], i.index_id) ASC;   
--ORDER BY reads DESC

-- Loop through the query above and update statistics one index at a time
DECLARE @sql nvarchar(4000), @start datetime2, @end datetime2
DECLARE @sch sysname, @tbl sysname, @ix sysname, @reads bigint
DECLARE st_curs CURSOR FOR
SELECT TOP 30 [schema] = sch.name
, [table] = o.name
, [index] = i.name
, [reads] = (os.range_scan_count + os.singleton_lookup_count)
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.schemas AS sch 
  ON sch.schema_id = o.schema_id
INNER JOIN sys.indexes AS i WITH (NOLOCK)
  ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK)
  ON i.[object_id] = s.[object_id] 
    AND i.index_id = s.stats_id
INNER JOIN sys.dm_db_index_operational_stats(db_id(), NULL, NULL, NULL) AS os
  ON os.object_id = i.object_id
    AND os.index_id = i.index_id
WHERE o.[type] = 'U'
  AND (STATS_DATE(i.[object_id], i.index_id) < '1/5/2016'
       OR STATS_DATE(i.[object_id], i.index_id) IS NULL)
ORDER BY reads DESC;

OPEN st_curs
FETCH NEXT FROM st_curs INTO @sch, @tbl, @ix, @reads

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @sql = 'UPDATE STATISTICS ' + QUOTENAME(@sch) + '.' + QUOTENAME(@tbl)
           + ' ' + QUOTENAME(@ix) + ' -- Reads: ' + CAST(@reads AS nvarchar(20))
  SET @start = GETDATE();
  PRINT @sql
  PRINT 'Start: ' + CONVERT(varchar(10), @start, 108)

  EXEC sp_executesql @sql;

  SET @end = GETDATE();
  PRINT 'End: ' + CONVERT(varchar(10), @end, 108)
  PRINT 'Time elapsed: ' + CAST(DATEDIFF(SECOND, @start, @end) AS varchar(10)) + ' seconds.'
  PRINT ''

  FETCH NEXT FROM st_curs INTO @sch, @tbl, @ix, @reads
END

CLOSE st_curs
DEALLOCATE st_curs