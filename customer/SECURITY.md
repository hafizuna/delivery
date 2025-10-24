# 🔐 Security Configuration

This document explains how to securely manage API keys and sensitive configuration in the Flutter app.

## 📋 Overview

API keys and sensitive configuration are managed through:
1. **Environment Variables** (Recommended for production)
2. **Local .env File** (Development only)
3. **Build-time Configuration** (Flutter --dart-define)

## 🔑 API Key Configuration

### Google Maps API Key

The Google Maps API key is used for:
- Live tracking with navigation routes
- Location services
- Map display

### Setup Methods

#### Method 1: Environment Variables (Production) ✅
```bash
# Set system environment variable
export GOOGLE_MAPS_API_KEY="your_actual_api_key"

# Or in Windows
set GOOGLE_MAPS_API_KEY=your_actual_api_key
```

#### Method 2: .env File (Development) ✅
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your actual values:
   ```env
   GOOGLE_MAPS_API_KEY=your_actual_api_key
   API_BASE_URL=http://localhost:3001
   SOCKET_URL=http://localhost:3001
   ```

#### Method 3: Build-time Configuration ✅
```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_actual_api_key
```

## 🚀 Running the App

### Development
```bash
# Using PowerShell script (Windows)
.\scripts\build.ps1 debug

# Using bash script (Linux/Mac)
./scripts/build.sh debug

# Manual with environment variables
flutter run --dart-define=GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY"
```

### Production Build
```bash
# Using PowerShell script (Windows)
.\scripts\build.ps1 release

# Using bash script (Linux/Mac)
./scripts/build.sh release

# Manual
flutter build apk --release --dart-define=GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY"
```

## 🛡️ Security Best Practices

### ✅ DO:
- Use environment variables for production
- Set API key restrictions in Google Cloud Console
- Keep `.env` file in `.gitignore`
- Use different API keys for different environments
- Monitor API usage and set quotas
- Rotate API keys periodically

### ❌ DON'T:
- Commit API keys to version control
- Use production API keys in development
- Share API keys in plain text
- Hard-code sensitive values in source code
- Use unrestricted API keys

## 📱 Platform Configuration

### Android
API key is configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="from_environment_or_fallback" />
```

### iOS  
API key is configured in `ios/Runner/AppDelegate.swift`:
```swift
let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] ?? "fallback_key"
GMSServices.provideAPIKey(apiKey)
```

## 🔍 Configuration Validation

The app validates configuration on startup:
- ✅ Checks if API key is present
- ✅ Validates key format
- ✅ Logs configuration status (without exposing keys)
- ❌ Throws error if required config missing

## 🆘 Troubleshooting

### API Key Not Found Error
1. Check if `.env` file exists and contains the key
2. Verify environment variable is set
3. Use build scripts with `--dart-define`

### Maps Not Loading
1. Check API key restrictions in Google Cloud Console
2. Verify billing is enabled
3. Check API quotas and usage

### Build Issues
1. Clean Flutter build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Verify all required environment variables are set

## 📞 Support

If you encounter issues with security configuration, check:
1. This SECURITY.md file
2. Build logs for configuration errors
3. Google Cloud Console for API restrictions