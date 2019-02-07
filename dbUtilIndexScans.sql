-- Don't allow queries to be executed if this is the primary replica
IF EXISTS (
  SELECT *
  FROM sys.dm_hadr_availability_replica_states s
  INNER JOIN sys.availability_groups AS ag ON ag.group_id = s.group_id AND s.is_local = 1
  INNER JOIN sys.dm_hadr_database_replica_states AS ds ON ds.group_id = ag.group_id AND ds.is_local = 1
  WHERE ds.is_primary_replica = 1
) 
BEGIN
  RAISERROR('At least one database is the primary replica on this server! Setting NOEXEC on...', 15, 1)
  SET NOEXEC ON;
  -- SET NOEXEC OFF -- Putting this here for easy access after NOEXEC gets turned on
END /*
ELSE
BEGIN
  SELECT [Server] = @@SERVERNAME, [Availability Group] = ag.name, [Role] = s.Role_Desc
  FROM sys.dm_hadr_availability_replica_states s
  INNER JOIN sys.availability_groups AS ag ON ag.group_id = s.group_id
  WHERE s.is_local = 1
END
*/

USE DBUtilities
GO

DECLARE @planDate AS date = (SELECT MAX(PlanDate) FROM logs.QueryPlans);

IF OBJECT_ID(N'tempdb.dbo.HGP_3850_IndexScanStats_20170713') IS NOT NULL DROP TABLE tempdb.dbo.HGP_3850_IndexScanStats_20170713;
IF OBJECT_ID(N'tempdb.dbo.HGP_3850_IndexScanSummary_20170713') IS NOT NULL DROP TABLE tempdb.dbo.HGP_3850_IndexScanSummary_20170713;

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
, targetQueryPlans AS (
   SELECT QueryPlan, PlanHandle, PlanDate
   FROM DBUtilities.logs.QueryPlans
   WHERE PlanDate = @planDate 
     AND QueryPlan IS NOT NULL
     AND QueryPlan.exist('//RelOp[@LogicalOp="Index Scan"
		                              or @LogicalOp="Clustered Index Scan"
		                              or @LogicalOp="Table Scan"]')=1
)
SELECT tqp.PlanHandle
     , tqp.QueryPlan
     , tqp.PlanDate
     , st.[Text]
     , q.n.query('.') AS RelOp
     , q.n.value('(@NodeId)[1]', 'varchar(255)') AS NodeId
     , q.n.value('(@LogicalOp)[1]', 'varchar(255)') AS LogicalOp
     , q.n.value('(@EstimateRows)[1]', 'float') AS EstimatedRows
     , q.n.value('(@EstimateIO)[1]', 'float') AS EstimatedIO
     , q.n.value('(@EstimateCPU)[1]', 'float') AS EstimatedCPU
     , q.n.value('(@EstimatedTotalSubtreeCost)[1]', 'float') AS EstimatedTotalSubtreeCost
     , q.n.value('(IndexScan/Object[1]/@Database)[1]', 'varchar(255)') AS [Database]
     , q.n.value('(IndexScan/Object[1]/@Schema)[1]', 'varchar(255)') AS [Schema]
     , q.n.value('(IndexScan/Object[1]/@Table)[1]', 'varchar(255)') AS [Table]
     , q.n.value('(IndexScan/Object[1]/@Index)[1]', 'varchar(255)') AS [Index]
     , q.n.value('(IndexScan/Object[1]/@IndexKind)[1]', 'varchar(255)') AS [IndexKind]
     , qs.TotalLogicalReads
     , AvgLogicalReads = qs.TotalLogicalReads / qs.ExecutionCount
     , qs.ExecutionCount
     , MinutesInProcCache = NULLIF(DATEDIFF(mi, qs.CreationTime, qs.LastExecutionTime), 0)
INTO tempdb.dbo.HGP_3850_IndexScanStats_20170713
FROM targetQueryPlans AS tqp
CROSS APPLY tqp.QueryPlan.nodes('//RelOp[@LogicalOp="Index Scan"
		                                  or @LogicalOp="Clustered Index Scan"
		                                  or @LogicalOp="Table Scan"]') AS q(n)
