require "http/server"

class Orion::Handlers::Meta
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    call_next cxt
    cxt.response.headers["Content-Type"] ||= "text/html"
    cxt.response.headers["X-Powered-By"] ||= "Orion"
  end
end
