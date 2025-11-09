# Microsoft Store Submission Guide

This guide explains how to submit the Xibe Chat universal MSIX package to the Microsoft Store without purchasing a code signing certificate.

## Overview

The build workflow now generates an **unsigned universal MSIX package** specifically designed for Microsoft Store submission. Microsoft will sign the package with their own certificate during the publishing process, so you don't need to purchase a certificate yourself.

## What's Generated

The workflow produces:
- `xibe-chat-windows-universal-store-v{VERSION}-{BUILD}.msix` - Unsigned universal MSIX for Microsoft Store

This package is:
- ✅ **Unsigned** - Ready for Microsoft Store to sign
- ✅ **Universal** - Works across all supported Windows architectures
- ✅ **Store-ready** - Configured with the `--store` flag
- ❌ **Cannot be sideloaded** - Requires Microsoft Store signature to install

## Prerequisites

1. **Microsoft Partner Center Account**
   - Go to https://partner.microsoft.com/
   - Create a developer account (one-time fee: $19 for individuals, $99 for organizations)
   - Complete identity verification

2. **Reserve App Name**
   - In Partner Center, go to "Apps and games" → "New product"
   - Reserve the name "Xibe Chat" (or your preferred name)
   - Note: App names must be unique in the Microsoft Store

## Submission Steps

### 1. Download the MSIX Package

After running the build workflow:
1. Go to GitHub Actions
2. Find your completed workflow run
3. Download `xibe-chat-windows-universal-store-v{VERSION}-{BUILD}.msix` from the release

### 2. Create a New Submission

