import 'dart:convert';

class McpServerConfig {
  final String command;
  final List<String> args;
  final Map<String, String>? env;
  final String? url;
  final Map<String, String>? headers;
  final bool isEnabled;

  McpServerConfig({
    this.command = '',
    this.args = const [],
    this.env,
    this.url,
    this.headers,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (command.isNotEmpty) {
      json['command'] = command;
      json['args'] = args;
      if (env != null && env!.isNotEmpty) {
        json['env'] = env;
      }
    }
    if (url != null && url!.isNotEmpty) {
      json['url'] = url;
      if (headers != null && headers!.isNotEmpty) {
        json['headers'] = headers;
      }
    }
    json['isEnabled'] = isEnabled;
    return json;
  }

  factory McpServerConfig.fromJson(Map<String, dynamic> json) {
    return McpServerConfig(
      command: json['command'] ?? '',
      args: json['args'] != null ? List<String>.from(json['args']) : [],
      env: json['env'] != null ? Map<String, String>.from(json['env']) : null,
      url: json['url'],
      headers: json['headers'] != null ? Map<String, String>.from(json['headers']) : null,
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  McpServerConfig copyWith({
    String? command,
    List<String>? args,
    Map<String, String>? env,
    String? url,
    Map<String, String>? headers,
    bool? isEnabled,
  }) {
    return McpServerConfig(
      command: command ?? this.command,
      args: args ?? this.args,
      env: env ?? this.env,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class McpConfiguration {
  final Map<String, McpServerConfig> mcpServers;

  McpConfiguration({required this.mcpServers});

  Map<String, dynamic> toJson() {
    return {
      'mcpServers': mcpServers.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory McpConfiguration.fromJson(Map<String, dynamic> json) {
    final serversMap = <String, McpServerConfig>{};
    if (json['mcpServers'] != null) {
      final servers = json['mcpServers'] as Map<String, dynamic>;
      servers.forEach((key, value) {
        serversMap[key] = McpServerConfig.fromJson(value);
      });
    }
    return McpConfiguration(mcpServers: serversMap);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory McpConfiguration.fromJsonString(String jsonString) {
    return McpConfiguration.fromJson(jsonDecode(jsonString));
  }

  // Create a default configuration (empty by default)
  factory McpConfiguration.defaultConfig() {
    return McpConfiguration(
      mcpServers: {},
    );
  }
}
