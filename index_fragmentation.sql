SELECT [table] = t.name, [index] = ix.name
, i.index_type_desc, i.avg_fragmentation_in_percent, i.avg_fragment_size_in_pages
, i.page_count
, rough_fragmentation_impact_score = i.page_count * i.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS i
INNER JOIN sys.tables AS t
  ON i.object_id = t.object_id
INNER JOIN sys.indexes AS ix
  ON ix.object_id = i.object_id
    AND ix.index_id = i.index_id
WHERE avg_fragmentation_in_percent >= 20.0
  AND i.index_type_desc = 'CLUSTERED INDEX'
--ORDER BY i.page_count DESC
ORDER BY rough_fragmentation_impact_score DESC

SELECT [table] = t.name, [index] = ix.name
, i.index_type_desc, i.avg_fragmentation_in_percent, i.avg_fragment_size_in_pages
, i.page_count
, rough_fragmentation_impact_score = i.page_count * i.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS i
INNER JOIN sys.tables AS t
  ON i.object_id = t.object_id
INNER JOIN sys.indexes AS ix
  ON ix.object_id = i.object_id
    AND ix.index_id = i.index_id
WHERE avg_fragmentation_in_percent >= 30.0
--ORDER BY i.page_count DESC
ORDER BY avg_fragmentation_in_percent DESC