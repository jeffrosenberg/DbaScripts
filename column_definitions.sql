SELECT [schema] = s.name, [table] = t.name
, [column] = c.name, c.column_id, [datatype] = typ.name
--Often-used column properties
, c.max_length, c.precision, c.scale, c.is_nullable
, c.is_identity, c.is_computed
--Other column properties
--, c.system_type_id, c.user_type_id
--, c.collation_name, c.is_ansi_padded, c.is_rowguidcol
--, c.is_filestream, c.is_replicated, c.is_non_sql_subscribed,
--, c.is_merge_published, c.is_dts_replicated, c.is_xml_document,
--, c.xml_collection_id, c.default_object_id, c.rule_object_id,
--, c.is_sparse, c.is_column_set
FROM sys.schemas AS s
INNER JOIN sys.tables AS t
  ON t.schema_id = s.schema_id
INNER JOIN sys.columns AS c
  ON c.object_id = t.object_id
LEFT JOIN sys.types AS typ
  ON typ.system_type_id = c.system_type_id
WHERE t.name LIKE '%TableName%'