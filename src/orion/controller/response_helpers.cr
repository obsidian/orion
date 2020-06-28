module Orion::Controller::ResponseHelpers
  # The `HTTP:Response`.
  def response
    @context.response
  end

  # Set the status of the response
  def status=(status)
    response.status = status
  end

  # Set the status of the response
  def status_code=(status_code)
    response.status_code = status_code
  end

  # Set the content type of the response
  def content_type=(content_type)
    response.content_type = content_type
  end
end
