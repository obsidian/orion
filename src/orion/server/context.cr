class Orion::Server::Context < HTTP::Server::Context
  getter! config : Orion::Config::ReadOnly?
  property session : Orion::Middleware::SessionStore?
  property flash : Orion::Middleware::Flash?
  property csrf_token : String?

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

  # Get session with safe access
  def session : Orion::Middleware::SessionStore
    @session || raise "Session not available. Add Session middleware to your router."
  end

  # Get flash with safe access
  def flash : Orion::Middleware::Flash
    @flash ||= Orion::Middleware::Flash.new(session)
  end
end

require "./context_helpers"
