struct Orion::Action
  getter helper : String?
  getter constraints = [] of Constraint
  @proc : HTTP::Handler::Proc | HTTP::Handler
  @handlers = [] of HTTP::Handler

  delegate call, to: @proc

  def initialize(proc : ::HTTP::Handler::Proc, *, handlers = [] of HTTP::Handler, constraints = [] of Constraint, @helper = nil)
    @constraints = constraints.dup
    @proc = handlers.empty? ? proc : HTTP::Server.build_middleware(handlers.map(&.dup), proc)
  end

  def matches_constraints?(request : ::HTTP::Request)
    constraints.all? &.matches?(request)
  end
end
