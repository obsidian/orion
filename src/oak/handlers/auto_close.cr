require "http/server"

class Oak::Handlers::AutoClose
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    call_next cxt
    cxt.response.close
  end
end
