require "http/server"

# :nodoc:
class Orion::Handlers::MethodOverrideParam
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    request = cxt.request
    override_method = param_method?(request) || form_method?(request)
    request.method = override_method if override_method
    call_next cxt
  end

  private def param_method?(req : HTTP::Request)
    req.query_params["_method"]?
  end

  private def form_method?(req : HTTP::Request)
    if MIME::Types.type_for(req).first? == MIME::Types["multipart/form-data"]
      HTTP::FormData.parse(req) do |part|
        if part.name == "_method"
          return part.body.gets_to_end
        end
      end
      nil
    end
  end
end
