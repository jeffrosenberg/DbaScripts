SELECT  OBJECT_SCHEMA_NAME(s.object_id) schema_name,
        OBJECT_NAME(s.object_id) table_name,
        SUM(s.used_page_count) used_pages,
        SUM(s.reserved_page_count) reserved_pages
FROM    sys.dm_db_partition_stats s
JOIN    sys.tables t
        ON s.object_id = t.object_id
GROUP BY s.object_id
ORDER BY used_pages DESC