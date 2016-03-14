#Alter these variables to retrieve specific backups
$serverFolder = 'AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01';
$dbName = "Amtrak";
$restoreType = "FULL"; # FULL / DIFF / LOG

#Figure out if this is a DATABASE (full/diff) or LOG restore
$operationType = switch ($restoreType) { "LOG" { "LOG" } default { "DATABASE" }}

#region Preset strings
$basePath = '\\commvault\SQLDump\'
$restoreStmt_Db = "RESTORE FILELISTONLY`n--$operationType $dbName`nFROM ";
$restoreStmtOptions_Db = "WITH NORECOVERY,`n  CHECKSUM, STOP_ON_ERROR,`n  STATS = 5";
$restoreStmt_Log = "RESTORE $operationType $dbName`nFROM ";
$restoreStmtOptions_Log = "WITH NORECOVERY, STOP_ON_ERROR";
#endregion

#region Initialize variables
$path = "$basePath\$serverFolder\$dbName\$restoreType"
$dateString = (Get-Date).ToString("yyyyMMdd");
$bakFiles = $null;
$restoreStmt = "";
#$restoreStmtOptions = "";
$countIterations = 0;
#endregion

#A few actions depend on whether this is a DATABASE (full/diff) or LOG restore
if ($operationType -eq "LOG") {
    $restoreStmt = "";
    $bakFiles = Get-ChildItem -Path $path -Filter "*$dateString*"; #Get only today's logs
}
else {
    $restoreStmt = $restoreStmt_Db;
    $bakFiles = Get-ChildItem -Path $path; #The most recent backup will be the only files in the folder
}

foreach ($file in ($bakFiles | Sort-Object -Property "LastWriteTime")) {
    if ($operationType -eq "DATABASE") {
        if ($countIterations -gt 0) {
            $restoreStmt += "`n, ";
        }
        $restoreStmt += "DISK = '$($file.FullName)'";
        $countIterations += 1;
        if ($countIterations -eq $bakFiles.Count) {
            $restoreStmt += "`n$restoreStmtOptions_Db";
        }
    }
    elseif ($operationType -eq "LOG") {
        $restoreStmt += $restoreStmt_Log;
        $restoreStmt += "DISK = '$($file.FullName)'";
        $restoreStmt += "`n$restoreStmtOptions_Log";
        $restoreStmt += ";`n";
    }

}

Clear-Host;
Write-Host $restoreStmt;