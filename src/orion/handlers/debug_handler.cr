require "exception_page"

# :nodoc:
class Orion::Handlers::DebugHandler
  class ExceptionPage < ::ExceptionPage
    getter styles : ExceptionPage::Styles = ExceptionPage::Styles.new(accent: "#2E1052")
  end

  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    begin
      call_next(cxt)
    rescue e
      cxt.response.status_code = 500
      cxt.response.headers["Content-Type"] = "text/html"
      ExceptionPage.for_runtime_exception(cxt, e).to_s(cxt.response)
    end
  end
end
