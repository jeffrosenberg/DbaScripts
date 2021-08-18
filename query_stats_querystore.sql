/* Query Store Stats
 * 
 * This script is meant to supplement the Query Store GUI by providing a more flexible and powerful parameterized query.
 *
 * It is based on queries found here:
 * https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store
 * and also modeled after similar queries to analyze the Plan Cache written pre-2016 by Paul Randal.
 *
 * USAGE:
 * All parameters are declared at the top of the script. Just tweak these to modify the script's behavior.
 * There are two sections: 
 * 1. Filtering parameters impact the WHERE clause
 *      Set @startTime and @endTime to bound the query by time. Note that there are two forms of each below, so choose one form and comment out the other
 *      You can filter to specific stored procedures by inserting their object_ids into the @storedProcedures table - otherwise, comment out that INSERT
 * 2. Display parameters impact to TOP/ORDER BY clauses
 *      Note that deciding which metric to sort on is critical to the output of the script. You should pick only one metric.
 * 
 *
 * NOTES:
 * 1. The query is broken into two parts, an initial CTE which gathers the stats, and then a second
        SELECT which tweaks the display of the data and joins back to the query plan / query text DMVs.
 * 2. I tested whether performance would be improved by handling the TOP condition in the CTE,
 *      and then handling display ordering in the SELECT. The difference was negligible.
 *
 * TODO:
 * 1. Once on SQL Server 2017/2019, add sys.query_store_wait_stats!
 */

-- Constants
declare @microsecondsPerSecond decimal(12,2) = 1000000.00; -- decimal to avoid truncating during division
declare @now datetimeoffset = sysdatetimeoffset();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Filtering parameters
--
-- Modify these to filter the queries and/or stored procedures that are analyzed
--declare @startTime datetimeoffset = datetimeoffsetfromparts(year(@now), month(@now), day(@now), 0, 0, 0, 0, datepart(tzoffset, @now) / 60, 0, 2) /* Today midnight */
declare @startTime datetimeoffset = cast('2021-05-05 10:00' as datetime) /* Specify time */ at time zone 'Central Standard Time'
declare @endTime datetimeoffset = null -- leave null to get up to the present
--declare @endTime datetimeoffset = cast('2021-05-04 11:05' as datetime) /* Specify time */ at time zone 'Central Standard Time'
declare @containsText nvarchar(4000) ='promotionrule'; -- Search for text in the query
declare @storedProcedures table ( [object_id] int not null primary key ); -- If desired, add object_id of stored procedures to this list to filter to those procedures
--insert into @storedProcedures ( [object_id] )
--values
--  (object_id(N'dbo.StoredProcedure1'))
--, (object_id(N'dbo.StoredProcedure2'))
--, (object_id(N'dbo.StoredProcedure3'))
--;

-- Display parameters
declare @rowsToSelect int = 100;
declare @orderByExecutionCount bit = 0;
declare @orderByTotalDuration bit = 0;
declare @orderByTotalLogicalReads bit = 0;
declare @orderByTotalPhysicalReads bit = 0;
declare @orderByTotalLogicalWrites bit = 0;
declare @orderByTotalCpuTime bit = 0;
declare @orderByTotalRows bit = 0;
declare @orderByAvgExecutions bit = 0;
declare @orderByAvgDuration bit = 1;
declare @orderByAvgLogicalReads bit = 0;
declare @orderByAvgPhysicalReads bit = 0;
declare @orderByAvgLogicalWrites bit = 0;
declare @orderByAvgCpuTime bit = 0;
declare @orderByAvgRows bit = 0;

