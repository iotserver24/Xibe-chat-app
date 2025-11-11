# GitHub Actions Variables Setup Guide

Step-by-step guide to add Firebase configuration as **Variables** (not Secrets) in GitHub Actions.

---

## Step 1: Navigate to Repository Settings

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/xibe-chat-app`
2. Click on the **Settings** tab (top menu bar)
3. In the left sidebar, click **Secrets and variables** → **Actions**

---

## Step 2: Go to Variables Tab

1. You'll see two tabs: **Secrets** and **Variables**
2. Click on the **Variables** tab (NOT Secrets)
3. Click the **New repository variable** button

---

## Step 3: Add Variables One by One

Add each variable individually. Click **New repository variable** for each one.

### Group 1: Shared/Project Variables (Add First)

**Variable 1:**
- **Name:** `FIREBASE_PROJECT_ID`
- **Value:** `share-x-56754`
- Click **Add variable**

**Variable 2:**
- **Name:** `FIREBASE_AUTH_DOMAIN`
- **Value:** `share-x-56754.firebaseapp.com`
- Click **Add variable**

**Variable 3:**
- **Name:** `FIREBASE_STORAGE_BUCKET`
- **Value:** `share-x-56754.firebasestorage.app`
- Click **Add variable**

**Variable 4:**
- **Name:** `FIREBASE_MESSAGING_SENDER_ID`
- **Value:** `488265380434`
- Click **Add variable**

---

### Group 2: Web Configuration (Fallback)

**Variable 5:**
- **Name:** `FIREBASE_API_KEY`
- **Value:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`
- Click **Add variable**

**Variable 6:**
- **Name:** `FIREBASE_APP_ID`
- **Value:** `1:488265380434:web:4e5f01713760cc1c10e58b`
- Click **Add variable**

---

### Group 3: Web Platform

**Variable 7:**
- **Name:** `FIREBASE_WEB_API_KEY`
- **Value:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`
- Click **Add variable**

**Variable 8:**
- **Name:** `FIREBASE_WEB_APP_ID`
- **Value:** `1:488265380434:web:4e5f01713760cc1c10e58b`
- Click **Add variable**

---

### Group 4: Windows Platform

**Variable 9:**
- **Name:** `FIREBASE_WINDOWS_API_KEY`
- **Value:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`
- Click **Add variable**

**Variable 10:**
- **Name:** `FIREBASE_WINDOWS_APP_ID`
- **Value:** `1:488265380434:web:4e5f01713760cc1c10e58b`
- Click **Add variable**

---

### Group 5: macOS Platform

**Variable 11:**
- **Name:** `FIREBASE_MACOS_API_KEY`
- **Value:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`
- Click **Add variable**

**Variable 12:**
- **Name:** `FIREBASE_MACOS_APP_ID`
- **Value:** `1:488265380434:web:4e5f01713760cc1c10e58b`
- Click **Add variable**

**Variable 13:**
- **Name:** `FIREBASE_MACOS_BUNDLE_ID`
- **Value:** `com.xibechat.app`
- Click **Add variable**

---

### Group 6: Linux Platform

**Variable 14:**
- **Name:** `FIREBASE_LINUX_API_KEY`
- **Value:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`
- Click **Add variable**

**Variable 15:**
- **Name:** `FIREBASE_LINUX_APP_ID`
- **Value:** `1:488265380434:web:4e5f01713760cc1c10e58b`
- Click **Add variable**

---

### Group 7: Android Platform

**Variable 16:**
- **Name:** `FIREBASE_ANDROID_API_KEY`
- **Value:** `AIzaSyCeYumB4mv99o6yYS0Q1D8XCsooB0P8Afw`
- Click **Add variable**

**Variable 17:**
- **Name:** `FIREBASE_ANDROID_APP_ID`
- **Value:** `1:488265380434:android:55d3a0fba109b6d410e58b`
- Click **Add variable**

---

### Group 8: iOS Platform

**Variable 18:**
- **Name:** `FIREBASE_IOS_API_KEY`
- **Value:** `AIzaSyBsfaexrb7pTIJ5QBip08EYyUxVXwFfSng`
- Click **Add variable**

**Variable 19:**
- **Name:** `FIREBASE_IOS_APP_ID`
- **Value:** `1:488265380434:ios:fd982cfc53e23bcd10e58b`
- Click **Add variable**

**Variable 20:**
- **Name:** `FIREBASE_IOS_BUNDLE_ID`
- **Value:** `com.xibechat.app`
- Click **Add variable**

---

## Step 4: Verify All Variables

After adding all variables, you should see a list like this:

