SELECT [Rows] = SUM(row_count)
FROM sys.dm_db_partition_stats
WHERE object_id=OBJECT_ID('dbo.AccrualCounters')   
AND (index_id=0 or index_id=1);
