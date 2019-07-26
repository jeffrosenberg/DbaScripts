-- Source: https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-2017

select
  qt.query_sql_text
, q.query_id
, qt.query_text_id
, rs1.runtime_stats_id as runtime_stats_id_1
, rsi1.start_time as interval_1
, p1.plan_id as plan_1
, rs1.avg_duration as avg_duration_1
, rs2.avg_duration as avg_duration_2
, p2.plan_id as plan_2
, rsi2.start_time as interval_2
, rs2.runtime_stats_id as runtime_stats_id_2
from sys.query_store_query_text as qt
join sys.query_store_query as q
  on qt.query_text_id = q.query_text_id
join sys.query_store_plan as p1
  on q.query_id = p1.query_id
join sys.query_store_runtime_stats as rs1
  on p1.plan_id = rs1.plan_id
join sys.query_store_runtime_stats_interval as rsi1
  on rsi1.runtime_stats_interval_id = rs1.runtime_stats_interval_id
join sys.query_store_plan as p2
  on q.query_id = p2.query_id
join sys.query_store_runtime_stats as rs2
  on p2.plan_id = rs2.plan_id
join sys.query_store_runtime_stats_interval as rsi2
  on rsi2.runtime_stats_interval_id = rs2.runtime_stats_interval_id
where rsi1.start_time > dateadd(hour, -48, getutcdate())
  and rsi2.start_time > rsi1.start_time
  and p1.plan_id <> p2.plan_id -- comment out to see all regressions (not only those related to plan choice change)
  and rs2.avg_duration > 2 * rs1.avg_duration
order by q.query_id
       , rsi1.start_time
       , rsi2.start_time;