# :nodoc:
class Orion::Handlers::Meta
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    call_next cxt
    cxt.response.headers["Content-Type"] ||= "text/html"
  end
end
