require "../../spec_helper"

describe Orion::StaticFileHandler do
  context "given the file exists" do
    it "should return the proper response" do
      io = IO::Memory.new
      context = mock_context(:get, "/test.txt", io: io)
      handler = Orion::StaticFileHandler.new("./spec/fixtures")
      handler.call(context)
      context.response.close
      io.rewind
      response = HTTP::Client::Response.from_io io
      response.status_code.should eq 200
      response.content_type.should eq "text/plain"
      response.body.should eq "Hello World"
    end
  end

  context "given a base path" do
    it "should return the proper response" do
      io = IO::Memory.new
      context = mock_context(:get, "/foo/test.txt", io: io)
      context.request.base_path = "/foo"
      handler = Orion::StaticFileHandler.new("./spec/fixtures")
      handler.call(context)
      context.response.close
      io.rewind
      response = HTTP::Client::Response.from_io io
      response.status_code.should eq 200
      response.content_type.should eq "text/plain"
      response.body.should eq "Hello World"
    end
  end

  context "given the file does not exist" do
    io = IO::Memory.new
      context = mock_context(:get, "/not-here.unknown", io: io)
      handler = Orion::StaticFileHandler.new("./spec/fixtures")
      handler.call(context)
      context.response.close
      io.rewind
      response = HTTP::Client::Response.from_io io
      response.status_code.should_not eq 200
  end
end
