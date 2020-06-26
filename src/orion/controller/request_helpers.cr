module Orion::Controller::RequestHelpers
  # The HTTP request object.
  def request
    @context.request
  end

  # The HTTP response object.
  def response
    @context.response
  end

  # The query params of the request object.
  def query_params
    request.query_params
  end

  # The path params if any routes have named params in the path.
  def path_params
    request.path_params
  end

  # The remote address of the incoming request.
  def remote_address
    request.remote_address
  end

  # The resource of the request object.
  def resource
    request.resource
  end

  # The host of the request object.
  def host
    request.host
  end

  # The host with port of the request object.
  def host
    request.host_with_port
  end
end
