module Orion::Controller::RequestHelpers
  # The `HTTP::Request` object.
  def request
    @context.request
  end

  # The query params of the `HTTP::Request`.
  def query_params
    request.query_params
  end

  # The path params of the `HTTP::Request` if any routes have named params in the path.
  def path_params
    request.path_params
  end

  # The remote address of the incoming `HTTP::Request`.
  def remote_address
    request.remote_address
  end

  # The resource of the `HTTP::Request`.
  def resource
    request.resource
  end

  # The host of the `HTTP::Request`.
  def host
    request.hostname
  end

  # The host with port of the `HTTP::Request`.
  def host_with_port
    request.headers["Host"]?
  end

  # Format of the `HTTP::Request`
  def format
    request.format
  end

  # Formats of the `HTTP::Request`
  def formats
    request.formats
  end
end
