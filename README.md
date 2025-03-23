# MCP Server Demo

A Ruby implementation of a Model Context Protocol (MCP) server.

## Requirements

- Ruby
- Node.js and npm (for using the MCP inspector)


## Integration with Claude

To integrate this MCP server with Claude:

1. Clone or download this repository to your local machine.

2. Configure your Claude settings by modifying the configuration file with the following JSON structure:

```json
{
  "mcpServers": {
    "mcp_server_demo": {
      "command": "ruby",
      "args": [
        "<path_to_repository>/demo.rb"
      ]
    }
  }
}
```

   Note: Replace `<path_to_repository>` with the absolute path to your local copy of this repository.

3. Restart Claude to apply the configuration changes.

## Testing Methods

### 1. Using MCP Inspector

1. Install the MCP inspector:
```bash
npm install -g @modelcontextprotocol/inspector
```

2. Run the server with inspector:
```bash
npx @modelcontextprotocol/inspector ruby demo.rb
```

### 2. Direct STDIO Testing

Send JSON-RPC commands through standard input:

1. Initialize the server:
```bash
echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"sampling":{},"roots":{"listChanged":true}},"clientInfo":{"name":"mcp-inspector","version":"0.0.1"}}}' | ruby demo.rb
```

2. List available tools:
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | ruby demo.rb
```

3. Call a tool:
```bash
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"_meta":{"progressToken":0},"name":"calculate_sum","arguments":{"a":1,"b":2}}}' | ruby demo.rb
```

## Development

Main components:
- `demo.rb`: Main server implementation
- `mcp_server.rb`: Core MCP protocol handling
- `dev.log`: Activity logging file

## License

MIT License
