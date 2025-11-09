# MSIX Device Family Configuration Guide

## Overview

When submitting an MSIX package to the Microsoft Store, you must ensure that the device families you select in Partner Center match what your package supports.

## Common Device Family Error

```
You must provide a package that supports each selected device family 
(or uncheck the box for unsupported device families). 
Note that targeting the Xbox device family requires a neutral or x64 package.
```

This error occurs when:
1. You've selected device families in Partner Center that your package doesn't support
2. Your package architecture doesn't match the device family requirements

## Xibe Chat Supported Device Families

**Current Configuration**: Xibe Chat is built for **Desktop x64 only**.

### ✅ Supported Device Families
- **Windows.Desktop** (x64) - Desktop PCs and laptops

### ❌ NOT Supported Device Families
- **Windows.Xbox** - Xbox consoles (requires special configuration)
- **Windows.Mobile** - Windows Mobile devices (deprecated)
- **Windows.Holographic** - HoloLens devices (requires special configuration)
- **Windows.IoT** - IoT devices (requires special configuration)
- **Windows.Team** - Surface Hub (requires special configuration)

## How to Fix Device Family Errors

### Option 1: Update Partner Center Selection (Recommended)

1. Go to [Microsoft Partner Center](https://partner.microsoft.com/)
2. Navigate to your app submission
3. Go to **Packages** section
4. Look for **Device family availability** section
5. **Uncheck** all device families except:
   - ✅ **Windows 10 Desktop** (or Windows.Desktop)
6. Make sure only the Desktop family is selected
7. Save your changes
8. Upload your MSIX package again

### Option 2: Build Multi-Architecture Package (Advanced)

If you want to support additional device families like Xbox:

1. **For Xbox Support**: Requires building for both x64 and ARM64
   ```yaml
   # In pubspec.yaml - this is NOT currently configured
   msix_config:
     architecture: neutral  # or build separate packages
   ```

2. **Requirements**:
   - Additional testing on target devices
   - Specific capabilities for each device family
   - Different UI considerations for Xbox/other platforms
   - Additional certification requirements

## Current Package Configuration

Based on the error message you received:

```
Invalid package family name: MegaVault.XibeChat_txc4n5ga7fxkm 
(expected: MegaVault.Xibechat_4jmkq7hf1s7vg)

Invalid package publisher name: CN=MegaVault 
(expected: CN=A65494A1-61E8-4D9B-82E9-7592028A8CCB)
```

These have been **fixed** in `pubspec.yaml`:
- ✅ `identity_name: MegaVault.Xibechat` (lowercase 'c')
- ✅ `publisher: CN=A65494A1-61E8-4D9B-82E9-7592028A8CCB` (Partner Center certificate)

## Recommended Actions

### Step 1: Rebuild the Package

After the configuration fixes, rebuild your MSIX:

```bash
# Via GitHub Actions (recommended)
1. Go to Actions → Multi-Platform Build and Release
2. Click "Run workflow"
3. Enter version (e.g., 1.0.4)
4. Enter build number (e.g., 1)
5. Select "draft"
6. Wait for build to complete
7. Download the MSIX from artifacts
```

### Step 2: Configure Partner Center

Before uploading the new package:

1. Sign in to Partner Center
2. Navigate to your app
3. Go to current submission
4. Click on **Packages**
5. Scroll to **Device family availability**
6. **IMPORTANT**: Uncheck all boxes except:
   - ✅ Windows 10 Desktop (version 10.0.17763.0 or higher)
7. Leave all other device families unchecked:
   - ❌ Xbox
   - ❌ Mobile (if visible)
   - ❌ Holographic
   - ❌ IoT
   - ❌ Team
8. Save the changes

### Step 3: Upload and Submit

1. Remove the old MSIX package
2. Upload the newly built MSIX with correct configuration
3. The validation should now pass for:
   - ✅ Package identity name
   - ✅ Publisher certificate
   - ✅ Device family support (only Desktop selected)
4. Add certification notes (see below)
5. Submit for review

## Certification Notes

Add this to your submission notes:

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
   - runFullTrust: Required for Win32 app functionality (standard for desktop apps)
   - No administrative privileges required
   - No special permissions needed beyond standard desktop app functionality

4. Testing:
   - App has been tested on Windows 10/11 Desktop (x64)
   - Verified functionality on standard user accounts
   - No compatibility issues found
```

## Architecture Details

### Current Build Configuration

```yaml
# pubspec.yaml
msix_config:
  architecture: x64  # Only x64 architecture
  store: true        # Unsigned package for Store submission
```

### GitHub Actions Workflow

```powershell
# .github/workflows/build-release.yml
flutter pub run msix:create --store --version ${{ inputs.version }}.0
```

This creates:
- **Architecture**: x64 only
- **Platform**: Windows Desktop
- **Package Type**: Unsigned MSIX (Store will sign)
- **Version Format**: X.X.X.0 (Store compliant)

## Troubleshooting

### Error: "Package doesn't support Xbox"

**Solution**: Uncheck Xbox device family in Partner Center. Xibe Chat is Desktop-only.

### Error: "Requires neutral or x64 package"

**Solution**: The package IS x64. Make sure only Desktop device family is selected.

### Error: "Device family not supported"

**Solution**: 
1. Check Partner Center device family selection
2. Ensure only Desktop is checked
3. Verify MSIX was built with correct configuration

### Error: "Architecture mismatch"

**Solution**:
1. Confirm MSIX was built with x64 architecture
2. Check that Desktop device family minimum version is set to 10.0.17763.0 or higher
3. Rebuild package if needed

## Verification Checklist

Before submitting to Store:

- [ ] Rebuilt MSIX with corrected `identity_name: MegaVault.Xibechat`
- [ ] Rebuilt MSIX with corrected `publisher: CN=A65494A1-61E8-4D9B-82E9-7592028A8CCB`
- [ ] In Partner Center, only **Windows Desktop** device family is selected
- [ ] All other device families (Xbox, Mobile, etc.) are **unchecked**
- [ ] Package version follows X.X.X.0 format
- [ ] Certification notes include technical details about runFullTrust
- [ ] Screenshots and Store listing are complete

## Expected Validation Results

After applying all fixes:

✅ **Package identity name**: `MegaVault.Xibechat_4jmkq7hf1s7vg` (correct capitalization)  
✅ **Publisher certificate**: `CN=A65494A1-61E8-4D9B-82E9-7592028A8CCB` (Partner Center GUID)  
✅ **Device family support**: Desktop only (matches package capabilities)  
✅ **Architecture**: x64 (correct for Desktop)  
✅ **Version format**: X.X.X.0 (Store compliant)  
⚠️ **runFullTrust warning**: Expected, non-blocking (standard for Flutter apps)

## Additional Resources

- [Microsoft Store Device Family Documentation](https://docs.microsoft.com/en-us/windows/uwp/publish/device-family-availability)
- [MSIX Architecture Requirements](https://docs.microsoft.com/en-us/windows/msix/package/device-architecture)
- `MSIX_STORE_FIXES.md` - Previous validation fixes
- `MICROSOFT_STORE_SUBMISSION.md` - Complete submission guide

---

**Quick Fix Summary**: Rebuild with corrected configuration, then in Partner Center uncheck all device families except Windows Desktop before uploading the new package.
