require "ecr"

class Orion::Handlers::Exceptions
  include Handler

  def call(cxt : Server::Context)
    begin
      call_next(cxt)
    rescue error
      Log.for(Orion).error(exception: error) { error.class.name }
      cxt.response.reset
      {% if flag?(:exceptionpage) || (flag?(:release) && !flag?(:noexceptionpage)) %}
        release_response cxt, error
      {% else %}
        dev_response cxt, error
      {% end %}
    end
  end

  private def release_response(cxt : Orion::Server::Context, error : Exception)
    status_code, message, subtext = response_for(error)
    cxt.response.status_code = status_code
    page_title = "#{message} (#{response.status_code})"
    cxt.response.headers["Content-Type"] = "text/html"
    ECR.embed "#{__DIR__}/../error_page.html.ecr", cxt.response
  end

  private def dev_response(cxt : Orion::Server::Context, error : Exception)
    status_code, message, subtext = response_for(error)
    cxt.response.status_code = status_code
    cxt.response.print ExceptionPage.for_runtime_exception(cxt, error).to_s
  end

  private def response_for(error : RoutingError)
    {404, "The page you were looking for doesn't exist.", "You may have mistyped the address or the page may have moved."}
  end

  private def response_for(error : Exception)
    {500, "We're sorry, but something went wrong.", "Please report this error to the application owner for assistance."}
  end
end
