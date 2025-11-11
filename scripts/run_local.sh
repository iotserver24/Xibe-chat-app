#!/bin/bash
# Bash script to run Flutter app with .env file
# Usage: ./scripts/run_local.sh [platform] [device]
# Example: ./scripts/run_local.sh windows
# Example: ./scripts/run_local.sh android

PLATFORM=${1:-windows}
DEVICE=${2:-""}

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "📝 Copy .env.example to .env and fill in your values"
    exit 1
fi

# Read .env file
echo "📖 Loading .env file..."
export $(grep -v '^#' .env | xargs)

# Build dart-define flags
DART_DEFINES=()
DART_DEFINES+=("--dart-define=E2B_BACKEND_URL=${E2B_BACKEND_URL}")

# Add platform-specific Firebase config
case "$PLATFORM" in
    android)
        DART_DEFINES+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_ANDROID_API_KEY}")
        DART_DEFINES+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_ANDROID_APP_ID}")
        ;;
    ios)
        DART_DEFINES+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_IOS_API_KEY}")
        DART_DEFINES+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_IOS_APP_ID}")
        DART_DEFINES+=("--dart-define=FIREBASE_IOS_BUNDLE_ID=${FIREBASE_IOS_BUNDLE_ID}")
        ;;
    windows)
        DART_DEFINES+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_WINDOWS_API_KEY}")
        DART_DEFINES+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_WINDOWS_APP_ID}")
        ;;
    macos)
        DART_DEFINES+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_MACOS_API_KEY}")
        DART_DEFINES+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_MACOS_APP_ID}")
        DART_DEFINES+=("--dart-define=FIREBASE_MACOS_BUNDLE_ID=${FIREBASE_MACOS_BUNDLE_ID}")
        ;;
    linux)
        DART_DEFINES+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_LINUX_API_KEY}")
        DART_DEFINES+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_LINUX_APP_ID}")
        ;;
    web)
        DART_DEFINES+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_WEB_API_KEY}")
        DART_DEFINES+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_WEB_APP_ID}")
        ;;
    *)
        # Use web config as default
        DART_DEFINES+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_API_KEY}")
        DART_DEFINES+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_APP_ID}")
        ;;
esac

# Add shared Firebase variables
DART_DEFINES+=("--dart-define=FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}")
DART_DEFINES+=("--dart-define=FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN}")
DART_DEFINES+=("--dart-define=FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET}")
DART_DEFINES+=("--dart-define=FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID}")

# Build Flutter command
if [ -n "$DEVICE" ]; then
    FLUTTER_CMD="flutter run -d $DEVICE"
else
    FLUTTER_CMD="flutter run -d $PLATFORM"
fi

FULL_CMD="$FLUTTER_CMD ${DART_DEFINES[*]}"

echo "🚀 Running Flutter app..."
echo "📱 Platform: $PLATFORM"
echo "🔧 Command: $FULL_CMD"
echo ""

# Execute Flutter command
eval $FULL_CMD