1. Log in to [Microsoft Partner Center](https://partner.microsoft.com/)
2. Navigate to **Apps and games**
3. Select your reserved app name
4. Click **Start your submission**

### 3. Configure App Properties

#### Pricing and Availability
- **Pricing**: Free (or set your price)
- **Markets**: Select all markets or specific regions
- **Visibility**: Public, Private, or Hidden

#### Properties
- **Category**: Productivity (or appropriate category)
- **Subcategory**: (optional)
- **App declarations**:
  - Does your product access, collect, or transmit personal information? (Answer appropriately based on your privacy practices)
  - Does your product require use of an internet connection? **Yes**

#### Age Ratings
- Complete the age ratings questionnaire
- Xibe Chat is likely rated PEGI 3 / ESRB Everyone

### 4. Upload Packages

1. Navigate to **Packages**
2. Click **Upload packages**
3. Drag and drop or browse to `xibe-chat-windows-universal-store-v{VERSION}-{BUILD}.msix`
4. Wait for validation to complete
5. Microsoft will automatically sign the package

**Important Package Requirements:**
- ✅ Package must be under 25 GB
- ✅ Must be an MSIX or MSIXBUNDLE file
- ✅ Must be unsigned (Microsoft will sign it)
- ✅ Must target Windows 10 version 1809 or later

### 5. Store Listings

#### English (United States) - Required

**Description** (between 10 and 10,000 characters):
```
Xibe Chat - AI-Powered Chat Application

Transform the way you interact with AI! Xibe Chat is a modern, feature-rich chat application that brings the power of artificial intelligence to your desktop.

🤖 FEATURES:
• Multi-model AI support - Chat with various AI models
• Beautiful cross-platform UI - Native Windows 11 design
• Multiple conversation threads - Organize your chats
• Markdown rendering - Rich text formatting in messages
• Code syntax highlighting - Perfect for developers
• Local chat history - Your conversations stay on your device
• Web search integration - Get answers with real-time web data
• Dark/Light themes - Easy on the eyes, day or night
• Offline-capable - Access your chat history anytime

💬 PERFECT FOR:
• Students and researchers
• Developers and programmers
• Content creators
• Business professionals
• Anyone curious about AI

🔒 PRIVACY FOCUSED:
Your conversations are stored locally on your device. We prioritize your privacy and data security.

⚡ FAST & RESPONSIVE:
Built with Flutter for smooth, native performance on Windows.

Get started with Xibe Chat today and experience the future of AI conversation!
```

**Screenshots**:
- Upload at least 1 screenshot (minimum 3 recommended)
- Required sizes: 1366x768, 1920x1080, or 3840x2160
- Show key features of your app

**Store logos**:
- App icon (300x300 or larger, square)
- Upload logo.png from the project

**Additional information** (optional):
- Website: https://github.com/iotserver24/xibe-chat
- Support contact info: Your email
- Privacy policy URL: (if applicable)

### 6. Certification Notes (Optional but Recommended)

Add notes for certification testers:
```
Test Account (if required):
- Not required - app works without account

Features requiring internet:
- AI chat functionality requires internet connection
- Local chat history works offline

Known limitations:
- First launch may require internet to download AI models
```

### 7. Submit for Certification

1. Review all sections - ensure all required fields are complete
2. Click **Submit to the Store**
3. Wait for certification (typically 24-48 hours)

## Certification Process

### What Microsoft Checks

1. **Security scan** - Automated malware and virus checks
2. **Technical compliance** - Package format, manifest, capabilities
3. **Content policy** - Ensures app follows Microsoft Store policies
4. **Performance** - App launch and basic functionality testing
5. **Accessibility** - Basic accessibility requirements

### Common Rejection Reasons

❌ **Incomplete metadata** - Missing required fields in store listing
❌ **Poor quality screenshots** - Low resolution or not representative
❌ **Crashes on launch** - App doesn't start properly
❌ **Missing privacy policy** - Required if you collect personal data
❌ **Inappropriate content** - Violates content policy

### If Rejected

1. Read the rejection email carefully
2. Address all issues mentioned
3. Update your submission
4. Resubmit for certification

## After Approval

### Publishing

- Your app becomes available in the Microsoft Store within a few hours
- Users can find it by searching "Xibe Chat"
- Direct store link: `https://www.microsoft.com/store/apps/{YOUR_APP_ID}`

### Updates

To release updates:
1. Run the build workflow with a new version number
2. Download the new MSIX package
3. Go to your app in Partner Center
4. Click **Update**
5. Upload new package
6. Submit for certification

**Update best practices:**
- Increment version number in the workflow
- Test thoroughly before submitting
- Write clear release notes
- Monitor user reviews and feedback

## Package Configuration

The MSIX package is configured in `pubspec.yaml`:

```yaml
msix_config:
  display_name: Xibe Chat
  publisher_display_name: XibeChat
  identity_name: XibeChat.XibeChat
  publisher: CN=XibeChat
  msix_version: 1.0.0.0
  logo_path: logo.png
  capabilities: internetClient
  store: true
  architecture: x64
```

### Important Settings

- **store: true** - Generates unsigned package for Store submission
- **publisher: CN=XibeChat** - Publisher identity (placeholder for Store submission, Microsoft will replace this)
- **capabilities: internetClient** - Allows network access
- **architecture: x64** - Universal package for all architectures

## Troubleshooting

### Package Validation Fails

**Error: "Package signature is invalid"**
- ✅ This is expected - the package is unsigned
- ✅ Microsoft will sign it during publishing

**Error: "Unsupported package architecture"**
- Check that architecture is set correctly in msix_config
- Ensure you're using the universal store package

**Error: "Package version conflict"**
- Version number must be higher than previous submissions
- Update version in workflow inputs

### Submission Issues

**Cannot upload package**
- Check file size (must be under 25 GB)
- Ensure it's a .msix file
- Try a different browser

**Certification taking too long**
- Normal time: 24-48 hours
- Peak times: Up to 5 days
- Contact support if > 7 days

## Additional Resources

- [Microsoft Store Policies](https://docs.microsoft.com/en-us/windows/uwp/publish/store-policies)
- [MSIX Packaging](https://docs.microsoft.com/en-us/windows/msix/)
- [Partner Center Documentation](https://docs.microsoft.com/en-us/windows/uwp/publish/)
- [App Certification Requirements](https://docs.microsoft.com/en-us/windows/uwp/publish/the-app-certification-process)

## Support

For questions or issues with:
- **Build workflow**: Open an issue in the GitHub repository
- **Microsoft Store submission**: Contact Microsoft Partner Center support
- **App functionality**: Open an issue in the GitHub repository

---

## Quick Checklist

Before submitting:
- [ ] Microsoft Partner Center account created
- [ ] App name reserved
- [ ] Universal MSIX package downloaded
- [ ] Store listing description written
- [ ] Screenshots prepared (minimum 3)
- [ ] App icon ready (300x300)
- [ ] Privacy policy created (if needed)
- [ ] Pricing and markets configured
- [ ] Age rating completed
- [ ] All required fields filled
- [ ] Package uploaded and validated
- [ ] Submission reviewed
- [ ] Submitted for certification

Good luck with your Microsoft Store submission! 🚀
