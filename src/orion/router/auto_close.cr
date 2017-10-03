require "http/server"

class Orion::Router::AutoClose
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    call_next cxt
    cxt.response.close
  end
end
