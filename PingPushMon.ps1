$urlstring = "http://pshmn.com/WYZnyP"
#Invoke-RestMethod -Uri $urlstring -Method Get #PowerShell 3.0+ only!
(New-Object System.Net.WebClient).DownloadString($urlstring)