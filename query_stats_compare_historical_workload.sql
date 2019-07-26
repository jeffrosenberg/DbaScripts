-- Source: https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-2017

--- "Recent" workload - last 1 hour  
declare @recent_start_time datetimeoffset;
declare @recent_end_time datetimeoffset;
set @recent_start_time = dateadd(hour, -1, sysutcdatetime());
set @recent_end_time = sysutcdatetime();

--- "History" workload  
declare @history_start_time datetimeoffset;
declare @history_end_time datetimeoffset;
set @history_start_time = dateadd(hour, -24, sysutcdatetime());
set @history_end_time = sysutcdatetime();

with hist as (
  select
    p.query_id as query_id
  , convert(float, sum(rs.avg_duration * rs.count_executions)) as total_duration
  , sum(rs.count_executions) as count_executions
  , count(distinct p.plan_id) as num_plans
  from sys.query_store_runtime_stats as rs
  join sys.query_store_plan as p
    on p.plan_id = rs.plan_id
  where (
    rs.first_execution_time >= @history_start_time
and rs.last_execution_time < @history_end_time
  )
     or (
       rs.first_execution_time <= @history_start_time
   and rs.last_execution_time > @history_start_time
     )
     or (
       rs.first_execution_time <= @history_end_time
   and rs.last_execution_time > @history_end_time
     )
  group by p.query_id
)
   , recent as (
  select
    p.query_id as query_id
  , convert(float, sum(rs.avg_duration * rs.count_executions)) as total_duration
  , sum(rs.count_executions) as count_executions
  , count(distinct p.plan_id) as num_plans
  from sys.query_store_runtime_stats as rs
  join sys.query_store_plan as p
    on p.plan_id = rs.plan_id
  where (
    rs.first_execution_time >= @recent_start_time
and rs.last_execution_time < @recent_end_time
  )
     or (
       rs.first_execution_time <= @recent_start_time
   and rs.last_execution_time > @recent_start_time
     )
     or (
       rs.first_execution_time <= @recent_end_time
   and rs.last_execution_time > @recent_end_time
     )
  group by p.query_id
)
select
  results.query_id as query_id
, results.query_text as query_text
, results.additional_duration_workload as additional_duration_workload
, results.total_duration_recent as total_duration_recent
, results.total_duration_hist as total_duration_hist
, isnull(results.count_executions_recent, 0) as count_executions_recent
, isnull(results.count_executions_hist, 0) as count_executions_hist
from (
  select
    hist.query_id as query_id
  , qt.query_sql_text as query_text
  , round(
      convert(float, recent.total_duration / recent.count_executions - hist.total_duration / hist.count_executions)
      * ( recent.count_executions )
    , 2
    ) as additional_duration_workload
  , round(recent.total_duration, 2) as total_duration_recent
  , round(hist.total_duration, 2) as total_duration_hist
  , recent.count_executions as count_executions_recent
  , hist.count_executions as count_executions_hist
  from hist
  join recent
    on hist.query_id = recent.query_id
  join sys.query_store_query as q
    on q.query_id = hist.query_id
  join sys.query_store_query_text as qt
    on q.query_text_id = qt.query_text_id
) as results
where additional_duration_workload > 0
order by additional_duration_workload desc
option ( merge join );