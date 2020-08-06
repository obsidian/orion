class Orion::Server::Request < HTTP::Request
  @original_path : String?

  setter path_params : Hash(String, String)?
  property base_path : String = "/"
  property action : Orion::Action?

  # Returns the list of path params set by an Orion route.
  def path_params
    @path_params ||= {} of String => String
  end

  # The original path of the request
  def reset_path!
    if (original_path = @original_path)
      self.path = original_path
      @original_path = nil
    end
  end

  def path=(new_path)
    @original_path = path
    super(new_path)
  end

  # The format of the http request
  def format
    formats.first
  end

  # The formats of the http request
  def formats
    MIMEHelper.request_extensions(self).tap do |set|
      set << File.extname(resource)
    end
  end
end