LEFT JOIN logs.QueryStats AS qs
  ON qs.PlanHandle = tqp.PlanHandle
    AND CAST(qs.CreateDate AS date) = tqp.PlanDate
LEFT JOIN logs.SqlText AS st
  ON st.PlanHandle = tqp.PlanHandle
    AND st.PlanDate = tqp.PlanDate
WHERE q.n.value('(IndexScan/Object[1]/@Database)[1]', 'varchar(255)') = '[Hyatt]'
  AND q.n.value('(IndexScan/Object[1]/@Schema)[1]', 'varchar(255)') IN ('[dbo]','[Hyatt]')
  AND (q.n.value('(@EstimateRows)[1]', 'float') >= 100 -- At least 100 rows, or 1000 logical reads in the full query stats
        OR qs.TotalLogicalReads / qs.ExecutionCount >= 1000);

SELECT iss.[Schema]
     , iss.[Table]
     , iss.[Index]
     , iss.IndexKind
     , Plans = COUNT(*)
     , Executions = SUM(iss.ExecutionCount)
     , ExecutionsPerMinute = (SUM(iss.ExecutionCount) + 0.00) / SUM(iss.MinutesInProcCache)
INTO tempdb.dbo.HGP_3850_IndexScanSummary_20170713
FROM tempdb.dbo.HGP_3850_IndexScanStats_20170713 AS iss
GROUP BY iss.[Schema], iss.[Table], iss.[Index], iss.IndexKind;

RETURN;

-- Import to primary, then go back to querying secondary

SELECT iss.[Schema]
     , iss.[Table]
     , iss.[Index]
     , iss.IndexKind
     , iss.Plans
     , TotalExecutions = iss.Executions
     , TotalExecutionsPerMinute = iss.ExecutionsPerMinute
FROM DBUtilities.logs.HGP_3850_IndexScanSummary_20170713 AS iss
ORDER BY ExecutionsPerMinute DESC;

WITH distinctStats AS (
  SELECT DISTINCT
         PlanHandle
       , PlanDate
       , NodeId
       , LogicalOp
       , [Schema]
       , [Table]
       , [Index]
       , IndexKind
  FROM DBUtilities.logs.HGP_3850_IndexScanStats_20170713
)
SELECT ds.PlanHandle
     , iss.QueryPlan
     , QueryText = iss.[Text]
     , ds.[Schema]
     , ds.[Table]
     , ds.[Index]
     , ds.IndexKind
     , ds.LogicalOp
     , ds.NodeId
     , iss.EstimatedRows
     , iss.EstimatedIO
     , iss.EstimatedCPU
     , iss.EstimatedTotalSubtreeCost
     , iss.TotalLogicalReads
     , iss.AvgLogicalReads
     , iss.ExecutionCount
     , iss.MinutesInProcCache
     , IndexPlans = sm.Plans
     , IndexTotalExecutions = sm.Executions
     , IndexTotalExecutionsPerMinute = sm.ExecutionsPerMinute
FROM distinctStats AS ds
CROSS APPLY (
  SELECT TOP 1 s.EstimatedRows, s.EstimatedIO, s.EstimatedCPU, s.EstimatedTotalSubtreeCost
              , s.TotalLogicalReads, s.AvgLogicalReads, s.ExecutionCount, s.MinutesInProcCache
              , s.QueryPlan, s.[Text]
  FROM DBUtilities.logs.HGP_3850_IndexScanStats_20170713 AS s
  WHERE s.PlanHandle = ds.PlanHandle
    AND s.PlanDate = ds.PlanDate
    AND s.[Index] = ds.[Index]
  ORDER BY s.EstimatedTotalSubtreeCost DESC
) AS iss
INNER JOIN DBUtilities.logs.HGP_3850_IndexScanSummary_20170713 AS sm
  ON sm.[Schema] = ds.[Schema]
    AND sm.[Table] = ds.[Table]
    AND sm.[Index] = ds.[Index]
    AND sm.IndexKind = ds.IndexKind  
ORDER BY sm.ExecutionsPerMinute DESC
       , iss.TotalLogicalReads DESC
       , iss.EstimatedRows DESC;