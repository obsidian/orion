require "http/server"

# :nodoc:
class Orion::Handlers::MethodOverrideHeader
  include Handler

  def call(cxt : Server::Context)
    override_method =
      cxt.request.headers["x-http-method-override"]? ||
        cxt.request.headers["x-method-override"]? ||
        cxt.request.headers["x-http-method"]?
    cxt.request.method = override_method if override_method
    call_next cxt
  end
end
