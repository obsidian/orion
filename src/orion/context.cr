class Orion::Context < HTTP::Server::Context

  getter env = {} of String => String
  getter request : Orion::Request
  getter response : Orion::Response

  def initialize(http_context : HTTP::Context, path_params : {} of String => String)
    @request = Request.new(http_context.request, path_params)
    @response = Response.new(http_context.response)
  end
end
