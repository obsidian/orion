struct Orion::Action
  getter helper : String?
  getter constraints = [] of Constraint
  @proc : HTTP::Handler::Proc

  delegate call, to: @proc

  def initialize(proc : ::HTTP::Handler::Proc, *, middleware = [] of Middleware::Chain::Link, constraints = [] of Constraint, @helper = nil)
    @constraints = constraints.dup
    @proc = Middleware::Chain.new(middleware, proc).to_proc
  end

  def matches_constraints?(request : ::HTTP::Request)
    constraints.all? &.matches?(request)
  end
end
