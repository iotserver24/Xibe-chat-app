# Custom API Providers Guide

This guide explains how to add and manage custom API providers in Xibe Chat, allowing you to use your own API keys with various AI services.

## Table of Contents

1. [Overview](#overview)
2. [Built-in Providers](#built-in-providers)
3. [Adding Custom Providers](#adding-custom-providers)
4. [Managing Custom Models](#managing-custom-models)
5. [Provider Configuration](#provider-configuration)
6. [Examples](#examples)
7. [Troubleshooting](#troubleshooting)

## Overview

Xibe Chat supports multiple AI providers through a flexible custom provider system. You can:

- Use built-in providers (Xibe, OpenAI, Anthropic, OpenRouter, Together AI, Groq)
- Add your own custom providers
- Configure multiple models per provider
- Switch between models seamlessly during conversations

## Built-in Providers

### Xibe
- **Type**: OpenAI Compatible
- **Base URL**: `https://api.xibe.app`
- **Features**: Multiple models, streaming, vision support
- **API Key**: Optional (default key provided)

### OpenAI
- **Type**: OpenAI Compatible
- **Base URL**: `https://api.openai.com/v1`
- **Features**: GPT models, streaming, vision, tools
- **API Key**: Required - Get from [platform.openai.com](https://platform.openai.com)

### Anthropic
- **Type**: Anthropic
- **Base URL**: `https://api.anthropic.com/v1`
- **Features**: Claude models, streaming
- **API Key**: Required - Get from [console.anthropic.com](https://console.anthropic.com)

### OpenRouter
- **Type**: OpenAI Compatible
- **Base URL**: `https://openrouter.ai/api/v1`
- **Features**: Access to 100+ models from different providers
- **API Key**: Required - Get from [openrouter.ai](https://openrouter.ai)

### Together AI
- **Type**: OpenAI Compatible
- **Base URL**: `https://api.together.xyz/v1`
- **Features**: Open-source models, fast inference
- **API Key**: Required - Get from [together.ai](https://together.ai)

### Groq
- **Type**: OpenAI Compatible
- **Base URL**: `https://api.groq.com/openai/v1`
- **Features**: Ultra-fast inference, open models
- **API Key**: Required - Get from [console.groq.com](https://console.groq.com)

## Adding Custom Providers

### Step 1: Open Custom Providers

1. Navigate to **Settings** → **Custom Providers** → **API Providers**
2. Click the **+** button in the top-right corner

### Step 2: Configure Provider

Fill in the provider details:

- **Provider Name**: Friendly name (e.g., "My OpenAI")
- **Base URL**: API endpoint (e.g., `https://api.openai.com/v1`)
- **API Key**: Your API key for the provider
- **API Type**: 
  - **OpenAI Compatible**: For OpenAI-style APIs
  - **Anthropic**: For Anthropic Claude API

### Step 3: Save

Click **Add** to save your custom provider.

## Managing Custom Models

Once you've added a provider, you need to configure models for it:

### Adding a Model

1. In the Custom Providers list, click the **list icon** next to your provider
2. Click the **+** button to add a model
3. Configure the model:
   - **Display Name**: User-friendly name (e.g., "GPT-4 Turbo")
   - **Model ID**: API model identifier (e.g., `gpt-4-turbo-preview`)
   - **Description**: Brief description
   - **Supports Vision**: Check if model can process images
   - **Supports Streaming**: Check if model supports streaming responses
   - **Supports Tools**: Check if model supports function calling

### Example Model Configurations

#### OpenAI GPT-4 Turbo
```
Display Name: GPT-4 Turbo
Model ID: gpt-4-turbo-preview
Description: Most capable GPT-4 model
Supports Vision: ✓
Supports Streaming: ✓
Supports Tools: ✓
```

#### Anthropic Claude 3.5 Sonnet
```
Display Name: Claude 3.5 Sonnet
Model ID: claude-3-5-sonnet-20241022
Description: Anthropic's most capable model
Supports Vision: ✓
Supports Streaming: ✓
Supports Tools: ✗
```

#### OpenRouter
```
Display Name: Llama 3.1 405B
Model ID: meta-llama/llama-3.1-405b-instruct
Description: Meta's largest Llama model
Supports Vision: ✗
Supports Streaming: ✓
Supports Tools: ✓
```

## Provider Configuration

### OpenAI-Compatible APIs

Most providers use OpenAI-compatible format:

```
Base URL: https://api.example.com/v1
Endpoint: /chat/completions
Headers:
  - Content-Type: application/json
  - Authorization: Bearer YOUR_API_KEY
```

### Anthropic API

Anthropic uses a slightly different format:

```
Base URL: https://api.anthropic.com/v1
Endpoint: /messages
Headers:
  - Content-Type: application/json
  - x-api-key: YOUR_API_KEY
  - anthropic-version: 2023-06-01
```

## Examples

### Example 1: Adding OpenAI

1. Get API key from [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Go to Settings → Custom Providers
3. Find "OpenAI" in the list
4. Click Edit (pencil icon)
5. Enter your API key
6. Click Save
7. Click the list icon to manage models
8. Add models like `gpt-4-turbo-preview`, `gpt-3.5-turbo`, etc.

### Example 2: Adding a Custom LLM API

If you have a custom LLM server running locally:

```
Provider Name: Local LLM
Base URL: http://localhost:8000/v1
API Key: (leave empty if not required)
API Type: OpenAI Compatible
```

Then add a model:
```
Display Name: My Local Model
Model ID: local-llm-7b
Description: Locally hosted 7B parameter model
```

### Example 3: Using OpenRouter

OpenRouter provides access to many models through a single API:

1. Sign up at [openrouter.ai](https://openrouter.ai)
2. Get your API key from the dashboard
3. Edit the OpenRouter provider in Xibe Chat
4. Enter your API key
5. Add models (browse models at [openrouter.ai/models](https://openrouter.ai/models))

Popular OpenRouter models:
- `anthropic/claude-3.5-sonnet`
- `google/gemini-pro-1.5`
- `meta-llama/llama-3.1-405b-instruct`
- `openai/gpt-4-turbo`

## Troubleshooting

### Error: "Provider not found for custom model"

- Ensure the provider is properly configured
- Check that the provider ID matches
- Verify the API key is entered correctly

### Error: "Server returned status code: 401"

- Invalid API key
- API key doesn't have proper permissions
- API key expired

### Error: "Server returned status code: 429"

- Rate limit exceeded
- Check your provider's usage limits
- Consider upgrading your plan

### Streaming not working

- Verify "Supports Streaming" is checked for the model
- Some providers don't support streaming for all models
- Check provider documentation

### Model not appearing in selector

- Ensure model is added to a configured provider
- Provider must have valid API key
- Restart the app if needed

## Best Practices

1. **API Key Security**
   - Never share your API keys
   - Store them securely
   - Rotate keys regularly

2. **Model Selection**
   - Use appropriate models for your tasks
   - Consider cost vs capability
   - Test with cheaper models first

3. **Rate Limits**
   - Be aware of provider rate limits
   - Implement proper error handling
   - Monitor your usage

4. **Testing**
   - Test new providers with simple queries
   - Verify streaming works correctly
   - Check vision support if needed

## API Provider Comparison

| Provider | Models | Speed | Cost | Vision | Tools |
|----------|--------|-------|------|--------|-------|
| OpenAI | GPT-4, GPT-3.5 | Medium | $$$ | ✓ | ✓ |
| Anthropic | Claude | Fast | $$ | ✓ | ✗ |
| OpenRouter | 100+ | Varies | Varies | Varies | Varies |
| Together AI | Open models | Fast | $ | ✗ | ✓ |
| Groq | Open models | Ultra-fast | Free | ✗ | ✗ |
| Xibe | Multiple | Fast | Free/Paid | ✓ | ✓ |

## Need Help?

- Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- Visit provider documentation
- Open an issue on GitHub
- Ask in community discussions

---

For more information, see the [User Guide](USER_GUIDE.md) or [Features Documentation](FEATURES.md).
