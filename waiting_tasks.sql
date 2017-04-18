-- Waiting tasks
-- Via Paul Randal, Performance Troubleshooting Using Wait Statistics
-- https://app.pluralsight.com/library/courses/sqlserver-waits/table-of-contents

SELECT dowt.session_id, dowt.exec_context_id, dowt.wait_duration_ms, dowt.wait_type
, dowt.blocking_session_id, dowt.resource_description, des.program_name
, dest.text, dest.dbid, der.query_hash, deqp.query_plan, des.cpu_time, des.memory_usage
FROM sys.dm_os_waiting_tasks AS dowt
INNER JOIN sys.dm_exec_sessions AS des
  ON des.session_id = dowt.session_id
INNER JOIN sys.dm_exec_requests AS der
  ON der.session_id = des.session_id
OUTER APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest
OUTER APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
WHERE des.is_user_process = 1
ORDER BY dowt.session_id, dowt.exec_context_id