# Xibe Chat User Guide

Complete guide to using Xibe Chat and all its features.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Basic Chat](#basic-chat)
3. [AI Models](#ai-models)
4. [Advanced Features](#advanced-features)
5. [Settings](#settings)

## Getting Started

### First Launch

When you first launch Xibe Chat:

1. The app opens to a new chat
2. Default model is pre-selected (Gemini)
3. You can start chatting immediately
4. No API key required for default Xibe models

### Interface Overview

#### Mobile/Tablet
- **Menu button** (☰): Access chat history and settings
- **Model selector** (🤖): Choose AI model
- **Chat area**: View messages
- **Input bar**: Type messages and attach images

#### Desktop
- **Left sidebar**: Chat history (always visible)
- **Top bar**: Chat title, model selector, settings
- **Chat area**: Messages with smooth scrolling
- **Bottom bar**: Message input with rich features

## Basic Chat

### Starting a Conversation

1. Type your message in the input field
2. Press Enter (desktop) or Send button (mobile)
3. Wait for the AI's response (streaming in real-time)

### Message Features

- **Text messages**: Standard chat messages
- **Code blocks**: Automatically highlighted with language detection
- **Markdown**: Supports bold, italic, lists, etc.
- **Links**: Clickable URLs
- **Images**: Attached images (vision models only)

### Chat Management

#### Creating New Chats
- Tap the "+" button or select "New Chat" from menu
- Chats are automatically saved on first message
- Chat titles are auto-generated based on content

#### Renaming Chats
- Tap the edit icon next to chat name
- Enter new name
- Changes save automatically

#### Deleting Chats
- Swipe left on chat (mobile) or click delete icon
- Confirm deletion
- This action cannot be undone

## AI Models

### Selecting a Model

1. Tap the robot icon (🤖) in the top bar
2. Browse available models
3. Tap to select a model
4. New selection applies immediately

### Built-in Models

**Xibe Models** (Default)
- Gemini: Fast, general-purpose
- Claude: Advanced reasoning
- GPT-4: Most capable
- And more...

**Custom Models**
- OpenAI GPT models
- Anthropic Claude
- OpenRouter models
- Your own custom providers

### Model Capabilities

Check model descriptions for:
- **Vision**: Can process images
- **Streaming**: Real-time responses
- **Tools**: Function calling support

## Advanced Features

### Vision (Image Input)

**Supported Models**: GPT-4 Vision, Gemini Vision, Claude

1. Click the image icon in input bar
2. Select image from device
3. Image appears as preview
4. Add your question/prompt
5. Send message

**Tips**:
- Works best with clear, well-lit images
- Describe what you want to know
- Can analyze charts, diagrams, screenshots, photos

### Web Search Mode

Enable real-time web search for current information:

1. Click the globe icon in input bar
2. Ask your question
3. AI will search the web and cite sources
4. Sources appear as clickable links

**Best for**:
- Current events
- Recent information
- Real-time data
- Fact-checking

### Reasoning Mode (Think)

Enable deep reasoning for complex problems:

1. Click the brain icon in input bar
2. Ask your question
3. AI will think step-by-step
4. See detailed reasoning process

**Best for**:
- Math problems
- Logic puzzles
- Complex analysis
- Step-by-step explanations

### Code Execution

**E2B Sandbox**: Run code directly

Supported languages: Python, JavaScript, TypeScript, Java, R, Bash

```python
# AI can generate and run code
print("Hello, World!")
for i in range(5):
    print(f"Count: {i}")
```

Click "Run" button on code blocks to execute.

**CodeSandbox Preview**: Live UI previews

For React, Vue, Angular, Svelte, HTML:

```codesandbox-react
import React from 'react';
export default function App() {
  return <div>Hello World</div>;
}
```

Click "Run Preview" to see live result.

### Memory System

AI automatically remembers:
- Your name and details
- Preferences and interests
- Project context
- Feedback and reactions

**Viewing Memories**:
- Settings → Long-Term Memory
- See all saved memories
- Edit or delete memories
- 1000 character limit total

**How It Works**:
- AI saves memories automatically
- No action needed from you
- Memories persist across chats
- Used to personalize responses

### AI Profiles

Customize AI behavior with profiles:

**Built-in Profiles**:
- Default: Balanced assistant
- Creative: Imaginative and artistic
- Professional: Formal and precise
- Casual: Friendly and conversational
- Technical: Developer-focused

**Custom Profiles**:
1. Settings → AI Profiles
2. Create new profile
3. Set name and system prompt
4. Apply profile

**Profile Features**:
- Affects AI personality
- Combines with custom system prompt
- Switch anytime
- Create unlimited profiles

### Model Context Protocol (MCP)

Connect external tools and resources:

1. Settings → Integrations → MCP Servers
2. Configure MCP servers
3. AI can access tools/resources
4. Seamless integration

**Use Cases**:
- Database queries
- API interactions
- File system access
- External service integration

## Settings

### API Configuration

**Xibe API Key**:
- Optional for enhanced features
- Get from [xibe.app](https://xibe.app)
- Enter in Settings → API Configuration

**Custom System Prompt**:
- Override default AI behavior
- Max 1000 characters
- Combines with AI profile

### Custom Providers

Add your own AI providers:

1. Settings → Custom Providers
2. Add new provider
3. Configure API key and models
4. Use in chat

See [Custom Providers Guide](CUSTOM_PROVIDERS.md) for details.

### Appearance

**Theme Selection**:
- Dark (default)
- Light
- System
- Custom themes

**UI Preferences**:
- Font size
- Message density
- Animation speed

### Advanced Settings

**Temperature**: Control randomness (0.0 - 2.0)
**Top P**: Nucleus sampling (0.0 - 1.0)
**Frequency Penalty**: Reduce repetition (0.0 - 2.0)
**Presence Penalty**: Encourage new topics (0.0 - 2.0)

### Data Management

**Clear All Chats**:
- Settings → Data → Clear All Chats
- Permanently deletes all conversations
- Cannot be undone

**Export Data** (Coming Soon):
- Export chat history
- Backup memories
- Portable format

### Donation

Support development:

1. Settings → Support → Donate
2. Choose amount (INR or USD)
3. Complete payment via Razorpay
4. Thank you for your support!

## Keyboard Shortcuts (Desktop)

- **Ctrl/Cmd + N**: New chat
- **Ctrl/Cmd + K**: Focus search
- **Ctrl/Cmd + ,**: Open settings
- **Ctrl/Cmd + Enter**: Send message
- **Escape**: Cancel current action

## Tips & Tricks

### Getting Better Responses

1. **Be specific**: Clear questions get clear answers
2. **Provide context**: More context = better responses
3. **Use examples**: Show what you want
4. **Iterate**: Refine based on responses

### Using Multiple Models

- Try different models for same question
- Compare responses
- Use specialized models for specific tasks
- Switch mid-conversation

### Managing Long Conversations

- Create new chats for new topics
- Use memory for persistent context
- Reference earlier messages
- Break complex topics into parts

### Privacy & Security

- Messages are processed by AI providers
- API keys stored locally (encrypted)
- No data sold to third parties
- Read privacy policy for details

## Troubleshooting

### Common Issues

**Model not responding**:
- Check internet connection
- Verify API key (if custom provider)
- Try different model
- Check provider status

**Slow responses**:
- Normal for complex queries
- Try smaller model
- Check internet speed
- Provider may be busy

**Image not sending**:
- Ensure model supports vision
- Check image format (JPG, PNG)
- Reduce image size
- Try different image

**Code not executing**:
- Check language support
- Verify code syntax
- E2B backend may be updating
- Try again in a moment

### Getting Help

- Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- Visit [FAQ](FAQ.md)
- Open GitHub issue
- Community discussions

## What's Next?

- Explore [Custom Providers](CUSTOM_PROVIDERS.md)
- Read [Features Documentation](FEATURES.md)
- Check [Architecture](ARCHITECTURE.md)
- Contribute [Development Guide](DEVELOPMENT.md)

---

Happy chatting! 🚀
