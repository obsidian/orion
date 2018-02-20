require "http/server"

# :nodoc:
struct Orion::Middleware::MethodOverrideHeader
  include Middleware

  def call(cxt : HTTP::Server::Context)
    override_method =
      cxt.request.headers["x-http-method-override"]? ||
      cxt.request.headers["x-method-override"]? ||
      cxt.request.headers["x-http-method"]?
    cxt.request.method = override_method if override_method
    yield cxt
  end
end
