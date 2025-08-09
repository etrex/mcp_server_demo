# MCP 伺服器展示

[English Version](README_EN.md)

這個專案是一個練習用的 Model Context Protocol (MCP) server 實作，主要目的是為了學習和了解 MCP 的運作原理。

## 目的

本專案的主要目標：
- 學習 MCP 協議的基本概念
- 理解 MCP server 的運作機制
- 實作一個簡單的 MCP server 來加深理解

## 環境需求

環境需求：
- Ruby
- Node.js 和 npm（用於 MCP inspector）

## 與 Claude 整合

與 Claude 整合的步驟：

1. 複製或下載此專案到本地端。
2. 修改 Claude 的設定檔，加入以下 JSON 結構：

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

3. 重新啟動 Claude 以套用新設定。

## 測試方法

### 1. 使用 MCP Inspector

1. 安裝 MCP inspector：
```bash
npm install -g @modelcontextprotocol/inspector
```

2. 使用 inspector 運行伺服器：
```bash
npx @modelcontextprotocol/inspector ruby simple_server.rb
```

```bash
npx @modelcontextprotocol/inspector ruby demo.rb
```

```bash
npx @modelcontextprotocol/inspector ruby server_with_fast_mcp.rb
```

### 2. STDIO 測試

MCP Server 使用標準輸入輸出（STDIO）進行通訊。有兩種測試方式：

#### 方式一：直接執行並手動輸入（推薦）

1. 首先啟動伺服器：
```bash
ruby simple_server.rb
```

2. 然後在終端機中輸入 JSON-RPC 指令（每行一個指令）：
```json
{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"sampling":{},"roots":{"listChanged":true}},"clientInfo":{"name":"mcp-inspector","version":"0.0.1"}}}
{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"_meta":{"progressToken":0},"name":"calculate_sum","arguments":{"a":1,"b":2,"env":""}}}
```

這種方式可以保持伺服器持續運行，進行多次測試。使用 Ctrl+C 可以結束伺服器。

#### 方式二：使用 PIPE（單次測試）

使用 PIPE（|）可以快速測試單個指令，但每次指令結束後伺服器就會關閉：

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | ruby simple_server.rb
```

注意：使用 PIPE 時，每次指令執行完成後，STDIN 會收到 EOF 並自動關閉伺服器。如果需要連續測試多個指令，建議使用方式一。

## 開發說明

本專案提供兩種不同的實作方式，幫助理解 MCP 協議：

### 基礎實作 - Simple Server
- `simple_server.rb`：單一檔案的基礎實作
  - 完整展示 MCP 協議的基本概念
  - 包含完整的 JSON-RPC 請求/回應流程
  - 展示工具註冊和呼叫機制
  - 適合學習 MCP 的基本運作原理

### 架構化實作 - Demo Server
- `demo.rb`：主要進入點
  - 展示如何組織一個完整的 MCP 伺服器專案
  - 使用模組化的方式管理工具和處理程序
- `mcp_server.rb`：核心 MCP 協議處理
  - 抽象化協議層的實作
  - 提供可重用的基礎類別和方法
  - 展示如何建構可擴展的 MCP 伺服器架構

## 授權條款

MIT 授權
