# 清理 NVIDIA 缓存
Write-Host "Cleaning NVIDIA caches..."

# 1. DXCache (DirectX 着色器缓存)
$dxCache = 'C:\Users\10295\AppData\Local\NVIDIA\DXCache'
if (Test-Path $dxCache) {
    Remove-Item -Path "$dxCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Cleaned DXCache"
}

# 2. NGX (DLSS 缓存)
$ngx = 'C:\ProgramData\NVIDIA\NGX'
if (Test-Path $ngx) {
    Remove-Item -Path "$ngx\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Cleaned NGX"
}

# 3. NVIDIA app 缓存
$nvApp = 'C:\ProgramData\NVIDIA Corporation\NVIDIA app'
if (Test-Path $nvApp) {
    Remove-Item -Path "$nvApp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Cleaned NVIDIA app"
}

# 4. Nsight 缓存
$nsight = 'C:\ProgramData\NVIDIA Corporation\Nsight'
if (Test-Path $nsight) {
    Remove-Item -Path "$nsight\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Cleaned Nsight"
}

Write-Host "`nCleanup completed!"
