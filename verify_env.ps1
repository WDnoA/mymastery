Write-Host "GRADLE_USER_HOME: $([System.Environment]::GetEnvironmentVariable('GRADLE_USER_HOME', 'User'))"
Write-Host "PUB_CACHE: $([System.Environment]::GetEnvironmentVariable('PUB_CACHE', 'User'))"
Write-Host "PIP_CACHE_DIR: $([System.Environment]::GetEnvironmentVariable('PIP_CACHE_DIR', 'User'))"
Write-Host "npm cache: $(npm config get cache)"
