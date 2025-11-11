import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';
import '../models/ai_profile.dart';
import '../models/custom_provider.dart';
import '../models/custom_model.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../services/cloud_sync_service.dart';

class SettingsProvider extends ChangeNotifier {
  // Memory limits
  static const int maxTotalMemoryCharacters = 1000;
  static const int maxSingleMemoryCharacters = 200;
  SharedPreferences? _prefs;
  final DatabaseService _databaseService = DatabaseService();
  String? _apiKey;
  String? _systemPrompt;
  String? _defaultModel; // Default model for new chats
  String? _imageGenerationModel; // Image generation model
  String? _e2bApiKey; // Kept for backward compatibility, not required anymore
  String? _e2bBackendUrl; // Backend URL (optional - can use env var)
  double _temperature = 0.7;
  int _maxTokens = 2048;
  double _topP = 1.0;
  double _frequencyPenalty = 0.0;
  double _presencePenalty = 0.0;
  String _updateChannel = 'stable'; // 'stable' or 'beta'
  List<Memory> _memories = [];
  int _cachedTotalMemoryCharacters = 0;
  List<AiProfile> _aiProfiles = [];
  String? _selectedAiProfileId;
  List<CustomProvider> _customProviders = [];
  List<CustomModel> _customModels = [];
  final CloudSyncService _cloudSyncService = CloudSyncService();
  String? _currentUserId;

  String? get apiKey => _apiKey;
  String? get systemPrompt => _systemPrompt;
  String? get defaultModel => _defaultModel;
  String get imageGenerationModel => _imageGenerationModel ?? 'turbo';
  String? get e2bApiKey =>
      _e2bApiKey; // Deprecated - kept for backward compatibility
  String? get e2bBackendUrl => _e2bBackendUrl;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  double get topP => _topP;
  double get frequencyPenalty => _frequencyPenalty;
  double get presencePenalty => _presencePenalty;
  String get updateChannel => _updateChannel;
  List<Memory> get memories => _memories;
  List<AiProfile> get aiProfiles => _aiProfiles;
  String? get selectedAiProfileId => _selectedAiProfileId;
  List<CustomProvider> get customProviders => _customProviders;
  List<CustomModel> get customModels => _customModels;

  // Set current user ID for cloud sync
  void setUserId(String? userId) {
    _currentUserId = userId;
    if (userId != null) {
      _loadSettingsFromCloud(userId);
    }
  }

  SettingsProvider() {
    _loadSettings();
    _loadMemories();
    _loadAiProfiles();
    _loadCustomProviders();
    _loadCustomModels();
  }

