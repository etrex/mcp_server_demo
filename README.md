# MCP Server Demo | MCP 伺服器展示

這個專案是一個練習用的 Model Context Protocol (MCP) server 實作，主要目的是為了學習和了解 MCP 的運作原理。

A Ruby implementation of a Model Context Protocol (MCP) server for learning and practice purposes.

## Purpose | 目的

本專案的主要目標：
- 學習 MCP 協議的基本概念
- 理解 MCP server 的運作機制
- 實作一個簡單的 MCP server 來加深理解

This project aims to:
- Learn the basic concepts of MCP protocol
- Understand how MCP server works
- Implement a simple MCP server for better understanding

## Requirements | 環境需求

環境需求：
- Ruby
- Node.js 和 npm（用於 MCP inspector）

Requirements:
- Ruby
- Node.js and npm (for using the MCP inspector)

## Integration with Claude | 與 Claude 整合

與 Claude 整合的步驟：

1. 複製或下載此專案到本地端。
2. 修改 Claude 的設定檔，加入以下 JSON 結構：

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

注意：請將 `<path_to_repository>` 替換為您本地端專案的絕對路徑。

Note: Replace `<path_to_repository>` with the absolute path to your local copy of this repository.

3. 重新啟動 Claude 以套用新設定。

3. Restart Claude to apply the configuration changes.

## Testing Methods | 測試方法

### 1. Using MCP Inspector | 使用 MCP Inspector

1. 安裝 MCP inspector：
```bash
npm install -g @modelcontextprotocol/inspector
```

1. Install the MCP inspector:
```bash
npm install -g @modelcontextprotocol/inspector
```

2. 使用 inspector 運行伺服器：
```bash
npx @modelcontextprotocol/inspector ruby demo.rb
```

2. Run the server with inspector:
```bash
npx @modelcontextprotocol/inspector ruby demo.rb
```

### 2. Direct STDIO Testing | 直接 STDIO 測試

透過標準輸入發送 JSON-RPC 指令：

Send JSON-RPC commands through standard input:

1. 初始化伺服器：
```bash
echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"sampling":{},"roots":{"listChanged":true}},"clientInfo":{"name":"mcp-inspector","version":"0.0.1"}}}' | ruby demo.rb
```

1. Initialize the server:
```bash
echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"sampling":{},"roots":{"listChanged":true}},"clientInfo":{"name":"mcp-inspector","version":"0.0.1"}}}' | ruby demo.rb
```

2. 列出可用工具：
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | ruby demo.rb
```

2. List available tools:
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | ruby demo.rb
```

3. 呼叫工具：
```bash
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"_meta":{"progressToken":0},"name":"calculate_sum","arguments":{"a":1,"b":2}}}' | ruby demo.rb
```

3. Call a tool:
```bash
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"_meta":{"progressToken":0},"name":"calculate_sum","arguments":{"a":1,"b":2}}}' | ruby demo.rb
```

## Development | 開發說明

主要元件：
- `demo.rb`：主要伺服器實作
- `mcp_server.rb`：核心 MCP 協議處理

Main components:
- `demo.rb`: Main server implementation
- `mcp_server.rb`: Core MCP protocol handling

## License | 授權條款

MIT License | MIT 授權
