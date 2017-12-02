class Orion::Radix::Payload
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

  def matches_constraints?(request : HTTP::Request)
    constraints.all?(&.new(request).matches?)
  end

  private def matches_constraint?(request, proc : Constraint::Proc)
    proc.call(request)
  end

  private def matches_constraint?(request, constraint : Constraint.class)
    constraint.new(request).matches?
  end
end