  // Load settings from cloud
  Future<void> _loadSettingsFromCloud(String userId) async {
    try {
      final cloudSettings = await _cloudSyncService.fetchUserSettings(userId);
      if (cloudSettings != null) {
        // Merge cloud settings with local (cloud takes precedence)
        if (cloudSettings.apiKey != null) {
          _apiKey = cloudSettings.apiKey;
          await _prefs?.setString('xibe_api_key', _apiKey!);
        }
        if (cloudSettings.systemPrompt != null) {
          _systemPrompt = cloudSettings.systemPrompt;
          await _prefs?.setString('system_prompt', _systemPrompt!);
        }
        if (cloudSettings.defaultModel != null) {
          _defaultModel = cloudSettings.defaultModel;
          await _prefs?.setString('default_model', _defaultModel!);
        }
        if (cloudSettings.imageGenerationModel != null) {
          _imageGenerationModel = cloudSettings.imageGenerationModel;
          await _prefs?.setString('image_generation_model', _imageGenerationModel!);
        }
        _temperature = cloudSettings.temperature;
        _maxTokens = cloudSettings.maxTokens;
        _topP = cloudSettings.topP;
        _frequencyPenalty = cloudSettings.frequencyPenalty;
        _presencePenalty = cloudSettings.presencePenalty;
        _updateChannel = cloudSettings.updateChannel;
        _selectedAiProfileId = cloudSettings.selectedAiProfileId;
        
        // Load AI profiles, custom providers, and models from cloud
        if (cloudSettings.aiProfiles.isNotEmpty) {
          _aiProfiles = cloudSettings.aiProfiles
              .map((json) => AiProfile.fromJson(json))
              .toList();
          await _saveAiProfiles();
        }
        if (cloudSettings.customProviders.isNotEmpty) {
          _customProviders = cloudSettings.customProviders
              .map((json) => CustomProvider.fromJson(json))
              .toList();
          await _saveCustomProviders();
        }
        if (cloudSettings.customModels.isNotEmpty) {
          _customModels = cloudSettings.customModels
              .map((json) => CustomModel.fromJson(json))
              .toList();
          await _saveCustomModels();
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading settings from cloud: $e');
    }
  }

  // Sync all settings to cloud (public method)
  Future<void> syncSettingsToCloud() async {
    if (_currentUserId == null) return;

    try {
      final settings = UserSettings(
        apiKey: _apiKey,
        systemPrompt: _systemPrompt,
        defaultModel: _defaultModel,
        imageGenerationModel: _imageGenerationModel,
        temperature: _temperature,
        maxTokens: _maxTokens,
        topP: _topP,
        frequencyPenalty: _frequencyPenalty,
        presencePenalty: _presencePenalty,
        updateChannel: _updateChannel,
        selectedAiProfileId: _selectedAiProfileId,
        aiProfiles: _aiProfiles.map((p) => p.toJson()).toList(),
        // Only sync custom (non-built-in) providers with their API keys
        // Built-in providers don't need to be synced as they're always available
        customProviders: _customProviders
            .where((p) => !p.isBuiltIn) // Only sync non-built-in providers
            .map((p) => p.toJson()) // Include all fields including apiKey
            .toList(),
        customModels: _customModels.map((m) => m.toJson()).toList(),
        lastSyncedAt: DateTime.now(),
      );
      await _cloudSyncService.saveUserSettings(_currentUserId!, settings);
    } catch (e) {
      print('Error syncing settings to cloud: $e');
    }
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs?.getString('xibe_api_key');
    _systemPrompt = _prefs?.getString('system_prompt');
    _defaultModel = _prefs?.getString('default_model');
    _imageGenerationModel = _prefs?.getString('image_generation_model');
    _e2bApiKey = _prefs?.getString('e2b_api_key'); // Deprecated
    _e2bBackendUrl = _prefs?.getString('e2b_backend_url');
    _temperature = _prefs?.getDouble('temperature') ?? 0.7;
    _maxTokens = _prefs?.getInt('max_tokens') ?? 2048;
    _topP = _prefs?.getDouble('top_p') ?? 1.0;
    _frequencyPenalty = _prefs?.getDouble('frequency_penalty') ?? 0.0;
    _presencePenalty = _prefs?.getDouble('presence_penalty') ?? 0.0;
    _updateChannel = _prefs?.getString('update_channel') ?? 'stable';
    notifyListeners();
  }

  Future<void> setApiKey(String? key) async {
    _apiKey = key;
    if (key != null && key.isNotEmpty) {
      await _prefs?.setString('xibe_api_key', key);
    } else {
      await _prefs?.remove('xibe_api_key');
    }
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setSystemPrompt(String? prompt) async {
    _systemPrompt = prompt;
    if (prompt != null && prompt.isNotEmpty) {
      await _prefs?.setString('system_prompt', prompt);
    } else {
      await _prefs?.remove('system_prompt');
    }
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setDefaultModel(String? modelId) async {
    _defaultModel = modelId;
    if (modelId != null && modelId.isNotEmpty) {
      await _prefs?.setString('default_model', modelId);
    } else {
      await _prefs?.remove('default_model');
    }
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setImageGenerationModel(String model) async {
    _imageGenerationModel = model;
    await _prefs?.setString('image_generation_model', model);
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setE2bApiKey(String? key) async {
    _e2bApiKey = key;
    if (key != null && key.isNotEmpty) {
      await _prefs?.setString('e2b_api_key', key);
    } else {
      await _prefs?.remove('e2b_api_key');
    }
    notifyListeners();
  }

  Future<void> setE2bBackendUrl(String? url) async {
    _e2bBackendUrl = url;
    if (url != null && url.isNotEmpty) {
      await _prefs?.setString('e2b_backend_url', url);
    } else {
      await _prefs?.remove('e2b_backend_url');
    }
    notifyListeners();
  }

  Future<void> setTemperature(double value) async {
    _temperature = value;
    await _prefs?.setDouble('temperature', value);
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setMaxTokens(int value) async {
    _maxTokens = value;
    await _prefs?.setInt('max_tokens', value);
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setTopP(double value) async {
    _topP = value;
    await _prefs?.setDouble('top_p', value);
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setFrequencyPenalty(double value) async {
    _frequencyPenalty = value;
    await _prefs?.setDouble('frequency_penalty', value);
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setPresencePenalty(double value) async {
    _presencePenalty = value;
    await _prefs?.setDouble('presence_penalty', value);
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setUpdateChannel(String channel) async {
    if (channel == 'stable' || channel == 'beta') {
      _updateChannel = channel;
      await _prefs?.setString('update_channel', channel);
      await syncSettingsToCloud();
      notifyListeners();
    }
  }

  // Memory management
  Future<void> _loadMemories() async {
    _memories = await _databaseService.getAllMemories();
    _updateCachedTotalCharacters();
    notifyListeners();
  }

  void _updateCachedTotalCharacters() {
    _cachedTotalMemoryCharacters =
        _memories.fold(0, (sum, memory) => sum + memory.content.length);
  }

  Future<void> addMemory(String content) async {
    final now = DateTime.now();
    final memory = Memory(
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    await _databaseService.insertMemory(memory);
    await _loadMemories();
  }

  Future<void> updateMemoryContent(int memoryId, String content) async {
    final memory = _memories.firstWhere((m) => m.id == memoryId);
    final updatedMemory = memory.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateMemory(updatedMemory);
    await _loadMemories();
  }

  Future<void> deleteMemory(int memoryId) async {
    await _databaseService.deleteMemory(memoryId);
    await _loadMemories();
  }

  int getTotalMemoryCharacters() {
    return _cachedTotalMemoryCharacters;
  }

  String getMemoriesContext() {
    if (_memories.isEmpty) return '';

    final memoryPoints = _memories.map((m) => '- ${m.content}').join('\n');
    return 'User Memory (Important context about the user):\n$memoryPoints';
  }

  // AI Profile management
  Future<void> _loadAiProfiles() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final profilesJson = _prefs?.getStringList('ai_profiles') ?? [];

      if (profilesJson.isEmpty) {
        // Initialize with default profiles
        final defaultProfiles = AiProfile.getDefaultProfiles();
        _aiProfiles = defaultProfiles;
        await _saveAiProfiles();
        // Don't auto-select a profile on first load - make it optional
        _selectedAiProfileId = null;
      } else {
        _aiProfiles = profilesJson
            .map((json) => AiProfile.fromJson(jsonDecode(json)))
            .toList();
        _selectedAiProfileId = _prefs?.getString('selected_ai_profile_id');
        // If empty string was stored, treat as null
        if (_selectedAiProfileId != null && _selectedAiProfileId!.isEmpty) {
          _selectedAiProfileId = null;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error loading AI profiles: $e');
      _aiProfiles = [];
    }
  }

  Future<void> _saveAiProfiles() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final profilesJson =
          _aiProfiles.map((p) => jsonEncode(p.toJson())).toList();
      await _prefs?.setStringList('ai_profiles', profilesJson);
    } catch (e) {
      print('Error saving AI profiles: $e');
    }
  }

  Future<void> addAiProfile(AiProfile profile) async {
    _aiProfiles.add(profile);
    await _saveAiProfiles();
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> deleteAiProfile(String profileId) async {
    _aiProfiles.removeWhere((p) => p.id == profileId);
    if (_selectedAiProfileId == profileId) {
      _selectedAiProfileId =
          _aiProfiles.isNotEmpty ? _aiProfiles.first.id : null;
      await _prefs?.setString(
          'selected_ai_profile_id', _selectedAiProfileId ?? '');
    }
    await _saveAiProfiles();
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> setSelectedAiProfileId(String? profileId) async {
    _selectedAiProfileId = profileId;
    await _prefs?.setString('selected_ai_profile_id', profileId ?? '');
    await syncSettingsToCloud();
    notifyListeners();
  }

  AiProfile? getSelectedAiProfile() {
    if (_selectedAiProfileId == null) return null;
    try {
      return _aiProfiles.firstWhere((p) => p.id == _selectedAiProfileId);
    } catch (e) {
      return null;
    }
  }

  String? getCombinedSystemPrompt() {
    final selectedProfile = getSelectedAiProfile();
    if (selectedProfile != null &&
        _systemPrompt != null &&
        _systemPrompt!.isNotEmpty) {
      return '${selectedProfile.systemPrompt}\n\n$_systemPrompt';
    } else if (selectedProfile != null) {
      return selectedProfile.systemPrompt;
    }
    return _systemPrompt;
  }

  // Custom Provider management
  Future<void> _loadCustomProviders() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final providersJson = _prefs?.getStringList('custom_providers') ?? [];

      if (providersJson.isEmpty) {
        _customProviders = CustomProvider.getBuiltInProviders();
        await _saveCustomProviders();
      } else {
        _customProviders = providersJson
            .map((json) => CustomProvider.fromJson(jsonDecode(json)))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading custom providers: $e');
      _customProviders = CustomProvider.getBuiltInProviders();
    }
  }

  Future<void> _saveCustomProviders() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final providersJson =
          _customProviders.map((p) => jsonEncode(p.toJson())).toList();
      await _prefs?.setStringList('custom_providers', providersJson);
    } catch (e) {
      print('Error saving custom providers: $e');
    }
  }

  Future<void> addCustomProvider(CustomProvider provider) async {
    _customProviders.add(provider);
    await _saveCustomProviders();
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> updateCustomProvider(CustomProvider provider) async {
    final index = _customProviders.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      _customProviders[index] = provider;
      await _saveCustomProviders();
      await syncSettingsToCloud();
      notifyListeners();
    }
  }

  Future<void> deleteCustomProvider(String providerId) async {
    _customProviders.removeWhere((p) => p.id == providerId);
    _customModels.removeWhere((m) => m.providerId == providerId);
    await _saveCustomProviders();
    await _saveCustomModels();
    await syncSettingsToCloud();
    notifyListeners();
  }

  CustomProvider? getProviderById(String providerId) {
    try {
      return _customProviders.firstWhere((p) => p.id == providerId);
    } catch (e) {
      return null;
    }
  }

  // Custom Model management
  Future<void> _loadCustomModels() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final modelsJson = _prefs?.getStringList('custom_models') ?? [];
      _customModels = modelsJson
          .map((json) => CustomModel.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading custom models: $e');
      _customModels = [];
    }
  }

  Future<void> _saveCustomModels() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final modelsJson =
          _customModels.map((m) => jsonEncode(m.toJson())).toList();
      await _prefs?.setStringList('custom_models', modelsJson);
    } catch (e) {
      print('Error saving custom models: $e');
    }
  }

  Future<void> addCustomModel(CustomModel model) async {
    _customModels.add(model);
    await _saveCustomModels();
    await syncSettingsToCloud();
    notifyListeners();
  }

  Future<void> updateCustomModel(CustomModel model) async {
    final index = _customModels.indexWhere((m) => m.id == model.id);
    if (index != -1) {
      _customModels[index] = model;
      await _saveCustomModels();
      await syncSettingsToCloud();
      notifyListeners();
    }
  }

  Future<void> deleteCustomModel(String modelId) async {
    _customModels.removeWhere((m) => m.id == modelId);
    await _saveCustomModels();
    await syncSettingsToCloud();
    notifyListeners();
  }

  CustomModel? getModelById(String modelId) {
    try {
      return _customModels.firstWhere((m) => m.id == modelId);
    } catch (e) {
      return null;
    }
  }

  List<CustomModel> getModelsByProvider(String providerId) {
    return _customModels.where((m) => m.providerId == providerId).toList();
  }
}
