SELECT DISTINCT [user] = dp2.name
, dp.class_desc, dp.major_id, dp.minor_id
, [securable] = COALESCE(db.name, s.name, o.name)
, dp.permission_name, dp.state_desc
FROM sys.database_permissions dp
INNER JOIN sys.database_principals dp2 
  ON dp.grantee_principal_id = dp2.principal_id
LEFT JOIN sys.databases AS db
  ON db.database_id = DB_ID()
    AND dp.class_desc = 'DATABASE'
LEFT JOIN sys.schemas AS s
  ON s.schema_id = dp.major_id
    AND dp.class_desc = 'SCHEMA'
LEFT JOIN sys.objects AS o
  ON o.object_id = dp.major_id
    AND dp.class_desc NOT IN ('DATABASE','SCHEMA')
WHERE dp2.name != 'public'
ORDER BY dp2.name