with query_stats as (
  select
    q.query_id
  , q.query_text_id
  , p.plan_id
  , q.object_id
  -- Executions
  , count_executions = sum(rs.count_executions)
  , count_executions_safe = -- Avoid divide by zero issues later on
    case 
      when coalesce(sum(rs.count_executions), 0) = 0 then 1 
      else sum(rs.count_executions) 
      end
  , first_execution_time = min(rs.first_execution_time)
  , last_execution_time = max(rs.last_execution_time)
  -- Duration - time in microseconds
  , total_duration_us = sum(rs.avg_duration * rs.count_executions) 
  , min_duration_us = min(rs.min_duration)
  , max_duration_us = max(rs.max_duration)
  -- Reads
  , total_logical_reads = sum(rs.avg_logical_io_reads * rs.count_executions)
  , min_logical_reads = min(rs.min_logical_io_reads)
  , max_logical_reads = max(rs.max_logical_io_reads)
  , total_physical_reads = sum(rs.avg_physical_io_reads * rs.count_executions)
  , min_physical_reads = min(rs.min_physical_io_reads)
  , max_physical_reads = max(rs.max_physical_io_reads)
  -- Writes
  , total_logical_writes = sum(rs.avg_logical_io_writes * rs.count_executions)
  , min_logical_writes = min(rs.min_logical_io_writes)
  , max_logical_writes = max(rs.max_logical_io_writes)
  -- CPU - time in microseconds
  , total_cpu_time_us = sum(rs.avg_cpu_time * rs.count_executions)
  , min_cpu_time_us = min(rs.min_cpu_time)
  , max_cpu_time_us = max(rs.max_cpu_time)
  , total_dop = sum(rs.avg_dop * rs.count_executions) -- This makes no sense on its own, use it to get avg DOP
  , min_dop = min(rs.min_dop)
  , max_dop = max(rs.max_dop)
  -- Memory Grant
  , total_memory_grant = sum(rs.avg_query_max_used_memory * rs.count_executions)
  , min_memory_grant = min(rs.min_query_max_used_memory)
  , max_memory_grant = max(rs.max_query_max_used_memory)
  -- Rows
  , total_rowcount = sum(rs.avg_rowcount * rs.count_executions)
  , min_rowcount = min(rs.min_rowcount)
  , max_rowcount = max(rs.max_rowcount)
  from sys.query_store_query  as q
  join sys.query_store_plan as p
    on q.query_id = p.query_id
  join sys.query_store_runtime_stats as rs
    on p.plan_id = rs.plan_id
  join sys.query_store_runtime_stats_interval as rsi
    on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
  where rsi.start_time >= @startTime
    and (@endTime is null or rsi.end_time <= @endTime)
    and rs.execution_type = 0 -- Successful execution
    -- filter by object_id, such as for a stored procedure
    and (not exists (select * from @storedProcedures)
           or exists (
              select *
              from @storedProcedures sp
              where sp.[object_id] = q.object_id
           ))
    and (@containsText is null
         or exists (
            select * 
            from sys.query_store_query_text as qt
            where qt.query_text_id = q.query_text_id
              and qt.query_sql_text like N'%' + @containsText + N'%'
         ))
  group by q.query_id, q.query_text_id, p.plan_id, q.object_id
)
select top (@rowsToSelect)
  qs.query_id
, query_text = try_cast(N'<?query -' + coalesce(char(13) + char(10) + object_name(qs.object_id) + ' - ', '') + char(13) + char(10) + qt.query_sql_text + char(13) + char(10) + N'-?>' as xml)

-- Executions
, first_execution_time = format(qs.first_execution_time at time zone 'Central Standard Time', 'yyyy-MM-dd HH:mm')
, last_execution_time = format(qs.last_execution_time at time zone 'Central Standard Time', 'yyyy-MM-dd HH:mm')
, qs.count_executions
,   executions_per_minute =
    case when qs.count_executions = 0 then 0
          when coalesce(datediff(minute, qs.first_execution_time, qs.last_execution_time), 0) = 0 then 0
          else cast((qs.count_executions + 0.0) / datediff(minute, qs.first_execution_time, qs.last_execution_time) as numeric(8,2))
          end

