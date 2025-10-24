# PowerShell Build script with environment variables
# Usage: .\scripts\build.ps1 [debug|release]

param(
    [string]$BuildMode = "debug"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent $ScriptDir

# Load environment variables from .env file if it exists
$EnvFile = Join-Path $ProjectRoot ".env"
if (Test-Path $EnvFile) {
    Write-Host "Loading environment variables from .env" -ForegroundColor Green
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
}

# Get environment variables
$GoogleMapsApiKey = $env:GOOGLE_MAPS_API_KEY
$ApiBaseUrl = $env:API_BASE_URL
$SocketUrl = $env:SOCKET_URL

# Validate required environment variables
if ([string]::IsNullOrEmpty($GoogleMapsApiKey)) {
    Write-Host "❌ Error: GOOGLE_MAPS_API_KEY is not set" -ForegroundColor Red
    Write-Host "Please set it in .env file or as environment variable" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Building with environment variables:" -ForegroundColor Green
Write-Host "📍 Google Maps API Key: $($GoogleMapsApiKey.Substring(0, [Math]::Min(10, $GoogleMapsApiKey.Length)))..." -ForegroundColor Yellow
Write-Host "🌐 API Base URL: $ApiBaseUrl" -ForegroundColor Yellow
Write-Host "🔌 Socket URL: $SocketUrl" -ForegroundColor Yellow

# Change to project directory
Set-Location $ProjectRoot

# Build the app with environment variables
switch ($BuildMode.ToLower()) {
    "release" {
        Write-Host "🚀 Building release version..." -ForegroundColor Cyan
        flutter build apk --release `
            --dart-define=GOOGLE_MAPS_API_KEY="$GoogleMapsApiKey" `
            --dart-define=API_BASE_URL="$ApiBaseUrl" `
            --dart-define=SOCKET_URL="$SocketUrl"
    }
    default {
        Write-Host "🔧 Running debug version..." -ForegroundColor Cyan
        flutter run `
            --dart-define=GOOGLE_MAPS_API_KEY="$GoogleMapsApiKey" `
            --dart-define=API_BASE_URL="$ApiBaseUrl" `
            --dart-define=SOCKET_URL="$SocketUrl"
    }
}