# MCP Configuration Guide

Guide to configuring Model Context Protocol (MCP) servers in Xibe Chat.

## What is MCP?

Model Context Protocol (MCP) enables AI models to access external tools, resources, and data sources beyond their training data.

## Configuration

### Default Configuration

MCP servers are configured in `lib/services/mcp_config_service.dart`. Default configuration includes:

- **Supabase MCP**: Database access
- **E2B MCP**: Code execution
- **File System MCP**: File operations
- **Web Search MCP**: Real-time web search

### Adding Custom MCP Servers

1. **Open Settings** → **MCP Servers**

2. **Add Server**:
   - Name: Server display name
   - Command: Executable command
   - Args: Command arguments
   - Environment: Environment variables

3. **Example Configuration**:

```json
{
  "name": "Custom MCP Server",
  "command": "node",
  "args": ["/path/to/server.js"],
  "env": {
    "API_KEY": "your-api-key"
  }
}
```

---

## Available MCP Servers

### Supabase MCP

Provides database access and operations.

**Configuration**:
```json
{
  "name": "Supabase",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-supabase"],
  "env": {
    "SUPABASE_URL": "https://your-project.supabase.co",
    "SUPABASE_KEY": "your-anon-key"
  }
}
```

### E2B MCP

Code execution sandbox integration.

**Configuration**:
```json
{
  "name": "E2B",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-e2b"],
  "env": {
    "E2B_API_KEY": "your-e2b-api-key"
  }
}
```

### File System MCP

File operations and management.

**Configuration**:
```json
{
  "name": "File System",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem"],
  "env": {
    "ALLOWED_DIRECTORIES": "/path/to/allowed/directory"
  }
}
```

---

## Using MCP Tools

### In Chat

MCP tools are automatically available when:
1. MCP server is running
2. Model supports tools
3. Tool is enabled in settings

### Example Usage

```
User: "Search the web for Flutter 3.0 features"
AI: [Uses Web Search MCP tool]
AI: "Here are the latest Flutter 3.0 features..."
```

---

## Troubleshooting

### Server Not Starting

1. Check command path
2. Verify dependencies installed
3. Check environment variables
4. Review logs in Settings → MCP Servers

### Tools Not Available

1. Ensure MCP server is running
2. Verify model supports tools
3. Check tool permissions

### Connection Errors

1. Verify network connectivity
2. Check firewall settings
3. Review server logs

---

## Security Considerations

### Environment Variables

- Never commit API keys
- Use secure storage
- Rotate keys regularly

### File System Access

- Limit allowed directories
- Use read-only access when possible
- Audit file operations

### Network Access

- Whitelist allowed domains
- Use HTTPS only
- Monitor network requests

---

## Additional Resources

- [MCP Specification](https://modelcontextprotocol.io/)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [MCP Documentation](https://modelcontextprotocol.io/docs)

