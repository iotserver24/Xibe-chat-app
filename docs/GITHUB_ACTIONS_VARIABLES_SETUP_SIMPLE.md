# GitHub Actions Variables Setup - Simplified

You're right! Most values are the same. Here's the **minimal setup** you actually need.

---

## Why Simplified?

- ✅ **Shared values** (Project ID, Auth Domain, etc.) are the same for ALL platforms
- ✅ **Web, Windows, macOS, Linux** can all use the SAME web config
- ✅ **Only Android and iOS** need separate configs
- ✅ **GitHub Actions workflow** already has fallback logic built-in

---

## Minimal Setup (Only 9 Variables Needed!)

### Step 1: Navigate to Variables

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **Variables** tab
3. Click **New repository variable**

---

### Step 2: Add Only These Variables

#### Group 1: Shared Values (Same for ALL platforms)

**Variable 1:**
- **Name:** `FIREBASE_PROJECT_ID`
- **Value:** `share-x-56754`

**Variable 2:**
- **Name:** `FIREBASE_AUTH_DOMAIN`
- **Value:** `share-x-56754.firebaseapp.com`

**Variable 3:**
- **Name:** `FIREBASE_STORAGE_BUCKET`
- **Value:** `share-x-56754.firebasestorage.app`

**Variable 4:**
- **Name:** `FIREBASE_MESSAGING_SENDER_ID`
- **Value:** `488265380434`

---

#### Group 2: Web Config (Used for Web, Windows, macOS, Linux)

**Variable 5:**
- **Name:** `FIREBASE_API_KEY`
- **Value:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`

**Variable 6:**
- **Name:** `FIREBASE_APP_ID`
- **Value:** `1:488265380434:web:4e5f01713760cc1c10e58b`

---

#### Group 3: Android (Different from web)

**Variable 7:**
- **Name:** `FIREBASE_ANDROID_API_KEY`
- **Value:** `AIzaSyCeYumB4mv99o6yYS0Q1D8XCsooB0P8Afw`

**Variable 8:**
- **Name:** `FIREBASE_ANDROID_APP_ID`
- **Value:** `1:488265380434:android:55d3a0fba109b6d410e58b`

---

#### Group 4: iOS (Different from web)

**Variable 9:**
- **Name:** `FIREBASE_IOS_API_KEY`
- **Value:** `AIzaSyBsfaexrb7pTIJ5QBip08EYyUxVXwFfSng`

**Variable 10:**
- **Name:** `FIREBASE_IOS_APP_ID`
- **Value:** `1:488265380434:ios:fd982cfc53e23bcd10e58b`

**Variable 11 (Optional):**
- **Name:** `FIREBASE_IOS_BUNDLE_ID`
- **Value:** `com.xibechat.app`
- *(Has default fallback, but good to set explicitly)*

---

## How It Works

The GitHub Actions workflow has **fallback logic**:

```yaml
# If platform-specific not set, uses shared/web config
FIREBASE_WINDOWS_API_KEY: ${{ vars.FIREBASE_WINDOWS_API_KEY || vars.FIREBASE_API_KEY }}
FIREBASE_MACOS_API_KEY: ${{ vars.FIREBASE_MACOS_API_KEY || vars.FIREBASE_API_KEY }}
FIREBASE_LINUX_API_KEY: ${{ vars.FIREBASE_LINUX_API_KEY || vars.FIREBASE_API_KEY }}
```

So:
- **Web/Windows/macOS/Linux** → Uses `FIREBASE_API_KEY` (web config)
- **Android** → Uses `FIREBASE_ANDROID_API_KEY` (or falls back to web)
- **iOS** → Uses `FIREBASE_IOS_API_KEY` (or falls back to web)

---

## Summary

### Minimum Required (9 variables):
1. `FIREBASE_PROJECT_ID`
2. `FIREBASE_AUTH_DOMAIN`
3. `FIREBASE_STORAGE_BUCKET`
4. `FIREBASE_MESSAGING_SENDER_ID`
5. `FIREBASE_API_KEY` (web config - used for web/desktop)
6. `FIREBASE_APP_ID` (web config - used for web/desktop)
7. `FIREBASE_ANDROID_API_KEY`
8. `FIREBASE_ANDROID_APP_ID`
9. `FIREBASE_IOS_API_KEY`
10. `FIREBASE_IOS_APP_ID`
11. `FIREBASE_IOS_BUNDLE_ID` (optional, has default)

### Optional (if you want explicit platform configs):
- `FIREBASE_WEB_API_KEY` (same as `FIREBASE_API_KEY`)
- `FIREBASE_WINDOWS_API_KEY` (same as `FIREBASE_API_KEY`)
- `FIREBASE_MACOS_API_KEY` (same as `FIREBASE_API_KEY`)
- `FIREBASE_LINUX_API_KEY` (same as `FIREBASE_API_KEY`)

**But you don't need them!** The workflow will automatically use the web config for these platforms.

---

## Quick Copy-Paste (Minimal Setup)

```
FIREBASE_PROJECT_ID = share-x-56754
FIREBASE_AUTH_DOMAIN = share-x-56754.firebaseapp.com
FIREBASE_STORAGE_BUCKET = share-x-56754.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID = 488265380434
FIREBASE_API_KEY = AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_APP_ID = 1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_ANDROID_API_KEY = AIzaSyCeYumB4mv99o6yYS0Q1D8XCsooB0P8Afw
FIREBASE_ANDROID_APP_ID = 1:488265380434:android:55d3a0fba109b6d410e58b
FIREBASE_IOS_API_KEY = AIzaSyBsfaexrb7pTIJ5QBip08EYyUxVXwFfSng
FIREBASE_IOS_APP_ID = 1:488265380434:ios:fd982cfc53e23bcd10e58b
FIREBASE_IOS_BUNDLE_ID = com.xibechat.app
```

**Total: 11 variables** (instead of 20!)

---

## Why This Works

1. **Shared values** → Used by all platforms
2. **Web config** → Used as fallback for Web, Windows, macOS, Linux
3. **Android config** → Only Android needs different API key/App ID
4. **iOS config** → Only iOS needs different API key/App ID
5. **Workflow fallback** → Automatically uses web config if platform-specific not set

---

## Result

✅ **11 variables** instead of 20  
✅ **Same functionality**  
✅ **Less maintenance**  
✅ **Easier to understand**

The workflow will automatically use the right config for each platform!

