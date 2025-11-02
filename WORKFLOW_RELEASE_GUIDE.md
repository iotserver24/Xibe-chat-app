# Workflow Release Guide

This guide explains how to use the Multi-Platform Build and Release workflow with the new release type feature.

## Quick Start

### Step 1: Navigate to GitHub Actions

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. Select "Multi-Platform Build and Release" from the workflow list
4. Click the "Run workflow" button (on the right side)

### Step 2: Configure the Release

Fill in the workflow inputs:

#### Version Number
- Format: `major.minor.patch` (e.g., `1.0.4`)
- Follow [semantic versioning](https://semver.org/)
- Example: `1.0.4`

#### Build Number
- Incremental number for this version
- Start at `1` for first build of a version
- Increment if rebuilding same version
- Example: `1`

#### Release Type
Choose from three options:

##### 🔒 Draft (For Testing)
```
release_type: draft
```
**Use when:**
- Testing the build process
- Verifying changes before public release
- Internal QA and validation

**Behavior:**
- Creates a draft release (not visible publicly)
- Only accessible to repository maintainers
- Not detected by app's auto-update
- Can be edited or deleted easily
- Can be published later as beta or latest

**Example:** Testing a new feature before sharing with users

##### 🧪 Beta (Pre-release)
```
release_type: beta
```
**Use when:**
- Releasing beta versions for testing
- Getting user feedback before stable release
- Testing new features with early adopters

**Behavior:**
- Marked as "Pre-release" on GitHub
- Visible to all users
- Shows "Beta Version" badge in update dialog
- Detected by app's auto-update
- Users can choose to install or skip

**Example:** Beta testing a major new feature

##### ✅ Latest (Stable Release)
```
release_type: latest
```
**Use when:**
- Releasing stable, production-ready version
- Recommended for all users
- No known critical bugs

**Behavior:**
- Normal public release
- Marked as "Latest release" on GitHub
- Detected by app's auto-update
- No special badges in update dialog
- Recommended installation

**Example:** Regular stable release

### Step 3: Run the Workflow

1. After filling in all fields, click "Run workflow"
2. The workflow will start building for all platforms:
   - Android (APK, AAB)
   - Windows (x64, ARM64)
   - macOS (Intel, Apple Silicon)
   - Linux (x64)
   - iOS (unsigned)
3. Wait for all builds to complete (~15-30 minutes)
4. Check the "Releases" tab to see your new release

## Examples

### Example 1: Draft Release for Testing
```yaml
Version: 1.0.5
Build Number: 1
Release Type: draft
```
**Result:** Creates `v1.0.5-1` as a draft. You can test it privately before publishing.

### Example 2: Beta Release
```yaml
Version: 1.1.0
Build Number: 1
Release Type: beta
```
**Result:** Creates `v1.1.0-1` as a pre-release. Users will see it as a beta update.

### Example 3: Stable Release
```yaml
Version: 1.0.4
Build Number: 1
Release Type: latest
```
**Result:** Creates `v1.0.4-1` as the latest stable release. All users will be notified.

## Release Workflow

### Recommended Flow

1. **Development Phase**
   - Make code changes
   - Test locally
   - Commit and push to repository

2. **Testing Phase** (Optional)
   ```yaml
   release_type: draft
   ```
   - Run workflow as draft
   - Download and test builds
   - Fix any issues found
   - Repeat if needed

3. **Beta Phase** (Optional)
   ```yaml
   release_type: beta
   ```
   - Run workflow as beta
   - Share with beta testers
   - Collect feedback
   - Fix critical issues

4. **Production Release**
   ```yaml
   release_type: latest
   ```
   - Run workflow as latest
   - All users get notified
   - Monitor for issues

### Publishing a Draft

If you created a draft and want to publish it:

1. Go to the draft release on GitHub
2. Click "Edit"
3. Uncheck "Set as a pre-release" (for stable) or keep it checked (for beta)
4. Uncheck "Set as a draft"
5. Click "Update release"

Note: The release will keep its original tag name.

## Version Numbering Guidelines

### When to Increment

#### Major Version (X.0.0)
- Breaking changes
- Major new features
- Complete redesign
- Example: `1.0.0` → `2.0.0`

#### Minor Version (0.X.0)
- New features (backward compatible)
- Significant improvements
- New platforms support
- Example: `1.0.0` → `1.1.0`

#### Patch Version (0.0.X)
- Bug fixes
- Small improvements
- Performance optimizations
- Example: `1.0.0` → `1.0.1`

#### Build Number
- Same version, different build
- Rebuild with same source
- Fix build issues
- Example: `1.0.0+1` → `1.0.0+2`

## Troubleshooting

### Workflow Fails

1. Check the logs in GitHub Actions
2. Common issues:
   - Build errors in code
   - Missing dependencies
   - Platform-specific issues
3. Fix the issue and rerun with same version but higher build number

### Release Not Showing in App

1. **For Draft releases:** Working as intended (drafts are hidden)
2. **For Beta/Latest releases:** 
   - Check release is published (not draft)
   - Verify release has assets (APK, EXE, etc.)
   - Wait a few minutes for GitHub API to update
   - Check app's internet connection

### Wrong Release Type

If you published with wrong type:

1. Delete the release on GitHub
2. Delete the tag on GitHub
3. Run workflow again with correct type

Or:

1. Edit the release on GitHub
2. Change pre-release flag as needed
3. Update release

## Best Practices

### Version Strategy
- Always increment version numbers
- Never reuse version numbers
- Use draft for internal testing
- Use beta for public testing
- Use latest for stable releases

### Build Numbers
- Start at 1 for each new version
- Increment if rebuilding same version
- Include in release notes if relevant

### Release Notes
- Write clear, concise release notes
- List new features
- List bug fixes
- List breaking changes
- Include upgrade instructions if needed

### Testing
- Test draft releases thoroughly
- Beta test for at least a few days
- Monitor beta feedback before stable release
- Have rollback plan for stable releases

## FAQ

**Q: Can I edit a release after publishing?**
A: Yes, you can edit release notes, but changing draft/pre-release status is recommended to be done before publishing.

**Q: What happens if I delete a release?**
A: Users won't see it as an available update. Current users won't be affected.

**Q: How do I rollback a release?**
A: Delete the problematic release and create a new release with the previous working version.

**Q: Can I have multiple beta versions?**
A: Yes, create multiple releases with different version numbers, all marked as beta.

**Q: Do draft releases consume GitHub storage?**
A: Yes, but you can delete them after testing.

**Q: How long does the workflow take?**
A: Usually 15-30 minutes depending on GitHub runners availability.

## Summary

- Use **draft** for private testing
- Use **beta** for public testing
- Use **latest** for stable releases
- Follow semantic versioning
- Test before publishing stable releases
- Write good release notes

For more details on the auto-update feature, see [AUTO_UPDATE_GUIDE.md](AUTO_UPDATE_GUIDE.md).
