require "http/server"

class Orion::Handlers::ParamsInjector
  include HTTP::Handler

  getter params : Hash(String, String)

  def initialize(@params)
  end

  def call(cxt : HTTP::Server::Context)
    params.each_with_object(cxt.request.query_params) do |(k, v), query_params|
      query_params[k] = v
    end
    call_next cxt
  end
end
