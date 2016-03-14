DECLARE @userName sysname, @roleName sysname

DECLARE role_desc 
CURSOR FOR
SELECT dp2.name, dp3.name 
FROM sys.database_permissions dp
INNER JOIN sys.database_principals dp2 ON dp.grantee_principal_id = dp2.principal_id
INNER JOIN sys.database_role_members drm ON dp2.principal_id = drm.member_principal_id
INNER JOIN sys.database_principals dp3 ON drm.role_principal_id = dp3.principal_id
WHERE dp2.name != 'public'

OPEN role_desc;

FETCH NEXT FROM role_desc INTO @userName, @roleName;

WHILE @@FETCH_STATUS = 0
BEGIN
  PRINT 'EXEC sp_addrolemember @rolename = ''' + @roleName + ''', @membername = ''' +  @userName + '''';
  FETCH NEXT FROM role_desc INTO @userName, @roleName;
END

CLOSE role_desc;
DEALLOCATE role_desc;

EXEC sp_addrolemember @rolename = 'db_datareader', @membername = 'YOSEMITE\PFC_SQL_P_TallyMDBIntegration_RWA'