```
Variables (20)
├── FIREBASE_PROJECT_ID
├── FIREBASE_AUTH_DOMAIN
├── FIREBASE_STORAGE_BUCKET
├── FIREBASE_MESSAGING_SENDER_ID
├── FIREBASE_API_KEY
├── FIREBASE_APP_ID
├── FIREBASE_WEB_API_KEY
├── FIREBASE_WEB_APP_ID
├── FIREBASE_WINDOWS_API_KEY
├── FIREBASE_WINDOWS_APP_ID
├── FIREBASE_MACOS_API_KEY
├── FIREBASE_MACOS_APP_ID
├── FIREBASE_MACOS_BUNDLE_ID
├── FIREBASE_LINUX_API_KEY
├── FIREBASE_LINUX_APP_ID
├── FIREBASE_ANDROID_API_KEY
├── FIREBASE_ANDROID_APP_ID
├── FIREBASE_IOS_API_KEY
├── FIREBASE_IOS_APP_ID
└── FIREBASE_IOS_BUNDLE_ID
```

---

## Quick Copy-Paste Reference

Here's a formatted list you can copy from:

```
FIREBASE_PROJECT_ID = share-x-56754
FIREBASE_AUTH_DOMAIN = share-x-56754.firebaseapp.com
FIREBASE_STORAGE_BUCKET = share-x-56754.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID = 488265380434
FIREBASE_API_KEY = AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_APP_ID = 1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_WEB_API_KEY = AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WEB_APP_ID = 1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_WINDOWS_API_KEY = AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WINDOWS_APP_ID = 1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_API_KEY = AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_MACOS_APP_ID = 1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_BUNDLE_ID = com.xibechat.app
FIREBASE_LINUX_API_KEY = AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_LINUX_APP_ID = 1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_ANDROID_API_KEY = AIzaSyCeYumB4mv99o6yYS0Q1D8XCsooB0P8Afw
FIREBASE_ANDROID_APP_ID = 1:488265380434:android:55d3a0fba109b6d410e58b
FIREBASE_IOS_API_KEY = AIzaSyBsfaexrb7pTIJ5QBip08EYyUxVXwFfSng
FIREBASE_IOS_APP_ID = 1:488265380434:ios:fd982cfc53e23bcd10e58b
FIREBASE_IOS_BUNDLE_ID = com.xibechat.app
```

**Note:** Copy the NAME and VALUE separately. GitHub requires you to enter them in separate fields.

---

## Important Notes

### Variables vs Secrets

- ✅ **Variables** (what we're using): Visible in workflow logs, can be used by anyone with repo access
- 🔒 **Secrets** (not using): Encrypted, hidden in logs, for sensitive data

**Why Variables?**
- Firebase API keys are meant to be public (they're restricted by domain/package)
- Easier to debug and verify in workflow logs
- No security risk since Firebase has security rules

### Variable Naming

- Use **UPPERCASE** with underscores
- No spaces
- Must match exactly what's in `.github/workflows/build-release.yml`

### Editing Variables

- Click on any variable name to edit it
- Click the **⋮** (three dots) menu to delete

---

## Testing

After adding all variables:

1. Go to **Actions** tab in your repository
2. Trigger a workflow (push a commit or manually run)
3. Check the workflow logs
4. Look for `--dart-define=FIREBASE_API_KEY=...` in the build command
5. Verify Firebase initialization succeeds

---

## Troubleshooting

### Variable Not Found Error

**Error:** `Context access might be invalid: FIREBASE_API_KEY`

**Solution:** 
- Verify variable name matches exactly (case-sensitive)
- Make sure you're in the **Variables** tab, not Secrets
- Check that variable was saved (refresh page)

### Build Fails with "Firebase configuration not found"

**Error:** `Firebase configuration not found for...`

**Solution:**
- Verify all required variables are set
- Check variable values don't have extra spaces
- Ensure workflow file references `vars.FIREBASE_API_KEY` (not `secrets.FIREBASE_API_KEY`)

### Wrong Values

**Error:** Firebase initialization fails

**Solution:**
- Double-check values copied correctly
- Verify from `docs/FIREBASE_CONFIG_VALUES.md`
- Make sure no typos in API keys or App IDs

---

## Summary

✅ **Total Variables:** 20  
✅ **Platforms Covered:** Web, Windows, macOS, Linux, Android, iOS  
✅ **Setup Time:** ~5-10 minutes  
✅ **Ready for:** All CI/CD builds with Firebase cloud sync

After completing this setup, your GitHub Actions workflows will automatically use these Firebase configurations for all platform builds!

