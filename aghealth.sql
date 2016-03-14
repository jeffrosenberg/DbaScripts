IF Object_ID('sys.availability_groups') IS NOT NULL
BEGIN
	SELECT ag.name AS ag_name, ar.replica_server_name AS ag_replica_server, d.Name as DatabaseName,
		is_ag_replica_local = CASE WHEN ar_state.is_local = 1 THEN N'LOCAL' ELSE 'REMOTE' END , 
		ag_replica_role = CASE WHEN ar_state.role_desc IS NULL THEN N'DISCONNECTED' ELSE ar_state.role_desc END, 
		ar.availability_mode_desc,
		dr_state.last_hardened_lsn, 
		dr_state.last_hardened_time, 
		dr_state.database_state_desc,
		dr_state.synchronization_state_desc,
		dr_state.synchronization_health_desc,
		ISNULL(dr_state.log_send_queue_size,0) as log_send_queue_size,
		ISNULL(dr_state.log_send_rate,0) as log_send_rate,
		ISNULL(dr_state.redo_queue_size,0) as redo_queue_size,
		ISNULL(dr_state.redo_rate,0) as redo_rate,
		-- these numbers are in KB or KB/sec. Calculate latency:
		ISNULL(dr_state.log_send_queue_size,0) / ISNULL(dr_state.log_send_rate+0.001, 100.0) + 
		ISNULL(dr_state.redo_queue_size,0)     / ISNULL(dr_state.redo_rate+0.001, 100.0) as LatencySec
		--, datediff(s,last_hardened_time, 	getdate()) as 'SecondsBehindPrimary' 
	FROM (( sys.availability_groups AS ag JOIN sys.availability_replicas AS ar ON ag.group_id = ar.group_id ) 
		JOIN sys.dm_hadr_availability_replica_states AS ar_state ON ar.replica_id = ar_state.replica_id) 
		JOIN sys.dm_hadr_database_replica_states dr_state on ag.group_id = dr_state.group_id and dr_state.replica_id = ar_state.replica_id
		INNER JOIN  sys.databases D ON dr_state.database_ID = D.Database_ID
	ORDER BY D.Name, Ar.replica_server_name
END
ELSE
BEGIN
	SELECT top 1 * from sys.tables where name = '-1';
END