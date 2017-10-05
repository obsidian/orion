require "../src/orion"
require "spec"
require "./fixtures"

def mock_context(verb, path, io = IO::Memory.new)
  request = HTTP::Request.new(verb.to_s.upcase, path)
  response = HTTP::Server::Response.new io
  HTTP::Server::Context.new(request, response)
end
