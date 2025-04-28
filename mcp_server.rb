#!/usr/bin/env ruby
require 'json'
require 'time'

class MCPServer
  def initialize(name: "mcp server demo", log_file: nil)
    @name = name
    @tools = {}
    @log_file = log_file
  end

  def add_tool(name, description, input_schema, handler_class)
    @tools[name] = {
      handler: handler_class,
      description: description,
      input_schema: input_schema
    }
  end

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

  def list_resources(id)
    {
      "jsonrpc": "2.0",
      "id": id,
      "result": {
        "resources": []
      }
    }
  end

  def list_prompts(id)
    {
      "jsonrpc": "2.0",
      "id": id,
      "result": {
        "prompts": []
      }
    }
  end

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

  def handle_notification(method)
    nil
  end

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

  def log_input(input)
    return unless @log_file
    
    File.open(@log_file, 'a') do |log|
      timestamp = Time.now.iso8601
      log.puts "[#{timestamp}] Received input: #{input.strip}"
    end
  end

  def log_output(output)
    return unless @log_file
    
    File.open(@log_file, 'a') do |log|
      timestamp = Time.now.iso8601
      log.puts "[#{timestamp}] Sending response: #{output.to_json}"
    end
  end

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
