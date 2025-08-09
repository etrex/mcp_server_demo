# MCP Server Demo

A Ruby implementation of a Model Context Protocol (MCP) server for learning and practice purposes.

[中文版](README.md)

## Purpose

This project aims to:
- Learn the basic concepts of MCP protocol
- Understand how MCP server works
- Implement a simple MCP server for better understanding

## Requirements

Requirements:
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
npx @modelcontextprotocol/inspector ruby simple_server.rb
```

```bash
npx @modelcontextprotocol/inspector ruby demo.rb
```

```bash
npx @modelcontextprotocol/inspector ruby server_with_fast_mcp.rb
```

### 2. STDIO Testing

The MCP Server uses Standard Input/Output (STDIO) for communication. There are two testing approaches:

#### Method 1: Direct Execution with Manual Input (Recommended)

1. First, start the server:
```bash
ruby simple_server.rb
```

2. Then input JSON-RPC commands in the terminal (one command per line):
```json
{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"sampling":{},"roots":{"listChanged":true}},"clientInfo":{"name":"mcp-inspector","version":"0.0.1"}}}
{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"_meta":{"progressToken":0},"name":"calculate_sum","arguments":{"a":1,"b":2,"env":""}}}
```

This method keeps the server running for multiple tests. Use Ctrl+C to terminate the server.

#### Method 2: Using PIPE (Single Test)

Using PIPE (|) allows quick testing of individual commands, but the server closes after each command:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | ruby simple_server.rb
```

Note: When using PIPE, the server automatically closes after each command execution as STDIN receives EOF. For continuous testing of multiple commands, Method 1 is recommended.

## Development

This project provides two different implementations to help understand the MCP protocol:

### Basic Implementation - Simple Server
- `simple_server.rb`: Single-file basic implementation
  - Demonstrates core MCP protocol concepts
  - Includes complete JSON-RPC request/response flow
  - Shows tool registration and invocation mechanisms
  - Ideal for learning basic MCP operations

### Structured Implementation - Demo Server
- `demo.rb`: Main entry point
  - Demonstrates how to organize a complete MCP server project
  - Uses modular approach for tool management and request handling
- `mcp_server.rb`: Core MCP protocol handling
  - Implements abstracted protocol layer
  - Provides reusable base classes and methods
  - Shows how to build an extensible MCP server architecture

## License

MIT License
