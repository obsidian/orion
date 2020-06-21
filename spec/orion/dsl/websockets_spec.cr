require "../../spec_helper"

module Orion::DSL::WebSocketsSpec
  router SampleRouter do
    ws "/match", ->(ws : WebSocket, c : Context) {
      ws.send("Match")
    }
    get "/match", ->(c : Context) {
      c.response.print("Match Non WS")
    }
  end

  describe "ws" do
    it "matches on given route" do
      io, response = test_ws(SampleRouter.new, "/match")
      io.to_s.should eq("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=\r\n\r\n\x81\u0005Match")
    end

    it "returns 404 for an unmatched route" do
      io, response = test_ws(SampleRouter.new, "/no_match")
      response.status_code.should eq(404)
    end

    it "should allow a non ws request to coexist" do
      response = test_route(SampleRouter.new, :get, "/match")
      response.status_code.should eq 200
      response.body.should eq "Match Non WS"
    end
  end
end
