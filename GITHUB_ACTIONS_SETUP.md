# GitHub Actions Setup - E2B Backend URL

## Overview

The Flutter app uses the E2B backend URL from environment variables during build. This allows you to configure different backend URLs for different environments.

## Setting E2B_BACKEND_URL in GitHub Actions

### Option 1: Using GitHub Repository Variables (Recommended)

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click on the **Variables** tab
4. Click **New repository variable**
5. Add:
   - **Name**: `E2B_BACKEND_URL`
   - **Value**: `https://e2b.n92dev.us.kg` (or your custom backend URL)
6. Click **Add variable**

The workflow will automatically use this variable during builds.

### Option 2: Using Secrets (If you want it hidden)

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click on the **Secrets** tab
4. Click **New repository secret**
5. Add:
   - **Name**: `E2B_BACKEND_URL`
   - **Value**: `https://e2b.n92dev.us.kg`
6. Click **Add secret**

Then update the workflow file to use `secrets.E2B_BACKEND_URL` instead of `vars.E2B_BACKEND_URL`.

## Default Behavior

If `E2B_BACKEND_URL` is not set in GitHub variables or secrets, the workflow defaults to:
- `https://e2b.n92dev.us.kg`

This is also the default hardcoded in the Flutter app code.

## Local Development

For local development, you can:

1. **Use the default** (no configuration needed):
   - The app will use `https://e2b.n92dev.us.kg` automatically

2. **Override in Settings**:
   - Go to Settings in the app
   - Enter a custom backend URL in "E2B Backend URL" field
   - Save

3. **Build with custom URL**:
   ```bash
   flutter build apk --release --dart-define=E2B_BACKEND_URL=https://your-backend-url.com
   ```

## How It Works

1. **Build time**: The `--dart-define=E2B_BACKEND_URL=...` flag sets the `String.fromEnvironment('E2B_BACKEND_URL')` value
2. **Runtime**: The app checks Settings for a user-configured URL first
3. **Fallback**: If no user URL is set, it uses the build-time environment variable
4. **Final fallback**: If no env var is set, uses the hardcoded default: `https://e2b.n92dev.us.kg`

## Testing

After setting up the variable, test a build:

```bash
# The workflow will automatically use the variable
# Or test locally:
flutter build apk --release --dart-define=E2B_BACKEND_URL=https://e2b.n92dev.us.kg
```

## Important Notes

- **E2B API Key is NO LONGER REQUIRED** - The backend handles authentication
- The backend URL can be overridden in app Settings if needed
- The default backend URL (`https://e2b.n92dev.us.kg`) is hardcoded as a fallback
- GitHub Actions variables are case-sensitive: `E2B_BACKEND_URL` must match exactly
