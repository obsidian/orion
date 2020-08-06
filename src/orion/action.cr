# :nodoc:
struct Orion::Action
  getter helper : String?
  getter constraints = [] of Constraint
  @proc : Handler::HandlerProc
  @pipeline : Orion::Pipeline

  def initialize(@proc : Handler::HandlerProc, *, handlers = [] of ::HTTP::Handler, constraints = [] of Constraint, @helper = nil)
    @constraints = constraints.dup
    @pipeline = Pipeline.new(handlers)
  end

  def invoke(c)
    @proc.call(c)
  end

  def call(c)
    c.request.action = self
    @pipeline.call(c)
  end

  def matches_constraints?(request : ::HTTP::Request)
    constraints.all? &.matches?(request)
  end
end
