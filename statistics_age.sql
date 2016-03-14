-- SQL Server 2005/2008 Statistics Queries
-- Glenn Berry 
-- August 2010
-- http://glennberrysqlperformance.spaces.live.com/
-- Twitter: GlennAlanBerry

-- When were Statistics last updated on all indexes?
SELECT o.name, i.name AS [Index Name],  
       STATS_DATE(i.[object_id], i.index_id) AS [Statistics Date], 
       s.auto_created, s.no_recompute, s.user_created
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK)
ON i.[object_id] = s.[object_id] 
AND i.index_id = s.stats_id
WHERE o.[type] = 'U'
ORDER BY STATS_DATE(i.[object_id], i.index_id) ASC;    


-- Find indexes with no_recompute turned on
SELECT o.name, i.name AS [Index Name],  
       STATS_DATE(i.[object_id], i.index_id) AS [Statistics Date], 
       s.auto_created, s.no_recompute, s.user_created
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK)
ON i.[object_id] = s.[object_id] 
AND i.index_id = s.stats_id
WHERE o.[type] = 'U'
AND no_recompute = 1
ORDER BY STATS_DATE(i.[object_id], i.index_id) ASC;

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
--ORDER BY STATS_DATE(i.[object_id], i.index_id) ASC;   
ORDER BY reads DESC