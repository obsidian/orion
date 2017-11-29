require "http/server"

class Orion::Handlers::ConstraintsChecker
  include HTTP::Handler

  getter constraints : Array(Constraint.class)

  def initialize(@constraints)
  end

  def call(cxt : HTTP::Server::Context) : Nil
    if constraints.all? &.new(cxt.request).matches?
      call_next cxt
    else
      cxt.response.respond_with_error(message: HTTP.default_status_message_for(404), code: 404)
    end
  end
end
