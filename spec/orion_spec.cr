require "./spec_helper"

class SampleController
  def initialize(@context : HTTP::Server::Context)
  end

  def get
    @context.response.puts @context.request.query_params["bar"]
    @context.response.close
  end

  def baz
    @context.response.puts @context.request.query_params["baz"]
    @context.response.close
  end
end

class SampleRouter < Orion::Router
  get "foo/:bar", "SampleController#get"
  group "foo/more" do
    get ":baz", "SampleController#baz"
  end
end

def mock_context(verb, path, io = IO::Memory.new)
  request = HTTP::Request.new(verb.to_s.upcase, path)
  response = HTTP::Server::Response.new io
  HTTP::Server::Context.new(request, response)
end

describe Orion do
  # TODO: Write tests

  it "renders a basic route" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/foo/world", io))
    io.tap(&.rewind).gets_to_end.should contain "world"
  end

  it "renders a group route" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/foo/more/mars", io))
    io.tap(&.rewind).gets_to_end.should contain "mars"
  end
end
