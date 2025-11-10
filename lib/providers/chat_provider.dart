import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/ai_model.dart';
import '../models/custom_provider.dart';
import '../models/custom_model.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/custom_provider_service.dart';
import '../services/mcp_client_service.dart';
import '../services/image_generation_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  late ApiService _apiService;
  final McpClientService _mcpClientService = McpClientService();
  final ImageGenerationService _imageGenerationService =
      ImageGenerationService();

  List<Chat> _chats = [];
  Chat? _currentChat;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _error;
  String _streamingContent = '';
  List<AiModel> _availableModels = [];
  List<CustomProvider> _customProviders = [];
  List<CustomModel> _customModels = [];
  String _selectedModel = 'gemini'; // Default model
  String? _systemPrompt;
  String Function()? _memoryContextGetter;
  Future<void> Function(String)? _onMemoryExtracted;
  String? _pendingPrompt;

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String? get error => _error;
  String get streamingContent => _streamingContent;
  List<AiModel> get availableModels => _availableModels;
  String get selectedModel => _selectedModel;
  String? get systemPrompt => _systemPrompt;
  String? get pendingPrompt => _pendingPrompt;

  bool get selectedModelSupportsVision {
    // Check if it's a custom model first
    final customModel = _customModels.firstWhere(
      (m) => m.modelId == _selectedModel,
      orElse: () => CustomModel(
        id: '',
        name: '',
        modelId: '',
        providerId: '',
        description: '',
        endpointUrl: '',
      ),
    );

    if (customModel.modelId.isNotEmpty) {
      return customModel.supportsVision;
    }

    // Otherwise check Xibe models
    final model = _availableModels.firstWhere(
      (m) => m.name == _selectedModel,
      orElse: () => AiModel(
        name: '',
        description: '',
        inputModalities: [],
        outputModalities: [],
        aliases: [],
      ),
    );
    return model.vision == true || model.inputModalities.contains('image');
  }

  ChatProvider({String? apiKey, String? systemPrompt}) {
    _systemPrompt = systemPrompt;
    _initializeApiService(apiKey);
    _loadChats();
    _loadModels();
    _initializeMcp();
  }

  Future<void> _initializeMcp() async {
    try {
      await _mcpClientService.initialize();
    } catch (e) {
      // Silently fail MCP initialization, don't block app startup
      print('Failed to initialize MCP: $e');
    }
  }

  /// Reload MCP configuration and reconnect to servers
  Future<void> reloadMcpServers() async {
    try {
      await _mcpClientService.reload();
      notifyListeners();
    } catch (e) {
      print('Failed to reload MCP servers: $e');
    }
  }

  void _initializeApiService(String? providedApiKey) {
    // Use provided API key from settings, or fallback to hardcoded test API key
    // Note: This test key is hardcoded for development/testing purposes
    String? apiKey = providedApiKey ?? 'XAI_t2o3pFT7JpV026x6vszxpIH55SFcVgjS';
    _apiService = ApiService(apiKey: apiKey);
  }

  void updateApiKey(String? apiKey) {
    _initializeApiService(apiKey);
    _loadModels(); // Reload models with new API key
  }

  void updateSystemPrompt(String? systemPrompt) {
    _systemPrompt = systemPrompt;
    notifyListeners();
  }

  void setMemoryContextGetter(String Function()? getter) {
    _memoryContextGetter = getter;
  }

  void setOnMemoryExtracted(Future<void> Function(String)? callback) {
    _onMemoryExtracted = callback;
  }

  Future<void> _loadModels() async {
    try {
      _availableModels = await _apiService.fetchModels();

      // Add custom Claude 4.5 Haiku model
      final claudeModel = AiModel(
        name: 'claudyclaude', // Model ID used in API calls
        description: 'Claude 4.5 Haiku',
        inputModalities: ['text', 'image'],
        outputModalities: ['text'],
        aliases: ['claude-4.5-haiku', 'claude-haiku'],
        vision: true,
        tools: false,
      );

      // Check if model already exists to avoid duplicates
      if (!_availableModels.any((m) => m.name == 'claudyclaude')) {
        _availableModels.add(claudeModel);
      }

      notifyListeners();
    } catch (e) {
      // Silently fail, use default model
      _availableModels = [];

      // Add custom Claude model even if API fetch fails
      final claudeModel = AiModel(
        name: 'claudyclaude',
        description:
            'Claude 4.5 Haiku - Fast and efficient model with vision support',
        inputModalities: ['text', 'image'],
        outputModalities: ['text'],
        aliases: ['claude 4.5 haiku', 'claude-haiku', 'claude-4.5-haiku'],
        vision: true,
        tools: false,
      );
      _availableModels.add(claudeModel);
      notifyListeners();
    }
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  void updateCustomProviders(
      List<CustomProvider> providers, List<CustomModel> models) {
    _customProviders = providers;
    _customModels = models;
    _loadModels();
    notifyListeners();
  }

  List<Map<String, String>> getAllModels() {
    final models = <Map<String, String>>[];

    for (var xibeModel in _availableModels) {
      models.add({
        'id': xibeModel.name,
        'name': xibeModel.description.isNotEmpty
            ? xibeModel.description
            : xibeModel.name,
        'provider': 'Xibe',
      });
    }

    for (var customModel in _customModels) {
      final provider = _customProviders.firstWhere(
        (p) => p.id == customModel.providerId,
        orElse: () => CustomProvider(
          id: '',
          name: 'Unknown',
          baseUrl: '',
          apiKey: '',
          type: 'openai',
        ),
      );
      models.add({
        'id': customModel.modelId,
        'name': customModel.name,
        'provider': provider.name,
      });
    }

    return models;
  }

  void setPendingPrompt(String? prompt) {
    _pendingPrompt = prompt;
    notifyListeners();
  }

  void clearPendingPrompt() {
    _pendingPrompt = null;
    notifyListeners();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! ☀️';
    } else if (hour < 17) {
      return 'Good afternoon! 🌤️';
    } else {
      return 'Good evening! 🌙';
    }
  }

  Future<void> _loadChats() async {
    final chats = await _databaseService.getAllChats();
    _chats = chats;
    // Don't auto-select any chat - let user or deep link choose
    // This allows app to always open to a new chat state
    notifyListeners();
  }

  Future<void> createNewChat({String? defaultModel}) async {
    final now = DateTime.now();
    // Create a temporary chat that's not yet saved to database
    // It will be saved when the user sends the first message

    // Use default model if provided, otherwise keep current selection
    if (defaultModel != null && defaultModel.isNotEmpty) {
      _selectedModel = defaultModel;
    }

    _currentChat = Chat(
      id: null, // null indicates this chat hasn't been saved yet
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
    );
    _messages = [];
    _error = null;
    _isLoading = false;
    _isStreaming = false;
    _streamingContent = '';

    notifyListeners();
  }

  Future<void> selectChat(Chat chat) async {
    _currentChat = chat;
    _messages = await _databaseService.getMessagesForChat(chat.id!);
    _error = null;
    notifyListeners();
  }

  Future<void> sendMessage(String content,
      {String? imageBase64,
      String? imagePath,
      bool webSearch = false,
      bool reasoning = false,
      bool imageGeneration = false,
      String? imageGenerationModel}) async {
    if (_currentChat == null) {
      await createNewChat();
    }

    // If this is a new chat (id is null), save it to the database first
    if (_currentChat!.id == null) {
      final now = DateTime.now();
      final chat = Chat(
        title: _currentChat!.title,
        createdAt: _currentChat!.createdAt,
        updatedAt: now,
      );
      final id = await _databaseService.createChat(chat);
      _currentChat = Chat(
        id: id,
        title: chat.title,
        createdAt: chat.createdAt,
        updatedAt: chat.updatedAt,
      );
    }

    _error = null;
    final userMessage = Message(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
      chatId: _currentChat!.id!,
      imageBase64: imageBase64,
      imagePath: imagePath,
      webSearchUsed: webSearch,
    );

    final insertedId = await _databaseService.insertMessage(userMessage);
    final messageWithId = Message(
      id: insertedId,
      role: userMessage.role,
      content: userMessage.content,
      timestamp: userMessage.timestamp,
      webSearchUsed: userMessage.webSearchUsed,
      chatId: userMessage.chatId,
      imageBase64: userMessage.imageBase64,
      imagePath: userMessage.imagePath,
    );
    _messages.add(messageWithId);

    // Immediately notify listeners to show the user message in UI
    notifyListeners();

    final isFirstMessage = _messages.length == 1;

    // Set loading state first to show typing indicator
    _isLoading = true;
    _isStreaming = false;
    _streamingContent = '';

    // Track response start time
    final responseStartTime = DateTime.now();

    // Notify to show typing indicator
    notifyListeners();

    try {
      // Get all messages except the user message we just added (last one in the list)
      final history = _messages.where((m) => m.role != 'system').toList();
      final historyForApi = history.length > 1
          ? history.sublist(0, history.length - 1)
          : <Message>[];

      // Get MCP context (available tools and resources)
      String? mcpContext;
      try {
        final context = _mcpClientService.getMcpContext();
        if (context.isNotEmpty) {
          mcpContext = context;
        }
      } catch (e) {
        // Silently fail, continue without MCP context
        print('Error getting MCP context: $e');
      }

      // Get memory context if available
      String? memoryContext;
      if (_memoryContextGetter != null) {
        try {
          memoryContext = _memoryContextGetter!();
        } catch (e) {
          print('Error getting memory context: $e');
        }
      }

      // Base system prompt - always included to inform AI about the app context
      final imageModel = imageGenerationModel ?? 'flux';
      String baseSystemPrompt =
          '''You are running in Xibe Chat, a modern AI chat application created by the user.

APP CONTEXT & CAPABILITIES:
- You are operating within the Xibe Chat desktop/mobile application
- The app provides integrated code execution and preview capabilities
- Users can run code directly within the app interface
- The app supports both computational code execution (E2B sandbox) and visual web previews (CodeSandbox)
- Users have access to MCP (Model Context Protocol) servers for extended functionality
- The app includes a memory system to remember important information across conversations
- Web search capabilities are available when enabled
- Code previews appear in a side panel with live rendering

IMAGE GENERATION:
- You can generate images! When the user requests image generation, respond with: <img-gen>{enhanced_prompt}</img-gen>
- CRITICAL: You MUST use the exact tag format: <img-gen>your prompt here</img-gen>
- DO NOT use <enhanced_prompt> or any other tag format - ONLY use <img-gen>
- The {enhanced_prompt} should be a detailed, descriptive prompt that you create
- Refine and enhance the user's request to be specific about style, colors, composition, mood, and important details
- The default model is $imageModel (flux: high quality, kontext, turbo: fast, gptimage)
- Example: User asks "make me a cat" → You respond: "Here's a beautiful cat image for you: <img-gen>A majestic fluffy orange tabby cat with bright green eyes, sitting elegantly on a velvet cushion, studio lighting, photorealistic, high detail</img-gen>"
- The image will be automatically generated and displayed to the user
- You can add context before and after the <img-gen> tag to enhance the response
- Use this whenever users ask you to create, draw, generate, make, or visualize images

IMPORTANT: Always be aware that you're helping users within this specialized application environment. When providing code examples, leverage the app's built-in execution and preview features to give users the best experience.''';

      // Combine base prompt with user's custom system prompt
      String? enhancedSystemPrompt;
      if (_systemPrompt != null && _systemPrompt!.isNotEmpty) {
        enhancedSystemPrompt =
            '$baseSystemPrompt\n\nUSER CUSTOM SYSTEM PROMPT:\n$_systemPrompt';
      } else {
        enhancedSystemPrompt = baseSystemPrompt;
      }

      // Add memory context first (most important)
      if (memoryContext != null && memoryContext.isNotEmpty) {
        if (enhancedSystemPrompt.isNotEmpty) {
          enhancedSystemPrompt = '$memoryContext\n\n$enhancedSystemPrompt';
        } else {
          enhancedSystemPrompt = memoryContext;
        }
      }

      // Add MCP context
      if (mcpContext != null && mcpContext.isNotEmpty) {
        if (enhancedSystemPrompt.isNotEmpty) {
          enhancedSystemPrompt = '$enhancedSystemPrompt\n\n$mcpContext';
        } else {
          enhancedSystemPrompt = mcpContext;
        }
      }

      // Add code execution and preview capabilities instruction
      const codeExecutionInstruction = '''
CODE EXECUTION & PREVIEW CAPABILITIES:

You have access to TWO powerful sandbox environments for running code:

1. E2B Sandbox (for computational/scripting code - NO frameworks, NO interactive inputs):
   Supported languages: Python, JavaScript, TypeScript, Java, R, Bash
   - Use standard language tags: ```python, ```javascript, ```typescript, ```java, ```r, ```bash
   - Perfect for: data processing, algorithms, calculations, scripts, file operations
   - User will see a "Run" button to execute the code
   - Example: ```python\nprint("Hello")\n```
   
2. CodeSandbox Preview (for visual web UI code - SINGLE OR MULTIPLE FILES):
   Supported frameworks: React, Vue, Angular, Svelte, HTML/CSS/JS
   - CRITICAL: Use language prefix "codesandbox-" + framework name
   - Language tags: ```codesandbox-react, ```codesandbox-vue, ```codesandbox-angular, ```codesandbox-svelte, ```codesandbox-html
   - User will see a "Run Preview" button to view the live UI
   - Perfect for: UI components, interactive demos, web apps, design examples
   
   SINGLE FILE Example:
   ```codesandbox-react
   import React from 'react';
   export default function App() { 
     return <div style={{padding: '20px'}}>Hello World</div>; 
   }
   ```
   
   MULTIPLE FILES Example (when you need separate CSS, config, or component files):
   ```codesandbox-react
   // File: App.js
   import React from 'react';
   import './styles.css';
   
   export default function App() { 
     return <div className="container">Hello World</div>; 
   }
   
   // File: styles.css
   .container {
     padding: 20px;
     background: linear-gradient(to right, #667eea, #764ba2);
     color: white;
     border-radius: 8px;
   }
   
   // File: Button.js
   import React from 'react';
   export default function Button({ children }) {
     return <button className="btn">{children}</button>;
   }
   ```
   
   MULTI-FILE RULES:
   - Use "// File: filename.ext" comments to separate files within ONE code block
   - All files in the same code block will be sent together to CodeSandbox
   - Supported file types: .js, .jsx, .ts, .tsx, .css, .json, .html, .vue, .svelte
   - Common use cases:
     * React component + CSS styling
     * Multiple React components (main + subcomponents)
     * Component + configuration (package.json customization)
     * HTML + CSS + JavaScript for vanilla projects
   - The app will automatically detect file markers and create proper sandbox structure
   
   When to use multiple files:
   ✅ User asks for "a button component with custom styling" → Create Button.js + styles.css
   ✅ User wants "a todo app with separate components" → Create App.js + TodoList.js + TodoItem.js + styles.css
   ✅ Complex UI with external CSS → Create component files + dedicated stylesheet
   ✅ User explicitly asks for "multiple files" or "separate files"
   ❌ Simple one-liner components → Use inline styles, no need for separate CSS
   ❌ Basic examples → Keep it simple with single file

CRITICAL RULES:
- For UI/visual web code → ALWAYS use codesandbox-{framework} language tag
- For computational/backend/script code → Use standard language tags (python, javascript, etc.)
- When users ask for UI examples, interactive demos, or web components → Use codesandbox-{framework}
- When code needs multiple files (CSS, components, config) → Use "// File:" markers in ONE code block
- When users ask to run calculations, scripts, or data processing → Use standard language tags
- NEVER use <codesandbox> tags - ALWAYS use the language prefix system instead
- NEVER create multiple separate code blocks for related files - put them ALL in ONE codesandbox-{framework} block''';

      if (enhancedSystemPrompt.isNotEmpty) {
        enhancedSystemPrompt =
            '$enhancedSystemPrompt\n\n$codeExecutionInstruction';
      } else {
        enhancedSystemPrompt = codeExecutionInstruction;
      }

      // Add web search instruction if web search is enabled
      if (webSearch) {
        const webSearchInstruction = '''
WEB SEARCH MODE:
You have access to real-time web search. When you use web sources to answer the user's question, you must list all the URLs you referenced at the very end of your response in this XML format:
<sources>
https://example.com/page1
https://example.com/page2
https://example.com/page3
</sources>

Important:
- List each URL on a separate line within the <sources> tags
- Only include URLs that you actually referenced in your response
- The <sources> section should be the last thing in your response
- Do not mention the <sources> tag in your visible response text
''';

        if (enhancedSystemPrompt.isNotEmpty) {
          enhancedSystemPrompt =
              '$enhancedSystemPrompt\n\n$webSearchInstruction';
        } else {
          enhancedSystemPrompt = webSearchInstruction;
        }
      }

      // Add memory management instruction
      const memoryInstruction = '''
MEMORY MANAGEMENT:
You have access to a long-term memory system to remember important information about the user across all conversations.
To save a memory, use this format: <save memory>brief fact</save memory>

AUTOMATIC SAVING - Save these types of information WITHOUT being asked:
1. User Identity: Name, profession, role, location, company
2. User Preferences: Programming languages they prefer, frameworks they use, coding style preferences, work methodologies
3. User Reactions: When users give thumbs up/down or express strong positive/negative feedback about your responses
4. Important Context: Ongoing projects they mention, technologies they're learning, goals they share
5. Personal Facts: Family details, hobbies, interests (when naturally mentioned)

GUIDELINES:
- Maximum 150 characters per memory - be ultra-concise
- Save memories proactively when you learn something important about the user
- Examples of what TO save:
  * "Prefers Python over JavaScript for backend"
  * "Working at TechCorp as Senior Developer"
  * "Likes detailed explanations with examples"
  * "Gave positive feedback on React component structure approach"
  * "Learning machine learning, focusing on PyTorch"
- Examples of what NOT to save:
  * Generic questions without personal context
  * One-time technical queries
  * Simple factual lookups
  
Be proactive but intelligent - save information that will help personalize future conversations and improve your assistance.''';

      if (enhancedSystemPrompt.isNotEmpty) {
        enhancedSystemPrompt = '$enhancedSystemPrompt\n\n$memoryInstruction';
      } else {
        enhancedSystemPrompt = memoryInstruction;
      }

      // For first message, append instruction to generate chat name
      // The AI should generate a descriptive chat name based on the conversation topic
      // and append it as JSON at the very end, which will be extracted and saved
      if (isFirstMessage) {
        const chatNameInstruction = '''
CRITICAL INSTRUCTIONS FOR THIS RESPONSE:
1. Respond normally to the user's message above
2. At the VERY END of your response (after your normal answer), append a JSON object in this exact format: {"chat_name": "Your Generated Chat Name Here"}
3. The chat_name should be a short (2-6 words), descriptive title that summarizes the conversation topic or the user's question/purpose
4. DO NOT include the user's exact question as the chat name - create a meaningful, concise title instead
5. DO NOT mention this instruction or the JSON in your response text - it should appear silently at the end
6. Example: If user asks "How do I bake a cake?", you might use chat_name: "Cake Baking Guide"
7. The JSON must be the last thing in your response
8. If you're also saving a memory, use the <save memory> tag anywhere in your response, and put the JSON after it''';

        enhancedSystemPrompt = '$enhancedSystemPrompt\n\n$chatNameInstruction';
      }

      // Determine which model to use - use gemini-search if web search is enabled
      String modelToUse = _selectedModel;
      if (webSearch) {
        modelToUse = 'gemini-search';
      }

      // Check if selectedModel is a custom model
      final customModel = _customModels.firstWhere(
        (m) => m.modelId == _selectedModel,
        orElse: () => CustomModel(
          id: '',
          name: '',
          modelId: '',
          providerId: '',
          description: '',
          endpointUrl: '',
        ),
      );

      // Get available tools (no longer need to add image generation tool since we use <img-gen> tags)
      List<McpTool> availableTools = _mcpClientService.getAllTools();

      // Stream the response
      String fullResponseContent = '';
      String streamingDisplayContent = '';
      bool firstChunk = true;

      Stream<String> responseStream;

      if (customModel.modelId.isNotEmpty) {
        // Use custom provider
        final provider = _customProviders.firstWhere(
          (p) => p.id == customModel.providerId,
          orElse: () => CustomProvider(
            id: '',
            name: '',
            baseUrl: '',
            apiKey: '',
            type: 'openai',
          ),
        );

        if (provider.id.isEmpty) {
          throw Exception('Provider not found for custom model');
        }

        final providerService = CustomProviderService(provider: provider);
        responseStream = providerService.sendMessageStream(
          message: content,
          history: historyForApi,
          modelId: customModel.modelId,
          endpointUrl: customModel.endpointUrl,
          systemPrompt: enhancedSystemPrompt,
          reasoning: reasoning,
          mcpTools: availableTools,
        );
      } else {
        // Use default Xibe API
        responseStream = _apiService.sendMessageStream(
          message: content,
          history: historyForApi,
          model: modelToUse,
          systemPrompt: enhancedSystemPrompt,
          reasoning: reasoning,
          mcpTools: availableTools,
        );
      }

      await for (final chunk in responseStream) {
        // On first chunk, switch from loading to streaming
        if (firstChunk) {
          _isStreaming = true;
          firstChunk = false;
        }

        fullResponseContent += chunk;

        // Filter out img-gen tags immediately during streaming
        String tempContent = fullResponseContent;
        final imgGenPatternStream = RegExp(r'<img-gen>.*?</img-gen>',
            caseSensitive: false, dotAll: true);
        final enhancedPromptPatternStream = RegExp(
            r'<enhanced_prompt>.*?</enhanced_prompt>',
            caseSensitive: false,
            dotAll: true);
        if (imgGenPatternStream.hasMatch(tempContent)) {
          // Replace with loading placeholder
          tempContent = tempContent.replaceAll(
            imgGenPatternStream,
            '\n\n*[Generating image...]*\n',
          );
        }
        // Also handle <enhanced_prompt> as fallback
        if (enhancedPromptPatternStream.hasMatch(tempContent)) {
          tempContent = tempContent.replaceAll(
            enhancedPromptPatternStream,
            '\n\n*[Generating image...]*\n',
          );
        }

        // For first message, filter out chat name JSON from display in real-time
        if (isFirstMessage) {
          // Look for JSON pattern that might appear at the end
          // Try multiple patterns to catch the JSON

          // Pattern 1: Full JSON object with chat_name
          final jsonPattern1 =
              RegExp(r'\{"chat_name"\s*:\s*"[^"]*"\}', caseSensitive: false);
          if (jsonPattern1.hasMatch(tempContent)) {
            tempContent = tempContent.replaceAll(jsonPattern1, '').trim();
          }

          // Pattern 2: Look for {"chat_name" at the start of JSON
          final jsonPattern2 = RegExp(r'\{"chat_name"', caseSensitive: false);
          if (jsonPattern2.hasMatch(tempContent)) {
            final match = jsonPattern2.firstMatch(tempContent);
            if (match != null) {
              // Remove everything from the start of the JSON
              tempContent = tempContent.substring(0, match.start).trim();
            }
          }

          // Pattern 3: Look for any remaining JSON-like patterns at the end
          final jsonPattern3 =
              RegExp(r'\{[^}]*"chat_name"[^}]*\}', caseSensitive: false);
          if (jsonPattern3.hasMatch(tempContent)) {
            tempContent = tempContent.replaceAll(jsonPattern3, '').trim();
          }

          streamingDisplayContent = tempContent;
        } else {
          streamingDisplayContent = tempContent;
        }

        // Update streaming content for display (without chat name JSON and img-gen tags)
        _streamingContent = streamingDisplayContent;
        notifyListeners();
      }

      // Extract image generation request if present using XML-style tags
      String? generatedImageBase64;
      String? generatedImagePrompt;
      String? generatedImageModel;
      bool isGeneratingImage = false;

      // Try <img-gen> tag first (preferred format)
      final imgGenPattern = RegExp(r'<img-gen>(.*?)</img-gen>',
          caseSensitive: false, dotAll: true);
      Match? imgGenMatch = imgGenPattern.firstMatch(fullResponseContent);

      // Fallback to <enhanced_prompt> if AI uses that format
      if (imgGenMatch == null) {
        final enhancedPromptPattern = RegExp(
            r'<enhanced_prompt>(.*?)</enhanced_prompt>',
            caseSensitive: false,
            dotAll: true);
        imgGenMatch = enhancedPromptPattern.firstMatch(fullResponseContent);
        // If we found enhanced_prompt, also update the pattern for replacement
        if (imgGenMatch != null) {
          // Use enhanced_prompt pattern for replacement
          final enhancedPattern = RegExp(
              r'<enhanced_prompt>.*?</enhanced_prompt>',
              caseSensitive: false,
              dotAll: true);
          fullResponseContent = fullResponseContent
              .replaceFirst(
                enhancedPattern,
                '\n\n*[Generated Image]*\n',
              )
              .trim();
        }
      }

      if (imgGenMatch != null) {
        generatedImagePrompt = imgGenMatch.group(1)?.trim();
        if (generatedImagePrompt != null && generatedImagePrompt.isNotEmpty) {
          // Mark that we're generating an image
          isGeneratingImage = true;

          // Update the message in the list to show loading state
          // Note: We'll update it again after processing is complete
          // For now, just mark that we're generating

          try {
            // Get the image generation model from settings
            generatedImageModel = imageGenerationModel ?? 'flux';

            // Generate the image
            final result = await _imageGenerationService.generateImage(
              prompt: generatedImagePrompt,
              model: generatedImageModel,
              width: 1024,
              height: 1024,
            );

            if (result['success'] == true && result['imageBytes'] != null) {
              // Convert image bytes to base64
              generatedImageBase64 = base64Encode(result['imageBytes']);
              isGeneratingImage = false;

              // Remove the img-gen tag from the response and replace with a placeholder
              // Check if we already replaced it (for enhanced_prompt case)
              if (fullResponseContent.contains('<img-gen>') ||
                  fullResponseContent.contains('</img-gen>')) {
                fullResponseContent = fullResponseContent
                    .replaceFirst(
                      imgGenPattern,
                      '\n\n*[Generated Image]*\n',
                    )
                    .trim();
              }
            } else {
              // Image generation failed, show error message
              isGeneratingImage = false;
              fullResponseContent = fullResponseContent
                  .replaceFirst(
                    imgGenPattern,
                    '\n\n*[Image generation failed: ${result['error'] ?? 'Unknown error'}]*\n',
                  )
                  .trim();
            }
          } catch (e) {
            print('Error generating image: $e');
            isGeneratingImage = false;
            // Replace with error message
            fullResponseContent = fullResponseContent
                .replaceFirst(
                  imgGenPattern,
                  '\n\n*[Image generation error: $e]*\n',
                )
                .trim();
          }
        }
      }

      // Extract sources from web search if present using XML-style tags
      List<String> extractedSources = [];
      if (webSearch) {
        final sourcesPattern = RegExp(r'<sources>(.*?)</sources>',
            caseSensitive: false, dotAll: true);
        final sourcesMatch = sourcesPattern.firstMatch(fullResponseContent);

        if (sourcesMatch != null) {
          final sourcesContent = sourcesMatch.group(1)?.trim();
          if (sourcesContent != null && sourcesContent.isNotEmpty) {
            // Extract URLs from the sources content (one per line)
            extractedSources = sourcesContent
                .split('\n')
                .map((line) => line.trim())
                .where((line) =>
                    line.isNotEmpty &&
                    (line.startsWith('http://') || line.startsWith('https://')))
                .toList();

            // Remove the sources tag from the response
            fullResponseContent =
                fullResponseContent.replaceFirst(sourcesPattern, '').trim();

            // Add formatted sources to the end of the response
            if (extractedSources.isNotEmpty) {
              final sourcesFormatted =
                  '\n\n**Sources:**\n${extractedSources.map((url) => '• $url').join('\n')}';
              fullResponseContent = '$fullResponseContent$sourcesFormatted';
            }
          }
        }
      }

      // Extract memory from full response if present using XML-style tags
      String? extractedMemory;
      // Try to find memory tag - look for the first occurrence
      final memoryPattern = RegExp(r'<save\s+memory>(.*?)</save\s+memory>',
          caseSensitive: false, dotAll: true);
      final memoryMatch = memoryPattern.firstMatch(fullResponseContent);

      if (memoryMatch != null) {
        extractedMemory = memoryMatch.group(1)?.trim();
        // Replace the memory tag with a visible confirmation message
        final confirmationMessage = '✅ *Memory saved: "$extractedMemory"*';
        fullResponseContent = fullResponseContent
            .replaceFirst(memoryPattern, confirmationMessage)
            .trim();

        // Save memory if callback is set and within character limit
        if (_onMemoryExtracted != null &&
            extractedMemory != null &&
            extractedMemory.isNotEmpty) {
          try {
            await _onMemoryExtracted!(extractedMemory);
          } catch (e) {
            print('Error saving memory: $e');
          }
        }
      }

      // Extract chat name from full response if it's the first message
      String displayContent = fullResponseContent;
      String? extractedChatName;

      if (isFirstMessage) {
        // Try multiple patterns to extract chat name from JSON
        // Pattern 1: Standard JSON format {"chat_name": "name"}
        RegExp jsonPattern1 =
            RegExp(r'\{"chat_name"\s*:\s*"([^"]+)"\}', caseSensitive: false);
        Match? match = jsonPattern1.firstMatch(fullResponseContent);

        if (match != null) {
          extractedChatName = match.group(1);
          // Remove the JSON part from display content
          displayContent = fullResponseContent.substring(0, match.start).trim();
        } else {
          // Pattern 2: JSON with potential whitespace variations
          RegExp jsonPattern2 = RegExp(r'\{\s*"chat_name"\s*:\s*"([^"]+)"\s*\}',
              caseSensitive: false);
          match = jsonPattern2.firstMatch(fullResponseContent);

          if (match != null) {
            extractedChatName = match.group(1);
            displayContent =
                fullResponseContent.substring(0, match.start).trim();
          } else {
            // Pattern 3: Look for chat_name with any quotes
            RegExp jsonPattern3 =
                RegExp(r'"chat_name"\s*:\s*"([^"]+)"', caseSensitive: false);
            match = jsonPattern3.firstMatch(fullResponseContent);

            if (match != null) {
              extractedChatName = match.group(1);
              displayContent =
                  fullResponseContent.substring(0, match.start).trim();
            } else {
              // Pattern 4: Single quotes
              RegExp jsonPattern4 =
                  RegExp(r"'chat_name'\s*:\s*'([^']+)'", caseSensitive: false);
              match = jsonPattern4.firstMatch(fullResponseContent);

              if (match != null) {
                extractedChatName = match.group(1);
                displayContent =
                    fullResponseContent.substring(0, match.start).trim();
              }
            }
          }
        }

        // Clean up display content - remove any remaining JSON artifacts
        displayContent = displayContent
            .replaceAll(
                RegExp(r'\{"chat_name"[^\}]*\}', caseSensitive: false), '')
            .replaceAll(
                RegExp(r'\{[^}]*"chat_name"[^}]*\}', caseSensitive: false), '')
            .replaceAll(
                RegExp(r'\{[^}]*chat_name[^}]*\}', caseSensitive: false), '')
            .trim();

        // If no chat name was extracted, generate one based on the response content
        // This ensures we always have a meaningful name, not the user's input
        if (extractedChatName == null || extractedChatName.isEmpty) {
          // Generate a name from the first sentence or key words in the response
          final words = displayContent
              .split(RegExp(r'\s+'))
              .where((w) => w.length > 3)
              .take(4)
              .toList();
          if (words.isNotEmpty) {
            extractedChatName = words.join(' ');
            // Limit length
            if (extractedChatName.length > 50) {
              extractedChatName = '${extractedChatName.substring(0, 47)}...';
            }
          } else {
            // Ultimate fallback - generic descriptive name
            extractedChatName = 'New Conversation';
          }
        }

        // Update chat title with extracted/generated name (never show user's input as title)
        _currentChat = Chat(
          id: _currentChat!.id,
          title: extractedChatName,
          createdAt: _currentChat!.createdAt,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateChat(_currentChat!);
        await _loadChats();
      }

      // Calculate response time
      final responseEndTime = DateTime.now();
      final responseTimeMs =
          responseEndTime.difference(responseStartTime).inMilliseconds;

      // Save the response with cleaned content (without chat name JSON)
      final assistantMessage = Message(
        role: 'assistant',
        content: displayContent,
        timestamp: DateTime.now(),
        webSearchUsed: webSearch,
        chatId: _currentChat!.id!,
        responseTimeMs: responseTimeMs,
        generatedImageBase64: generatedImageBase64,
        generatedImagePrompt: generatedImagePrompt,
        generatedImageModel: generatedImageModel,
        isGeneratingImage: isGeneratingImage,
      );

      final assistantInsertedId =
          await _databaseService.insertMessage(assistantMessage);
      final assistantMessageWithId = Message(
        id: assistantInsertedId,
        role: assistantMessage.role,
        content: assistantMessage.content,
        timestamp: assistantMessage.timestamp,
        webSearchUsed: assistantMessage.webSearchUsed,
        chatId: assistantMessage.chatId,
        responseTimeMs: assistantMessage.responseTimeMs,
        generatedImageBase64: assistantMessage.generatedImageBase64,
        generatedImagePrompt: assistantMessage.generatedImagePrompt,
        generatedImageModel: assistantMessage.generatedImageModel,
        isGeneratingImage: assistantMessage.isGeneratingImage,
      );
      _messages.add(assistantMessageWithId);

      // Update chat's updatedAt timestamp if not already updated
      if (!isFirstMessage) {
        _currentChat = Chat(
          id: _currentChat!.id,
          title: _currentChat!.title,
          createdAt: _currentChat!.createdAt,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateChat(_currentChat!);
        await _loadChats();
      }

      _streamingContent = '';
    } catch (e) {
      _error = e.toString();
      _streamingContent = '';
    } finally {
      _isLoading = false;
      _isStreaming = false;
      notifyListeners();
    }
  }

  Future<void> renameChat(int chatId, String newTitle) async {
    final chat = _chats.firstWhere((c) => c.id == chatId);
    final updatedChat = Chat(
      id: chat.id,
      title: newTitle,
      createdAt: chat.createdAt,
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateChat(updatedChat);
    if (_currentChat?.id == chatId) {
      _currentChat = updatedChat;
    }
    await _loadChats();
    notifyListeners();
  }

  Future<void> deleteChat(int chatId) async {
    await _databaseService.deleteChat(chatId);
    if (_currentChat?.id == chatId) {
      _currentChat = null;
      _messages = [];
    }
    await _loadChats();
    notifyListeners();
  }

  Future<void> deleteAllChats() async {
    await _databaseService.deleteAllChats();
    _currentChat = null;
    _messages = [];
    await _loadChats();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> setMessageReaction(int messageId, String? reaction) async {
    await _databaseService.updateMessageReaction(messageId, reaction);
    // Update in memory
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      _messages[index] = Message(
        id: message.id,
        role: message.role,
        content: message.content,
        timestamp: message.timestamp,
        webSearchUsed: message.webSearchUsed,
        chatId: message.chatId,
        imageBase64: message.imageBase64,
        imagePath: message.imagePath,
        thinkingContent: message.thinkingContent,
        isThinking: message.isThinking,
        responseTimeMs: message.responseTimeMs,
        reaction: reaction,
        generatedImageBase64: message.generatedImageBase64,
        generatedImagePrompt: message.generatedImagePrompt,
        generatedImageModel: message.generatedImageModel,
        isGeneratingImage: message.isGeneratingImage,
      );
      notifyListeners();
    }
  }
}
