-- Disk usage by table
-- adapted from http://stackoverflow.com/questions/7892334/get-size-of-all-tables-in-database

SELECT TableName = t.Name
     , SchemaName = s.Name
     , TotalSpaceMB = SUM(a.total_pages) * 8 / 1024
     , UsedSpaceMB = SUM(a.used_pages) * 8 / 1024
     , UnusedSpaceMB = (SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_ms_shipped = 0 
  AND t.name LIKE '%'
  AND s.name LIKE '%'
GROUP BY t.Name, s.Name
--HAVING SUM(a.total_pages) * 8 / 1024 > 100 -- Show only when TotalSpaceMB above a certain threshold
ORDER BY TotalSpaceMB DESC