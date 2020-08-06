class Orion::Server::Context < HTTP::Server::Context
  getter! config : Orion::Config::ReadOnly?

  # :nodoc:
  def initialize(@request : Request, @response : Response)
  end

  def config=(config : Orion::Config::ReadOnly)
    raise Exception.new("Cannot change the config during a request") if @config
    @config = config
  end

  def request : Request
    @request.as(Request)
  end

  def response : Response
    @response.as(Response)
  end
end
