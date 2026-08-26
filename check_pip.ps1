$src = 'C:\Users\10295\AppData\Local\pip\cache'
$dst = 'E:\DevCache\pip'
if (Test-Path $src) {
    $srcSize = (Get-ChildItem $src -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    Write-Host "Source: $([math]::Round($srcSize/1MB,1)) MB"
} else {
    Write-Host "Source: not exists"
}
if (Test-Path $dst) {
    $dstSize = (Get-ChildItem $dst -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    Write-Host "Destination: $([math]::Round($dstSize/1MB,1)) MB"
} else {
    Write-Host "Destination: not exists"
}
