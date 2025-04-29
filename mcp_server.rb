#!/usr/bin/env ruby
require 'json'
require 'time'

# MCP（Model Context Protocol）伺服器類別
# 負責處理與 AI 模型的通訊協議，管理工具註冊和調用
class MCPServer
  # 初始化 MCP 伺服器
  # @param name [String] 伺服器名稱
  # @param log_file [String, nil] 日誌檔案路徑，如果為 nil 則不記錄日誌
  def initialize(name: "mcp server demo", log_file: nil)
    @name = name
    @tools = {}
    @log_file = log_file
  end

  # 註冊新的工具到伺服器
  # @param name [String] 工具名稱
  # @param description [String] 工具描述
  # @param input_schema [Hash] 工具輸入參數的 JSON Schema
  # @param handler_class [Class] 處理工具調用的類別
  def add_tool(name, description, input_schema, handler_class)
    @tools[name] = {
      handler: handler_class,
      description: description,
      input_schema: input_schema
    }
  end

  # 列出所有已註冊的工具
  # @param id [String] 請求 ID
  # @return [Hash] 包含所有工具資訊的 JSON-RPC 回應
  def list_tools(id)
    {
      "jsonrpc": "2.0",
      "id": id,
      "result": {
        "tools": @tools.map { |name, tool|
          {
            name: name,
            description: tool[:description],
            inputSchema: tool[:input_schema]
          }
        }
      }
    }
  end

  # 列出所有可用資源
  # @param id [String] 請求 ID
  # @return [Hash] 包含資源列表的 JSON-RPC 回應
  def list_resources(id)
    {
      "jsonrpc": "2.0",
      "id": id,
      "result": {
        "resources": []
      }
    }
  end

  # 列出所有可用提示
  # @param id [String] 請求 ID
  # @return [Hash] 包含提示列表的 JSON-RPC 回應
  def list_prompts(id)
    {
      "jsonrpc": "2.0",
      "id": id,
      "result": {
        "prompts": []
      }
    }
  end

  # 初始化伺服器連線
  # @param id [String] 請求 ID
  # @return [Hash] 包含伺服器資訊和功能的 JSON-RPC 回應
  def run_initialize(id)
    {
      "jsonrpc": "2.0",
      "id": id,
      "result": {
        "protocolVersion": "2024-11-05",
        "capabilities": {
          "tools": {}
        },
        "serverInfo": {
          "name": @name,
          "version": "1.0.0"
        }
      }
    }
  end

  # 處理通知型請求
  # @param method [String] 通知方法名稱
  # @return [nil] 通知不需要回應
  def handle_notification(method)
    nil
  end

  # 處理客戶端請求
  # @param request [Hash] JSON-RPC 請求物件
  # @return [Hash, nil] JSON-RPC 回應或 nil（如果是通知）
  def handle_request(request)
    request_id = request["id"]
    
    if request["method"].start_with?("notifications/")
      handle_notification(request["method"])
    else
      case request["method"]
      when "initialize"
        run_initialize(request_id)
      when "tools/list"
        list_tools(request_id)
      when "tools/call"
        call_tool(request_id, request["params"])
      when "resources/list"
        list_resources(request_id)
      when "prompts/list"
        list_prompts(request_id)
      when /^tools\/run\/(.*)/
        tool_name = $1
        if @tools.key?(tool_name)
          handler = @tools[tool_name][:handler].new
          handler.handle(request_id, request["params"])
        else
          error_response(request_id, -32601, "Tool not found: #{tool_name}")
        end
      else
        error_response(request_id, -32601, "Method not found")
      end
    end
  end

  # 調用指定的工具
  # @param request_id [String] 請求 ID
  # @param params [Hash] 工具調用參數
  # @return [Hash] 工具執行結果的 JSON-RPC 回應
  def call_tool(request_id, params)
    tool_name = params["name"]
    arguments = JSON.parse(params["arguments"].to_json, symbolize_names: true)
    
    if !tool_name
      return error_response(request_id, -32602, "Missing tool name")
    end

    if @tools.key?(tool_name)
      handler = @tools[tool_name][:handler].new
      result = handler.call(**arguments)
      {
        "jsonrpc": "2.0",
        "id": request_id,
        "result": {
          "content": result,
          "isError": false
        }
      }
    else
      error_response(request_id, -32601, "Tool not found: #{tool_name}")
    end
  end

  # 生成錯誤回應
  # @param id [String, nil] 請求 ID
  # @param code [Integer] 錯誤代碼
  # @param message [String] 錯誤訊息
  # @return [Hash] JSON-RPC 錯誤回應
  def error_response(id, code, message)
    {
      "jsonrpc": "2.0",
      "id": id,
      "error": {
        "code": code,
        "message": message
      }
    }
  end

  # 記錄輸入資料到日誌檔
  # @param input [String] 輸入資料
  def log_input(input)
    return unless @log_file
    
    File.open(@log_file, 'a') do |log|
      timestamp = Time.now.iso8601
      log.puts "[#{timestamp}] Received input: #{input.strip}"
    end
  end

  # 記錄輸出資料到日誌檔
  # @param output [Hash] 輸出資料
  def log_output(output)
    return unless @log_file
    
    File.open(@log_file, 'a') do |log|
      timestamp = Time.now.iso8601
      log.puts "[#{timestamp}] Sending response: #{output.to_json}"
    end
  end

  # 啟動 MCP 伺服器
  # 開始監聽標準輸入並處理請求
  def start
    STDOUT.sync = true

    begin
      while line = STDIN.gets
        log_input(line)

        begin
          request = JSON.parse(line)
          response = handle_request(request)
          if response
            log_output(response)
            puts JSON.generate(response)
          end
        rescue JSON::ParserError => e
          log_output(error_response(nil, -32700, "Parse error"))
          puts JSON.generate(error_response(nil, -32700, "Parse error"))
        rescue => e
          log_output(error_response(defined?(request_id) ? request_id : nil, -32603, "Internal error: #{e.message}"))
          puts JSON.generate(error_response(defined?(request_id) ? request_id : nil, -32603, "Internal error: #{e.message}"))
        end
      end
    rescue => e
      log_output(error_response(nil, -32603, "Internal error: #{e.message}"))
      puts JSON.generate(error_response(nil, -32603, "Internal error: #{e.message}"))
    end
  end
end