-- Duration
, total_duration_s = cast(qs.total_duration_us / @microsecondsPerSecond as decimal(12,2))
, avg_duration_s = cast((qs.total_duration_us / qs.count_executions_safe) / @microsecondsPerSecond as decimal(12,2))
--, min_duration_s = cast(qs.min_duration_us / @microsecondsPerSecond as decimal(12,2))
, max_duration_s = cast(qs.max_duration_us / @microsecondsPerSecond as decimal(12,2))

-- Reads
, qs.total_logical_reads
, avg_logical_reads = cast(qs.total_logical_reads / qs.count_executions_safe as bigint)
--, qs.min_logical_reads
, qs.max_logical_reads

, qs.total_physical_reads
, avg_physical_reads = cast(qs.total_physical_reads / qs.count_executions_safe as bigint)
--, qs.min_physical_reads
, qs.max_physical_reads

-- Writes
, qs.total_logical_writes
, avg_logical_writes = cast(qs.total_logical_writes / qs.count_executions_safe as bigint)
--, qs.min_logical_writes
, qs.max_logical_writes

-- CPU
, total_cpu_time_s = cast(qs.total_cpu_time_us / @microsecondsPerSecond as decimal(12,2))
, avg_cpu_time_s = cast((qs.total_cpu_time_us / qs.count_executions_safe) / @microsecondsPerSecond as decimal(12,2))
--, min_cpu_time_s = cast(qs.min_cpu_time_us / @microsecondsPerSecond as decimal(12,2))
, max_cpu_time_s = cast(qs.max_cpu_time_us / @microsecondsPerSecond as decimal(12,2))

, avg_dop = qs.total_dop / qs.count_executions_safe
, qs.min_dop
, qs.max_dop

-- Memory Grant
, qs.total_memory_grant
, avg_memory_grant = cast(qs.total_memory_grant / qs.count_executions_safe as bigint)
--, qs.min_memory_grant
, qs.max_memory_grant

-- Rows
, qs.total_rowcount
, avg_rowcount = cast(qs.total_rowcount / qs.count_executions_safe as int)
--, qs.min_rowcount
, qs.max_rowcount

, query_plan = try_cast(qp.query_plan as xml)
from query_stats qs 
inner join sys.query_store_query_text qt
  on qt.query_text_id = qs.query_text_id
inner join sys.query_store_plan qp
  on qp.plan_id = qs.plan_id
  
order by case when @orderByExecutionCount = 1 then qs.count_executions else null end desc
       , case when @orderByTotalDuration = 1 then qs.total_duration_us else null end desc
       , case when @orderByTotalLogicalReads = 1 then qs.total_logical_reads else null end desc
       , case when @orderByTotalPhysicalReads = 1 then qs.total_physical_reads else null end desc
       , case when @orderByTotalLogicalWrites = 1 then qs.total_logical_writes else null end desc
       , case when @orderByTotalCpuTime = 1 then qs.total_cpu_time_us else null end desc
       , case when @orderByTotalRows = 1 then qs.total_rowcount else null end desc
	   , case when @orderByAvgExecutions = 1 then 
											 case when qs.count_executions = 0 then 0
												  when coalesce(datediff(minute, qs.first_execution_time, qs.last_execution_time), 0) = 0 then 0
												  else cast((qs.count_executions + 0.0) / datediff(minute, qs.first_execution_time, qs.last_execution_time) as numeric(8,2))
												  end
											 else null end desc
       , case when @orderByAvgDuration = 1 then (qs.total_duration_us / qs.count_executions_safe) else null end
       , case when @orderByAvgLogicalReads = 1 then (qs.total_logical_reads / qs.count_executions_safe) else null end desc
       , case when @orderByAvgPhysicalReads = 1 then (qs.total_physical_reads / qs.count_executions_safe) else null end desc
       , case when @orderByAvgLogicalWrites = 1 then (qs.total_logical_writes / qs.count_executions_safe) else null end
       , case when @orderByAvgCpuTime = 1 then (qs.total_cpu_time_us / qs.count_executions_safe) else null end desc
       , case when @orderByAvgRows = 1 then (qs.total_rowcount / qs.count_executions_safe) else null end
;