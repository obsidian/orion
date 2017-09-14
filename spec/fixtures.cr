module Callable
  def self.call(context : HTTP::Server::Context)
    context.response.puts "callable"
    context.response.close
  end
end

class App
  def call(context : HTTP::Server::Context)
    context.response.puts "app"
    context.response.close
  end
end

class SampleMiddleware
  include HTTP::Handler

  def initialize(@string : String)
  end

  def call(cxt : HTTP::Server::Context)
    cxt.response.puts @string
    call_next(cxt)
  end
end

class SampleController
  include Orion::Routeable

  def get
    response.puts request.query_params["bar"]
    response.close
  end

  def baz
    response.puts request.query_params["baz"]
    response.close
  end

  def taz
    response.puts request.query_params["taz"]
    response.close
  end
end

class SampleRouter < Orion::Router
  use SampleMiddleware.new("at root")
  mount "app", App.new
  get "foo/:bar", "SampleController#get"
  get "proc", ->(context : HTTP::Server::Context) {
    context.response.puts "proc"
    context.response.close
  }
  get "callable", Callable
  group "in_group" do
    use SampleMiddleware.new("in group")
    get ":baz", "SampleController#baz"
    group "in_deeper_group" do
      use SampleMiddleware.new("in deep group")
      get ":taz", "SampleController#taz"
    end
  end
end
