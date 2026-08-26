Get-PSDrive E | ForEach-Object {
    $used = [math]::Round($_.Used/1GB,1)
    $free = [math]::Round($_.Free/1GB,1)
    Write-Host "E盘: Used=$used GB, Free=$free GB"
}
