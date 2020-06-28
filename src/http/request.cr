class HTTP::Request
  # :nodoc:
  setter path_params : Hash(String, String)?
  property base_path : String = "/"
  property action : Orion::Action?

  # Returns the list of path params set by an Orion route.
  def path_params
    @path_params ||= {} of String => String
  end

  # The format of the http request
  def format
    formats.first
  end

  # The formats of the http request
  def formats
    Orion::MIMEHelper.request_extensions(self).tap do |set|
      set << File.extname(resource)
    end
  end
end
