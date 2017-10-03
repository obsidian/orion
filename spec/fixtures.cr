module Callable
  def self.call(context : HTTP::Server::Context)
    context.response.puts "callable"
  end
end

class App
  def call(context : HTTP::Server::Context)
    context.response.puts "app"
  end
end

class SampleMiddleware
  include HTTP::Handler

  property string : String

  def initialize(@string : String)
  end

  def call(cxt : HTTP::Server::Context)
    cxt.response.puts string
    call_next(cxt)
  end
end

struct SampleController
  include Orion::Routable

  def get
    response.puts request.query_params["bar"]
  end

  def baz
    response.puts request.query_params["baz"]
  end

  def taz
    response.puts request.query_params["taz"]
  end
end

class SampleRouter < Orion::Router
  use SampleMiddleware.new("at root")
  mount "app", App.new
  get "foo/:bar", "SampleController#get"
  get "proc", ->(context : HTTP::Server::Context) {
    context.response.puts "proc"
  }
  group "in_group" do
    use SampleMiddleware.new("in group")
    put ":baz", ->(cxt : HTTP::Server::Context) { cxt.response.puts "?" }
    match ":baz", "SampleController#baz"
    group "in_deeper_group" do
      use SampleMiddleware.new("in deep group")
      get ":taz", "SampleController#taz"
    end
    clear_handlers do
      get "no/handlers", ->(context : HTTP::Server::Context) {
        context.response.puts "no handlers"
      }
    end
  end
  get "callable", Callable
end
