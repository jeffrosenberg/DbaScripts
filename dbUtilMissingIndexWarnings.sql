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

-- Modified from https://www.sqlskills.com/blogs/jonathan/digging-into-the-sql-plan-cache-finding-missing-indexes/
-- to work with the DBUtilities database and the logs.QueryPlans table

IF OBJECT_ID(N'tempdb..#MissingIndexInfo') IS NOT NULL DROP TABLE #MissingIndexInfo;

DECLARE @planDate AS date = '2017-07-06'; -- Date of last user seek from missing indexes
DECLARE @table varchar(128) = 'ACCRUALSTAGING'; -- Pass in a table name to filter on a specific table

WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT query_plan,
       n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text,
       n.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') AS impact,
       DB_ID(REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'),'[',''),']','')) AS database_id,
       OBJECT_ID(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' +
           n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' +
           n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')) AS OBJECT_ID,
       REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'),'[',''),']','') AS [database],
       REPLACE(REPLACE(n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)'),'[',''),']','') AS [schema],
       REPLACE(REPLACE(n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)'),'[',''),']','') AS [table],
       (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
           FROM n.nodes('//ColumnGroup') AS t(cg)
           CROSS APPLY cg.nodes('Column') AS r(c)
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'EQUALITY'
           FOR  XML PATH('')
       ) AS equality_columns,
        (  SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
           FROM n.nodes('//ColumnGroup') AS t(cg)
           CROSS APPLY cg.nodes('Column') AS r(c)
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INEQUALITY'
           FOR  XML PATH('')
       ) AS inequality_columns,
       (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
           FROM n.nodes('//ColumnGroup') AS t(cg)
           CROSS APPLY cg.nodes('Column') AS r(c)
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INCLUDE'
           FOR  XML PATH('')
       ) AS include_columns
INTO #MissingIndexInfo
FROM
(
   SELECT qp.QueryPlan
   FROM DBUtilities.logs.QueryPlans AS qp
   WHERE qp.PlanDate = @planDate 
     AND qp.QueryPlan.exist('//MissingIndex')=1
) AS tab (query_plan)
CROSS APPLY query_plan.nodes('//StmtSimple') AS q(n)
WHERE n.exist('QueryPlan/MissingIndexes') = 1;
 
-- Trim trailing comma from lists
UPDATE #MissingIndexInfo
SET equality_columns = LEFT(equality_columns,LEN(equality_columns)-1),
   inequality_columns = LEFT(inequality_columns,LEN(inequality_columns)-1),
   include_columns = LEFT(include_columns,LEN(include_columns)-1);
 
SELECT *
FROM #MissingIndexInfo
WHERE @table IS NULL OR [table] = @table; -- TODO: Get this into tab subquery above instead (using XPATH)
 
--DROP TABLE #MissingIndexInfo;