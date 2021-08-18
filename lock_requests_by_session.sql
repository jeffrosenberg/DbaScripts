select
    l.resource_type,
    l.request_mode,
    l.request_status,
    l.request_session_id,
	l.resource_associated_entity_id,
	resource = coalesce(o.name, o2.name),
    r.command,
    r.status,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    request_sql_text = st.text,
    s.program_name,
    most_recent_sql_text = stc.text
from sys.dm_tran_locks l
left join sys.dm_exec_requests r
  on l.request_session_id = r.session_id
left join sys.dm_exec_sessions s
  on l.request_session_id = s.session_id
left join sys.dm_exec_connections c
  on s.session_id = c.session_id
left join sys.objects o
  on o.object_id = l.resource_associated_entity_id
left join sys.allocation_units au
  on au.allocation_unit_id = l.resource_associated_entity_id
left join sys.partitions p
  on p.partition_id = au.container_id
left join sys.objects o2
  on o2.object_id = p.object_id
outer apply sys.dm_exec_sql_text(r.sql_handle) st
outer apply sys.dm_exec_sql_text(c.most_recent_sql_handle) stc
where request_session_id = 115
order by request_session_id;