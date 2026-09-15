Write-Host "Cleaning NVIDIA caches..."
Remove-Item -Path "C:\ProgramData\NVIDIA" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\ProgramData\NVIDIA Corporation" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "NVIDIA caches cleaned"
