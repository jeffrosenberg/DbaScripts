:connect sgomcsqlpy04.yosemite.local

EXEC sp_polybase_leave_group
--EXEC sp_polybase_join_group 'SGOMCSQLPY03', 16450, 'MSSQLSERVER';  
GO

:connect sgomcsqlpy05.yosemite.local

EXEC sp_polybase_leave_group
--EXEC sp_polybase_join_group 'SGOMCSQLPY03', 16450, 'MSSQLSERVER';  
GO