
DECLARE @RowsPerIteration AS int = 5000; --Rows to commit at a time
DECLARE @MaxIterations AS int = 50000; --Provide an escape valve if we only want to execute a few times
DECLARE @CurrentIteration AS int = 1; --Track how many iterations have been processed
DECLARE @inserted AS int, @deleted AS int; --Count records inserted and deleted for each iteration

-------------------------------------------------------------------------------
--Create temporary tables for storing IDs
IF OBJECT_ID(N'tempdb..#IdTracker') IS NOT NULL
	DROP TABLE #IdTracker;
IF OBJECT_ID(N'tempdb..#IdTracker_Temp') IS NOT NULL
	DROP TABLE #IdTracker_Temp;

CREATE TABLE #IdTracker ( --"Outer" table (holds all IDs to move)
	Id int NOT NULL,
	Processed bit NOT NULL DEFAULT 0,
	CONSTRAINT PK_IdTracker PRIMARY KEY CLUSTERED(Id)
)
CREATE TABLE #IdTracker_Temp ( --"Inner" table (holds current chunk of IDs)
	Id int NOT NULL,
	CONSTRAINT PK_IdTracker_Temp PRIMARY KEY CLUSTERED(Id)
)

--=============================================================================
--Define the source recordset to be processed here
--=============================================================================
INSERT INTO #IdTracker (Id) --Load all IDs at the outset, so we can load them only once
SELECT MEMBERCOMMUNICATIONID
FROM Amtrak.archive.MEMBERCOMMUNICATION WITH (NOLOCK) --Reduce blocking while reading in the list of IDs
WHERE CreateDate >= DATEADD(year, -2, CURRENT_TIMESTAMP)

CREATE NONCLUSTERED INDEX [IX_IdTracker] 
ON #IdTracker([Processed] ASC) INCLUDE ([Id]) 
-------------------------------------------------------------------------------

BEGIN TRY
  --Loop over IDs in chunks and move data
  WHILE EXISTS(SELECT * FROM #IdTracker WHERE Processed = 0) AND @CurrentIteration <= @MaxIterations
  BEGIN 
	  BEGIN TRAN;
		  TRUNCATE TABLE #IdTracker_Temp;
		
      --Read the next chunk into the inner table
		  INSERT INTO #IdTracker_Temp (Id) 
		  SELECT TOP (@RowsPerIteration) Id
		  FROM #IdTracker
		  WHERE Processed = 0;

      --Read from the source and write into the destination

      --=============================================================================
      --Define the destination insert operation here
      --=============================================================================
      INSERT INTO Amtrak.dbo.MEMBERCOMMUNICATION 
      ( MEMBERCOMMUNICATIONID, COMMUNICATIONID, MEMBERID, STATUSID,
        SENDDATEID, CREATEDATE, CREATEUSERID, UPDATEDATE, UPDATEUSERID, DELETED,
        DELETEDATE, DELETEUSERID, VERSION, CUSTSPECBELOW, PROMOMEMBERCOMMUNICATIONID,
        SENDDEFINITION, RESENT )
      SELECT 
        MEMBERCOMMUNICATIONID, COMMUNICATIONID, MEMBERID, STATUSID,
        SENDDATEID, CREATEDATE, CREATEUSERID, UPDATEDATE, UPDATEUSERID, DELETED,
        DELETEDATE, DELETEUSERID, VERSION, CUSTSPECBELOW, PROMOMEMBERCOMMUNICATIONID,
        SENDDEFINITION, RESENT
      FROM Amtrak.archive.MEMBERCOMMUNICATION AS a WITH (NOLOCK)
      INNER JOIN #IdTracker_Temp AS i
        ON i.Id = a.MEMBERCOMMUNICATIONID
      SET @inserted = @@ROWCOUNT; --Record the number of inserts
    
      --Delete the processed records from the source
      DELETE a
      FROM Amtrak.archive.MEMBERCOMMUNICATION AS a
      INNER JOIN #IdTracker_Temp AS i
        ON i.Id = a.MEMBERCOMMUNICATIONID
      SET @deleted = @@ROWCOUNT; --Record the number of deletes

      --Make sure the number of deletes from the source matches inserts into the destination
      IF @inserted <> @deleted
        THROW 50001, 'The number of records inserted and deleted did not match!', 1; --If not, fail and roll back
      ELSE
      BEGIN
        COMMIT;
		    PRINT CAST(@inserted AS varchar(10)) + ' records committed: ' + CONVERT(varchar(100), GETDATE(), 114);

        --Update this chunk as Processed in the outer table
		    UPDATE id
		    SET id.Processed = 1
		    FROM #IdTracker AS id
		    INNER JOIN #IdTracker_Temp AS tmp
			    ON tmp.Id = id.Id;
      END

      SET @CurrentIteration += 1;
  END
END TRY

BEGIN CATCH
  IF @@TRANCOUNT > 0
  BEGIN
    ROLLBACK;
    PRINT 'An error occurred. Rolling back the most recent set and exiting...';
  END

  ;THROW;
END CATCH