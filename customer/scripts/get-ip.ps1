# Script to find your computer's IP address for mobile device testing
# Usage: .\scripts\get-ip.ps1

Write-Host "Finding your computer's IP addresses for mobile device testing..." -ForegroundColor Cyan
Write-Host ""

# Get network adapters that are up and have an IP address
$adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notmatch "^127\." -and 
    $_.IPAddress -notmatch "^169\.254\." -and
    $_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual"
}

Write-Host "Available IP addresses:" -ForegroundColor Green
foreach ($adapter in $adapters) {
    $interfaceAlias = (Get-NetAdapter -InterfaceIndex $adapter.InterfaceIndex).Name
    $ipAddress = $adapter.IPAddress
    
    # Determine network type
    if ($ipAddress -match "^192\.168\.") {
        $networkType = "Home/Private Network"
    } elseif ($ipAddress -match "^10\.") {
        $networkType = "Office/Corporate Network" 
    } elseif ($ipAddress -match "^172\.(1[6-9]|2[0-9]|3[0-1])\.") {
        $networkType = "Private Network"
    } else {
        $networkType = "Other Network"
    }
    
    Write-Host "  $ipAddress" -ForegroundColor Yellow -NoNewline
    Write-Host " ($interfaceAlias - $networkType)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "To use with your mobile device:" -ForegroundColor Cyan
Write-Host "1. Update your .env file with one of the IPs above:" -ForegroundColor White
Write-Host "   API_BASE_URL=http://YOUR_IP:3000/api/v1" -ForegroundColor Gray
Write-Host "   SOCKET_URL=http://YOUR_IP:3000" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Make sure your mobile device is on the same network" -ForegroundColor White
Write-Host "3. Ensure Windows Firewall allows Node.js (port 3000)" -ForegroundColor White
Write-Host ""

# Show current .env configuration if it exists
$envFile = Join-Path (Split-Path -Parent $PSScriptRoot) ".env"
if (Test-Path $envFile) {
    Write-Host "Current .env configuration:" -ForegroundColor Cyan
    $envContent = Get-Content $envFile | Where-Object { $_ -match "API_BASE_URL|SOCKET_URL" }
    foreach ($line in $envContent) {
        if ($line -match "^(API_BASE_URL|SOCKET_URL)=(.+)") {
            Write-Host "  $($matches[1]): " -ForegroundColor Yellow -NoNewline
            Write-Host "$($matches[2])" -ForegroundColor White
        }
    }
} else {
    Write-Host "WARNING: No .env file found. Copy .env.example to .env first!" -ForegroundColor Red
}

Write-Host ""