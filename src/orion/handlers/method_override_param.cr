# :nodoc:
class Orion::Handlers::MethodOverrideParam
  include Handler

  def call(cxt : Server::Context)
    request = cxt.request
    override_method = param_method?(request) || form_method?(request)
    request.method = override_method if override_method
    call_next cxt
  end

  private def param_method?(req : HTTP::Request)
    req.query_params["_method"]?
  end

  private def form_method?(req : HTTP::Request)
    if type_for_request(req) == "multipart/form-data"
      HTTP::FormData.parse(req) do |part|
        if part.name == "_method"
          return part.body.gets_to_end
        end
      end
      nil
    end
  end

  def type_for_request(request : HTTP::Request)
    content_type = request.headers["content-type"]?.to_s.split(';').first?.to_s
  end
end
