SELECT sl.name, sl.sid, sl.password_hash
FROM sys.sql_logins AS sl

DECLARE @loginName AS sysname, @sid varbinary(256), @hash varbinary(256);
DECLARE login_curs 
CURSOR FOR
SELECT sl.name, sl.sid, sl.password_hash
FROM sys.sql_logins AS sl

OPEN login_curs;

FETCH NEXT FROM login_curs INTO @loginName, @sid, @hash;

WHILE @@FETCH_STATUS = 0
BEGIN
  PRINT --Doesn't work, passes out nonsense computer-speak... how to properly cast to varchar?
    'CREATE LOGIN ' + @loginName
  + ' WITH PASSWORD = ' + CAST(@hash AS varchar(500)) + ' HASHED'
  + ' , SID = ' + CAST(@sid AS varchar(500));

  FETCH NEXT FROM login_curs INTO @loginName, @sid, @hash;
END

CLOSE login_curs;
DEALLOCATE login_curs;

RETURN;