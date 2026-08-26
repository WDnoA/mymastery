Get-Process | Where-Object { $_.ProcessName -match 'dart|java' } | Stop-Process -Force
