#!/usr/bin/env ruby
require_relative 'mcp_server'

# Example tool handler class
class CalculateSumHandler
  def call(a: , b: )
    a + b
  end
end

# Initialize server
server = MCPServer.new(log_file: './dev.log')

# Add tools
server.add_tool(
  "calculate_sum",
  "Add two numbers together",
  {
    type: "object",
    properties: {
      a: { type: "number" },
      b: { type: "number" }
    },
    required: ["a", "b"]
  },
  CalculateSumHandler
)

# Start the server
server.start