class Orion::StaticFileHandler
  include HTTP::Handler
  include MIMEHelper

  def initialize(public_dir : String)
    @public_dir = File.expand_path(public_dir)
  end

  def call(context)
    unless {"GET", "HEAD"}.includes?(context.request.method)
      call_next(context)
      return
    end

    original_path = "/#{context.request.path.not_nil!.lstrip(context.request.base_path)}"
    is_dir_path = original_path.ends_with? "/"
    request_path = self.request_path(URI.decode(original_path))

    # File path cannot contains '\0' (NUL) because all filesystem I know
    # don't accept '\0' character as file name.
    if request_path.includes? '\0'
      context.response.respond_with_status(:bad_request)
      return
    end

    expanded_path = File.expand_path(request_path, "/")
    if is_dir_path && !expanded_path.ends_with? "/"
      expanded_path = "#{expanded_path}/"
    end
    is_dir_path = expanded_path.ends_with? "/"

    file_path = File.join(@public_dir, expanded_path)
    is_dir = Dir.exists? file_path
    is_file = !is_dir && File.exists?(file_path)

    if is_dir && (index_path = index_file(file_path, context.request))
      file_path = index_path
      is_file = true
    elsif request_path != expanded_path || is_dir && !is_dir_path
      redirect_to context, "#{expanded_path}#{is_dir && !is_dir_path ? "/" : ""}"
      return
    end

    if is_file
      last_modified = modification_time(file_path)
      add_cache_headers(context.response.headers, last_modified)

      if cache_request?(context, last_modified)
        context.response.status = :not_modified
        return
      end

      context.response.content_type = MIME.from_filename(file_path, "application/octet-stream")
      context.response.content_length = File.size(file_path)
      File.open(file_path) do |file|
        IO.copy(file, context.response)
      end
    else
      call_next(context)
    end
  end

  # given a full path of the request, returns the path
  # of the file that should be expanded at the public_dir
  protected def request_path(path : String) : String
    path
  end

  private def index_file(path, request)
    request_extensions(request).map do |ext|
      File.join(path, "index#{ext}")
    end.find do |path|
      File.exists? path
    end
  end

  private def redirect_to(context, url)
    context.response.status = :found

    url = URI.encode(url)
    context.response.headers.add "Location", url
  end

  private def add_cache_headers(response_headers : HTTP::Headers, last_modified : Time) : Nil
    response_headers["Etag"] = etag(last_modified)
    response_headers["Last-Modified"] = HTTP.format_time(last_modified)
  end

  private def cache_request?(context : HTTP::Server::Context, last_modified : Time) : Bool
    # According to RFC 7232:
    # A recipient must ignore If-Modified-Since if the request contains an If-None-Match header field
    if if_none_match = context.request.if_none_match
      match = {"*", context.response.headers["Etag"]}
      if_none_match.any? { |etag| match.includes?(etag) }
    elsif if_modified_since = context.request.headers["If-Modified-Since"]?
      header_time = HTTP.parse_time(if_modified_since)
      # File mtime probably has a higher resolution than the header value.
      # An exact comparison might be slightly off, so we add 1s padding.
      # Static files should generally not be modified in subsecond intervals, so this is perfectly safe.
      # This might be replaced by a more sophisticated time comparison when it becomes available.
      !!(header_time && last_modified <= header_time + 1.second)
    else
      false
    end
  end

  private def etag(modification_time)
    %{W/"#{modification_time.to_unix}"}
  end

  private def modification_time(file_path)
    File.info(file_path).modification_time
  end
end
