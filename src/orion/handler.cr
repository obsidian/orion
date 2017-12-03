module Orion::Handler
  alias Proc = ::Proc(Orion::Context, Nil)
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call Orion::Context.new(context)
  end

  abstract def call(context : Orion::Context)
end
