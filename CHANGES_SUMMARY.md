# Changes Summary - Code Execution & Memory System Updates

## Overview
This update addresses three main issues:
1. AI now automatically saves user information, preferences, and reactions in memory
2. AI is fully aware of code sandbox capabilities for UI previews
3. AI understands when to use E2B execution vs CodeSandbox previews

## Changes Made

### 1. Memory System Enhancement (`lib/providers/chat_provider.dart`)

**Previous Behavior:**
- AI only saved memories when explicitly asked
- Very restrictive rules (only critical personal info)
- Maximum 1-2 saves per conversation

**New Behavior:**
- AI proactively saves important user information WITHOUT being asked
- Automatically saves:
  - User identity (name, profession, role, location, company)
  - User preferences (languages, frameworks, coding styles, methodologies)
  - User reactions (thumbs up/down, positive/negative feedback)
  - Important context (ongoing projects, learning goals)
  - Personal facts (when naturally mentioned)

**Implementation:**
Updated the memory instruction in the system prompt (lines 378-405) to encourage proactive memory saving while maintaining intelligence about what's worth remembering.

### 2. Code Execution & Preview System (`lib/providers/chat_provider.dart`)

**Enhanced System Prompt:**
The AI now has comprehensive knowledge about both execution methods:

**E2B Code Execution:**
- For computational/script code
- Supported languages: Python, JavaScript, TypeScript, Java, R, Bash
- Code blocks automatically get a "Run" button in the UI
- Perfect for: data processing, algorithms, calculations, scripts

**CodeSandbox Preview:**
- For single-page UI code
- Supported frameworks: React, Vue, Angular, Svelte, Preact, SolidJS, HTML/CSS/JS
- Code wrapped in `<codesandbox>` tags gets a "Run Preview" button
- Perfect for: UI components, interactive demos, web apps, design examples

**Format Example:**
```
<codesandbox>
import React from 'react';
export default function App() {
  return <div>Hello World</div>;
}
</codesandbox>
```

**Implementation:**
Updated code execution instruction (lines 317-345) with detailed information about both systems, when to use each, and how to format code properly.

### 3. AI Profile Updates (`lib/models/ai_profile.dart`)

**Updated All 8 Default Profiles:**
Each profile now includes guidance about code execution and preview:

1. **Socratic Tutor** - Added code formatting guidelines
2. **Creative Writer** - Added interactive writing tools guidance  
3. **Strict Coder** - Enhanced with clear UI vs backend code instructions
4. **Friendly Assistant** - Updated code sharing guidelines
5. **Professional Analyst** - Added data visualization instructions
6. **Mindfulness Coach** - Added interactive tools guidance
7. **Debugging Expert** - Added bug fix code formatting instructions
8. **Brief & Direct** - Concise code formatting note

## How It Works

### Memory Saving Flow:
1. User shares information (e.g., "I prefer Python")
2. AI recognizes this as valuable preference information
3. AI includes `<save memory>Prefers Python for development</save memory>` in response
4. System extracts and saves the memory automatically
5. Memory is included in future conversations automatically

### Code Execution Flow:
1. User asks for computational code (e.g., "sort this array")
2. AI provides code in regular code blocks: ` ```python ... ``` `
3. UI automatically shows "Run" button
4. User clicks, code executes via E2B backend

### Code Preview Flow:
1. User asks for UI code (e.g., "create a button component")
2. AI wraps code in `<codesandbox>` tags
3. UI detects tags and shows "Run Preview" button
4. User clicks, preview opens in full-screen webview

## Testing Recommendations

1. **Test Memory Saving:**
   - Start new chat and mention preferences
   - Check if memory is automatically saved without asking
   - Give thumbs up/down reactions and verify they're remembered

2. **Test E2B Execution:**
   - Ask for Python/JavaScript algorithms
   - Verify "Run" button appears
   - Test execution works properly

3. **Test CodeSandbox Preview:**
   - Ask for React/Vue/HTML components
   - Verify `<codesandbox>` tags are used
   - Verify "Run Preview" button appears
   - Test preview opens and renders correctly

## Files Modified

1. `/lib/providers/chat_provider.dart` - Enhanced system prompts
2. `/lib/models/ai_profile.dart` - Updated all 8 default AI profiles

## No Breaking Changes

All changes are additive and enhance existing functionality:
- Memory system still works the same way, just more proactive
- Code execution unchanged, AI just knows about it better
- CodeSandbox service unchanged, AI just uses it correctly now
- All existing conversations and data remain compatible
