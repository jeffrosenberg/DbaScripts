SELECT fk.name, fk.type_desc
, fk.object_id, t.name
, fk.referenced_object_id, ref.name
, fk.update_referential_action_desc
, fk.delete_referential_action_desc
, fk.is_disabled
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS t
  ON t.object_id = fk.parent_object_id
INNER JOIN sys.tables AS ref
  ON ref.object_id = fk.referenced_object_id
WHERE ref.name = 'MEMBER'