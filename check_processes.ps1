Get-Process | Where-Object { $_.ProcessName -match 'java|gradle|flutter|dart|android' } | Select-Object Id,ProcessName,Path | Format-Table -AutoSize
