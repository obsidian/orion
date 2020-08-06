module Orion::Handler
  include HTTP::Handler
  alias HandlerProc = Server::Context ->

  abstract def call(context : Server::Context)

  def call(context : HTTP::Server::Context)
    raise "Cannot use an orion handler with a standard HTTP router."
  end
end
