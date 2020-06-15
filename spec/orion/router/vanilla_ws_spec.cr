require "http"

def mock_context(verb, path, host = "example.org", *, headers = {} of String => String, io = IO::Memory.new, body = nil)
  http_headers = HTTP::Headers.new
  headers.each { |k, v| http_headers[k] = v }
  http_headers["HOST"] = host
  request = HTTP::Request.new(verb.to_s.upcase, path, http_headers)
  request.body = body
  response = HTTP::Server::Response.new io
  HTTP::Server::Context.new(request, response)
end

def test_ws(router, path, host = "example.org")
  io = IO::Memory.new
  context = mock_context("GET", path, host, headers: {
    "Upgrade"               => "websocket",
    "Connection"            => "Upgrade",
    "Sec-WebSocket-Key"     => "dGhlIHNhbXBsZSBub25jZQ==",
    "Sec-WebSocket-Version" => "13",
  }, io: io)
  begin
    router.call context
    context.response.close
  rescue IO::Error
    # Raises because the IO:: Memory is empty
  end
  io.rewind
  {io, context}
end

handler = HTTP::WebSocketHandler.new do |ws, ctx|
  puts "block invoked"
  ws.send("Match")
end

io, context = test_ws(handler, "/")

assertion = "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=\r\n\r\n\x81\u0005Match"

response = io.to_s
puts response
raise "Invalid Response" unless response == assertion
puts "OK"
