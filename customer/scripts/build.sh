#!/bin/bash

# Build script with environment variables
# Usage: ./scripts/build.sh [debug|release]

BUILD_MODE=${1:-debug}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment variables from .env file if it exists
if [ -f "$PROJECT_ROOT/.env" ]; then
    echo "Loading environment variables from .env"
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi

# Validate required environment variables
if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    echo "❌ Error: GOOGLE_MAPS_API_KEY is not set"
    echo "Please set it in .env file or as environment variable"
    exit 1
fi

echo "✅ Building with environment variables:"
echo "📍 Google Maps API Key: ${GOOGLE_MAPS_API_KEY:0:10}..."
echo "🌐 API Base URL: $API_BASE_URL"
echo "🔌 Socket URL: $SOCKET_URL"

# Build the app with environment variables
cd "$PROJECT_ROOT"

case $BUILD_MODE in
    "release")
        echo "🚀 Building release version..."
        flutter build apk --release --dart-define=GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY" \
                                  --dart-define=API_BASE_URL="$API_BASE_URL" \
                                  --dart-define=SOCKET_URL="$SOCKET_URL"
        ;;
    "debug"|*)
        echo "🔧 Building debug version..."
        flutter run --dart-define=GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY" \
                   --dart-define=API_BASE_URL="$API_BASE_URL" \
                   --dart-define=SOCKET_URL="$SOCKET_URL"
        ;;
esac