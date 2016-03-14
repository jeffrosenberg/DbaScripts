SELECT session_id as SPID, command, start_time
, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time 
FROM sys.dm_exec_requests r
WHERE r.command LIKE 'backup%'
  OR r.command LIKE 'restore%'