require "../src/orion"
require "spec"

def mock_context(verb, path, io = IO::Memory.new)
  request = HTTP::Request.new(verb.to_s.upcase, path)
  response = HTTP::Server::Response.new io
  HTTP::Server::Context.new(request, response)
end

def Orion::Router.test_route(method, path, *, ignore_body = false)
  io = IO::Memory.new
  context = mock_context(:get, path, io)
  router = new
  router.call(context)
  HTTP::Client::Response.from_io io.tap(&.rewind), ignore_body: ignore_body
end
