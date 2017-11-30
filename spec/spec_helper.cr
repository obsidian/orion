require "../src/orion"
require "spec"

def mock_context(verb, path, host = "example.org", *, io = IO::Memory.new)
  headers = HTTP::Headers.new
  headers["HOST"] = host
  request = HTTP::Request.new(verb.to_s.upcase, path, headers)
  response = HTTP::Server::Response.new io
  HTTP::Server::Context.new(request, response)
end

def Orion::Router.test_route(method, path, *, ignore_body = false)
  io = IO::Memory.new
  context = mock_context(method, path, io: io)
  router = new
  router.call(context)
  HTTP::Client::Response.from_io io.tap(&.rewind), ignore_body: ignore_body
end
