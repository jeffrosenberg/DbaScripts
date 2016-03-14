
SELECT t.object_id, table_name = t.name, t.type_desc
, create_date = CAST(t.create_date AS date)
, modify_date = CAST(t.modify_date AS date)
, p.partition_id, p.partition_number
, p.index_id, index_name = i.name
, p.rows, p.data_compression_desc
FROM sys.tables AS t
INNER JOIN sys.partitions AS p
  ON p.object_id = t.object_id
LEFT OUTER JOIN sys.indexes AS i
  ON i.object_id = t.object_id
    AND i.index_id = p.index_id
WHERE t.type = 'U'
ORDER BY p.data_compression_desc, rows DESC;