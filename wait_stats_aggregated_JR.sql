-- Aggregated wait stats
-- Adapted from Paul Randal, Performance Troubleshooting Using Wait Statistics
-- https://app.pluralsight.com/library/courses/sqlserver-waits/table-of-contents
-- Removed self-join, GROUP BY, and HAVING clauses
-- Superceded by Paul Randal 2016 update to
-- http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/
  
WITH Waits AS
	(SELECT
		wait_type,
		wait_time_ms / 1000.0 AS WaitS,
		(wait_time_ms - signal_wait_time_ms) / 1000.0
			AS ResourceS,
		signal_wait_time_ms / 1000.0 AS SignalS,
		waiting_tasks_count AS WaitCount,
		100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage
	FROM sys.dm_os_wait_stats
  WHERE wait_type NOT IN (
      -- Full list of wait types via: 
      -- http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/

      N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
      N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
      N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
      N'CHKPT', N'CLR_AUTO_EVENT',
      N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
 
      -- Maybe comment these four if you have mirroring issues
      N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
      N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
 
      N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
      N'EXECSYNC', N'FSAGENT',
      N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
 
      -- Maybe comment these six if you have AG issues
      N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
      N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
      N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
 
      N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
      N'LOGMGR_QUEUE', N'MEMORY_ALLOCATION_EXT',
      N'ONDEMAND_TASK_QUEUE',
      N'PREEMPTIVE_XE_GETTARGETSTATE',
      N'PWAIT_ALL_COMPONENTS_INITIALIZED',
      N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
      N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
      N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
      N'QDS_SHUTDOWN_QUEUE', N'REDO_THREAD_PENDING_WORK',
      N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
      N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
      N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
      N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
      N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
      N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
      N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
      N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
      N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
      N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
      N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
      N'WAIT_XTP_RECOVERY',
      N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
      N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
      N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT',

      --Additional excludes by Jeff Rosenberg
      N'ADDITIONAL_WAIT_TYPES_TO_EXCLUDE'
      )
  )
SELECT
	wait_type = W1.wait_type                         
, wait_s = CAST (W1.WaitS AS decimal(14, 2))       
, resource_s = CAST (W1.ResourceS AS decimal(14, 2))
, signal_s = CAST (W1.SignalS AS decimal(14, 2))    
, wait_count = W1.WaitCount                         
, percentage = CAST (W1.Percentage AS decimal(4, 2))
, avgwait_s =	CAST ((W1.WaitS / W1.WaitCount) AS DECIMAL (14, 4))
, avgres_s =	CAST ((W1.ResourceS / W1.WaitCount) AS DECIMAL (14, 4))
, avgsig_s =	CAST ((W1.SignalS / W1.WaitCount) AS DECIMAL (14, 4))
FROM Waits AS W1
WHERE CAST (W1.Percentage AS decimal(4, 2)) >= 0.1
ORDER BY W1.Percentage DESC