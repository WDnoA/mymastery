$src = 'C:\Users\10295\.gradle\caches'
$dst = 'E:\DevCache\gradle\caches'
$srcSize = (Get-ChildItem $src -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$dstSize = (Get-ChildItem $dst -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
Write-Host "Source remaining: $([math]::Round($srcSize/1MB,1)) MB"
Write-Host "Destination: $([math]::Round($dstSize/1MB,1)) MB"
