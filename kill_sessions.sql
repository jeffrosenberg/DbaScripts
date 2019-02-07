-- Take a look at the open sessions
SELECT des.session_id
     , des.login_name
     , des.host_name
     , der.start_time
     , run_time_s = DATEDIFF(second, der.start_time, GETDATE())
     , der.wait_type
     , der.status
     , der.command
     , der.blocking_session_id
FROM sys.dm_exec_requests AS der
INNER JOIN sys.dm_exec_sessions AS des
  ON des.session_id = der.session_id
WHERE des.is_user_process = 1
  AND des.login_name = 'sql_sghgpsqlpy_hyatt'
  AND der.start_time <= DATEADD(second, -10, GETDATE())
  AND des.host_name LIKE 'SGHGPSVCPY%'

RETURN; -- Don't accidentally kill them unintentionally; stop here unless explicitly running the section below to kill

DECLARE @sessionId int;
DECLARE @sql nvarchar(4000);

DECLARE sessionCurs CURSOR FOR 
SELECT des.session_id
FROM sys.dm_exec_sessions AS des
FROM sys.dm_exec_requests AS der
INNER JOIN sys.dm_exec_sessions AS des
  ON des.session_id = der.session_id
WHERE des.is_user_process = 1
  AND des.login_name = 'sql_sghgpsqlpy_hyatt'
  AND des.host_name LIKE 'SGHGPSVCPY%'
  --AND der.start_time <= DATEADD(second, -10, GETDATE()) -- running for over 10 seconds


OPEN sessionCurs
FETCH NEXT FROM sessionCurs INTO @sessionId

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @sql = 'KILL ' + CAST(@sessionId AS nvarchar)
  EXEC (@sql);
  FETCH NEXT FROM sessionCurs INTO @sessionId
END

CLOSE sessionCurs
DEALLOCATE sessionCurs