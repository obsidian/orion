struct Orion::Action
  getter helper : String?
  getter constraints = [] of Constraint
  @pipeline : HTTP::Handler

  # delegate call, to: @pipeline

  def initialize(proc : ::HTTP::Handler::Proc, *, handlers = [] of ::HTTP::Handler, constraints = [] of Constraint, @helper = nil)
    @constraints = constraints.dup
    @pipeline = Pipeline.build(handlers, proc)
    # @handler = handlers.empty? ? proc : HTTP::Server.build_middleware(handlers.map(&.dup), proc)
  end

  def call(c)
    puts "CALLING ACTION"
    pp @pipeline
    @pipeline.call(c)
  end

  def matches_constraints?(request : ::HTTP::Request)
    constraints.all? &.matches?(request)
  end
end
