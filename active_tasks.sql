-- Active tasks
-- Via Paul Randal, Performance Troubleshooting Using Wait Statistics
-- https://app.pluralsight.com/library/courses/sqlserver-waits/table-of-contents

SELECT dot.scheduler_id
     , dot.task_state
     --, der.wait_type
     , task_count = COUNT(*)
FROM sys.dm_os_tasks AS dot
INNER JOIN sys.dm_exec_requests AS der
  ON dot.[session_id] = der.[session_id]
INNER JOIN sys.dm_exec_sessions AS des
    ON des.[session_id] = der.[session_id]
WHERE des.is_user_process = 1
GROUP BY dot.scheduler_id
       , dot.task_state
       --, der.wait_type
ORDER BY dot.task_state
       , dot.scheduler_id
