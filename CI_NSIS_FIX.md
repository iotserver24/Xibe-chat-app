# CI NSIS Installation Fix

## Problem
The GitHub Actions Windows build workflow was failing with:
```
❌ NSIS not found in any expected location
Process completed with exit code 1.
```

The issue occurred because NSIS was being installed via Chocolatey, but the PATH environment variable was not being updated for subsequent workflow steps. This meant that even though NSIS was successfully installed, the build step couldn't locate the `makensis.exe` executable.

## Solution
Fixed the workflow in `.github/workflows/build-release.yml` with the following improvements:

### 1. Enhanced NSIS Installation Step (lines 198-243)
- **Added PATH persistence**: After finding the NSIS installation, the workflow now adds the NSIS directory to `$env:GITHUB_PATH`, which persists the PATH change for all subsequent steps
- **Added current session PATH**: Also updates `$env:PATH` for the current PowerShell session
- **Improved error handling**: If NSIS is not found in expected locations, performs a filesystem search as a fallback
- **Better verification**: Confirms NSIS is found and displays its version before proceeding

### 2. Enhanced NSIS Build Step (lines 326-420)
- **Multi-tier location strategy**:
  1. First checks PATH using `where.exe makensis.exe` (most reliable)
  2. Falls back to checking standard installation directories
  3. Last resort: performs a filesystem search
- **Better error messages**: Provides clear diagnostic information if NSIS cannot be found
- **Build verification**: After creating the installer, verifies the file exists and displays its size
- **Detailed logging**: Shows which NSIS executable path is being used

## Key Changes
1. **PATH Management**: The critical fix is persisting the NSIS directory to GitHub Actions PATH using `$env:GITHUB_PATH`
2. **Robust Detection**: Multiple fallback methods ensure NSIS is found regardless of installation location
3. **Error Prevention**: Early detection and clear error messages prevent silent failures

## Testing
This fix ensures that:
- NSIS is properly installed and detected in GitHub Actions runners
- The PATH is correctly configured for subsequent build steps
- Clear error messages are shown if any step fails
- The NSIS installer is successfully built for both x64 and arm64 architectures

## Technical Details
- **GitHub Actions PATH**: Writing to `$env:GITHUB_PATH` persists environment variables across steps
- **PowerShell Sessions**: Direct `$env:PATH` modification only affects the current session
- **Chocolatey**: Installs NSIS to `C:\Program Files (x86)\NSIS\` by default on Windows runners
