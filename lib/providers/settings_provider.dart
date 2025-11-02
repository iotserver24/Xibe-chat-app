import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';
import '../services/database_service.dart';

class SettingsProvider extends ChangeNotifier {
  // Memory limits
  static const int maxTotalMemoryCharacters = 1000;
  static const int maxSingleMemoryCharacters = 200;
  SharedPreferences? _prefs;
  final DatabaseService _databaseService = DatabaseService();
  String? _apiKey;
  String? _systemPrompt;
  String? _e2bApiKey;
  double _temperature = 0.7;
  int _maxTokens = 2048;
  double _topP = 1.0;
  double _frequencyPenalty = 0.0;
  double _presencePenalty = 0.0;
  String _updateChannel = 'stable'; // 'stable' or 'beta'
  List<Memory> _memories = [];
  int _cachedTotalMemoryCharacters = 0;

  String? get apiKey => _apiKey;
  String? get systemPrompt => _systemPrompt;
  String? get e2bApiKey => _e2bApiKey;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  double get topP => _topP;
  double get frequencyPenalty => _frequencyPenalty;
  double get presencePenalty => _presencePenalty;
  String get updateChannel => _updateChannel;
  List<Memory> get memories => _memories;

  SettingsProvider() {
    _loadSettings();
    _loadMemories();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs?.getString('xibe_api_key');
    _systemPrompt = _prefs?.getString('system_prompt');
    _e2bApiKey = _prefs?.getString('e2b_api_key');
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
    notifyListeners();
  }

  Future<void> setSystemPrompt(String? prompt) async {
    _systemPrompt = prompt;
    if (prompt != null && prompt.isNotEmpty) {
      await _prefs?.setString('system_prompt', prompt);
    } else {
      await _prefs?.remove('system_prompt');
    }
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

  Future<void> setTemperature(double value) async {
    _temperature = value;
    await _prefs?.setDouble('temperature', value);
    notifyListeners();
  }

  Future<void> setMaxTokens(int value) async {
    _maxTokens = value;
    await _prefs?.setInt('max_tokens', value);
    notifyListeners();
  }

  Future<void> setTopP(double value) async {
    _topP = value;
    await _prefs?.setDouble('top_p', value);
    notifyListeners();
  }

  Future<void> setFrequencyPenalty(double value) async {
    _frequencyPenalty = value;
    await _prefs?.setDouble('frequency_penalty', value);
    notifyListeners();
  }

  Future<void> setPresencePenalty(double value) async {
    _presencePenalty = value;
    await _prefs?.setDouble('presence_penalty', value);
    notifyListeners();
  }

  Future<void> setUpdateChannel(String channel) async {
    if (channel == 'stable' || channel == 'beta') {
      _updateChannel = channel;
      await _prefs?.setString('update_channel', channel);
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
    _cachedTotalMemoryCharacters = _memories.fold(0, (sum, memory) => sum + memory.content.length);
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
}
