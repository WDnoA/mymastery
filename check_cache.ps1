$dirs = @(
    'C:\Users\10295\AppData\Local\Pub\Cache',
    'C:\Users\10295\.gradle\caches',
    'C:\Users\10295\.gradle\wrapper',
    'C:\Users\10295\AppData\Local\Trae',
    'C:\Users\10295\AppData\Roaming\Trae',
    'C:\Users\10295\.trae-cn',
    'C:\Users\10295\AppData\Local\Android',
    'C:\Users\10295\AppData\Local\pip\cache',
    'C:\Users\10295\AppData\Local\npm-cache',
    'C:\Users\10295\.nuget'
)
foreach ($p in $dirs) {
    if (Test-Path $p) {
        $s = (Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        $mb = [math]::Round($s / 1MB, 1)
        Write-Host "$mb MB  $p"
    }
}
