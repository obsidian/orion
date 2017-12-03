module Orion::Handler
  alias Proc = ::Proc(::HTTP::Server::Context, Nil)
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call ::HTTP::Server::Context.new(context)
  end

  abstract def call(context : ::HTTP::Server::Context)
end
