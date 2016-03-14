SELECT SCH.name + '.' + TBL.name AS TableName 
FROM sys.tables AS TBL 
     INNER JOIN sys.schemas AS SCH 
         ON TBL.schema_id = SCH.schema_id 
     INNER JOIN sys.indexes AS IDX 
         ON TBL.object_id = IDX.object_id 
            AND IDX.type = 0 -- = Heap 
ORDER BY TableName