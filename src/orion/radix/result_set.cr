require "./result"

struct Orion::Radix::ResultSet
  include Enumerable(Result)

  NOT_FOUND = ->(context : HTTP::Server::Context) {
    context.response.respond_with_error(
      message: HTTP.default_status_message_for(404),
      code: 404
    )
    context.response.close
    nil
  }

  @results = [] of Orion::Radix::Result
  delegate each, to: @results
  delegate params, track, to: current

  def initialize
    @results << Result.new
  end

  def current
    @results.last
  end

  def current=(result : Result)
    @results << result
  end

  def use(node : Node)
    current.use node
    self.current = Result.new
  end

  def call(context : HTTP::Server::Context)
    result = find(&.matches_constraints?(context.request)) || NOT_FOUND
    result.call(context)
  end
end
