SELECT sl.name, sl.sid, sl.password_hash
, create_stmt = 
    'CREATE LOGIN ' + sl.name
  + ' WITH PASSWORD = ' + CONVERT(varchar(500), sl.password_hash, 1) + ' HASHED'
  + ' , SID = ' + CONVERT(varchar(500), sl.sid, 1)
FROM sys.sql_logins AS sl