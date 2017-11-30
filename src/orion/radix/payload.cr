module Orion::Radix
  class Payload
    getter helper : String?
    getter label : String?
    getter constraints = [] of Constraint.class
    @proc : HTTP::Handler::Proc | HTTP::Handler
    @handlers = [] of HTTP::Handler

    delegate call, to: @proc

    def initialize(proc : HTTP::Handler::Proc, *, handlers = [] of HTTP::Handler, constraints = [] of Constraint.class, @helper = nil, @label = nil)
      @constraints = constraints.dup
      @proc = handlers.empty? ? proc : HTTP::Server.build_middleware(handlers.map(&.dup), proc)
    end
  end
end
