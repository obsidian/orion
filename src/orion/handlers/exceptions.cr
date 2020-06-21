require "ecr"

class Orion::Handlers::Exceptions
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    begin
      call_next(cxt)
    rescue e
      response = cxt.response
      status_code = response.status_code
      response.reset
      response.status_code = e.is_a?(RoutingError) ? 404 : 500
      {% if flag?(:release) %}
        message = e.is_a?(RoutingError) ? "The page you were looking for doesn't exist." : "We're sorry, but something went wrong."
        page_title = "#{message} (#{response.status_code})"
        subtext = e.is_a?(RoutingError) ? "You may have mistyped the address or the page may have moved." : "Please report this error to the application owner for assistance."
        response.headers["Content-Type"] = "text/html"
        ECR.embed "#{__DIR__}/../error_page.html.ecr", response
      {% else %}
        response.print ExceptionPage.for_runtime_exception(cxt, e).to_s
      {% end %}
    end
  end
end
