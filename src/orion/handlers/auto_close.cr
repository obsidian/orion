require "http/server"

# :nodoc:
class Orion::Handlers::AutoClose
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    call_next cxt
    cxt.response.close
  end
end
