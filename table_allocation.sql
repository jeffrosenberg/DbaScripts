-- Detailed allocation by table
-- via: https://www.simple-talk.com/sql/database-administration/whats-the-point-of-using-varcharn-anymore/
-- NOTE: takes a long time, filter to only those objects you want to investigate
SELECT
  table_name = OBJECT_NAME([object_id])
, alloc_unit_type_desc
, page_count           
, avg_page_space_used_in_percent
, record_count 
, min_record_size_in_bytes
, max_record_size_in_bytes
, forwarded_record_count
FROM sys.dm_db_index_physical_stats (
  DB_ID(), -- Database
  NULL, -- Object ID (probably want to populate this)
  NULL, -- Index ID
  NULL, -- Partition Number
  'DETAILED' -- Mode (leave as 'Detailed')
); 