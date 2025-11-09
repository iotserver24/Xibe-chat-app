# Microsoft Store Submission Checklist

## Pre-Submission Checklist

Use this checklist before submitting your MSIX package to ensure all issues are resolved.

### ✅ Configuration Verification

- [x] **Package Identity Name**: `MegaVault.Xibechat` (lowercase 'c') in `pubspec.yaml`
- [x] **Publisher Certificate**: `CN=A65494A1-61E8-4D9B-82E9-7592028A8CCB` in `pubspec.yaml`
- [x] **Publisher Display Name**: `MegaVault` in `pubspec.yaml`
- [x] **Version Format**: X.X.X.0 (workflow automatically sets .0)
- [x] **Store Flag**: `store: true` in `pubspec.yaml`
- [x] **Architecture**: `x64` in `pubspec.yaml`

### 📦 Package Build

- [ ] Run GitHub Actions workflow with new version number
- [ ] Wait for workflow to complete successfully
- [ ] Download MSIX artifact: `xibe-chat-windows-universal-store-v{VERSION}-{BUILD}.msix`
- [ ] Verify file size is reasonable (should be 20-50 MB)

### 🎯 Partner Center Configuration

- [ ] Sign in to [Microsoft Partner Center](https://partner.microsoft.com/)
- [ ] Navigate to Xibe Chat app submission
- [ ] Go to **Packages** section
- [ ] Configure **Device Family Availability**:
  - [ ] ✅ Check **ONLY**: Windows 10 Desktop
  - [ ] ❌ Uncheck: Xbox
  - [ ] ❌ Uncheck: Mobile (if visible)
  - [ ] ❌ Uncheck: Holographic
  - [ ] ❌ Uncheck: IoT
  - [ ] ❌ Uncheck: Team
  - [ ] ❌ Uncheck: Any other device families
- [ ] Save device family settings

### 📤 Package Upload

- [ ] Remove old MSIX package (if any)
- [ ] Upload new MSIX package
- [ ] Wait for validation to complete
- [ ] Verify no validation errors appear
- [ ] Check validation warnings:
  - [ ] ⚠️ runFullTrust warning (expected, non-blocking)
  - [ ] ✅ No identity name errors
  - [ ] ✅ No publisher certificate errors
  - [ ] ✅ No device family errors

### 📝 Store Listing

- [ ] **App Name**: Xibe Chat (or your reserved name)
- [ ] **Description**: Complete and accurate (10-10,000 characters)
- [ ] **Screenshots**: At least 3 screenshots (1366x768, 1920x1080, or 3840x2160)
- [ ] **App Icon**: 300x300 or larger
- [ ] **Privacy Policy**: Added (if collecting personal data)
- [ ] **Support Contact**: Email or website provided
- [ ] **Category**: Productivity (or appropriate category)
- [ ] **Pricing**: Set (Free or Paid)
- [ ] **Markets**: Selected
- [ ] **Age Rating**: Completed

### 📋 Certification Notes

- [ ] Added technical notes about runFullTrust capability
- [ ] Explained Flutter desktop app architecture
- [ ] Noted platform support (Desktop only)
- [ ] Mentioned no admin privileges required

Example certification notes:
```
Technical Implementation Notes:

1. Platform Support:
   - This application is designed for Windows Desktop devices only
   - Targets x64 architecture
   - Minimum OS: Windows 10 version 1809 (build 17763) or later

2. Framework:
   - Built with Flutter (Dart-based cross-platform framework)
   - This is a Win32 application packaged as MSIX
   - Uses runFullTrust capability (standard for Flutter desktop apps)

3. Capabilities:
   - internetClient: Required for AI chat functionality
   - runFullTrust: Required for Win32 app functionality
   - No administrative privileges required

4. Testing:
   - App has been tested on Windows 10/11 Desktop (x64)
   - Verified functionality on standard user accounts
```

### 🚀 Final Submission

- [ ] Reviewed all sections for completeness
- [ ] Verified all required fields are filled
- [ ] Checked for any validation errors
- [ ] Clicked **"Submit to the Store"**
- [ ] Noted submission date/time

## Expected Validation Results

After following this checklist, you should see:

| Check | Expected Result |
|-------|----------------|
| Package identity name | ✅ Pass - `MegaVault.Xibechat_4jmkq7hf1s7vg` |
| Publisher certificate | ✅ Pass - `CN=A65494A1-61E8-4D9B-82E9-7592028A8CCB` |
| Device family support | ✅ Pass - Desktop only |
| Version format | ✅ Pass - X.X.X.0 |
| Architecture | ✅ Pass - x64 for Desktop |
| runFullTrust capability | ⚠️ Warning (non-blocking) |
| Store signature | ✅ Pass - Microsoft will sign |

## Common Issues and Quick Fixes

### Issue: "Invalid package family name"
**Quick Fix**: Verify `identity_name: MegaVault.Xibechat` (lowercase 'c') in pubspec.yaml, rebuild

### Issue: "Invalid package publisher name"
**Quick Fix**: Verify `publisher: CN=A65494A1-61E8-4D9B-82E9-7592028A8CCB` in pubspec.yaml, rebuild

### Issue: "Device family not supported"
**Quick Fix**: In Partner Center, uncheck all device families except Windows Desktop

### Issue: "Version revision must be 0"
**Quick Fix**: Use GitHub Actions workflow (automatically sets .0), don't build manually

### Issue: "runFullTrust capability warning"
**Quick Fix**: Add certification notes explaining Flutter desktop app (this is non-blocking)

## Post-Submission

After submission:

- [ ] Monitor submission status in Partner Center
- [ ] Wait for certification (typically 24-48 hours)
- [ ] Check email for certification results
- [ ] If approved: Celebrate! 🎉
- [ ] If rejected: Read feedback carefully, fix issues, resubmit

## Quick Links

- [Microsoft Partner Center](https://partner.microsoft.com/)
- [Store Policies](https://docs.microsoft.com/en-us/windows/uwp/publish/store-policies)
- [MSIX Packaging](https://docs.microsoft.com/en-us/windows/msix/)
- [App Certification Requirements](https://docs.microsoft.com/en-us/windows/uwp/publish/the-app-certification-process)

## Repository Documentation

For detailed information:

- **`MSIX_VALIDATION_FIXES_SUMMARY.md`** - Quick summary of fixes applied
- **`MSIX_DEVICE_FAMILY_GUIDE.md`** - Device family configuration guide
- **`MICROSOFT_STORE_SUBMISSION.md`** - Complete submission guide
- **`MSIX_STORE_FIXES.md`** - Previous validation fixes

---

**Status**: Configuration fixed ✅ | Ready to rebuild and submit 🚀

**Estimated Time**: 10-15 minutes (rebuild + configure + upload)
