require "html_builder"

# Patch HTML escape function
def HTML.escape(stringable : Bool | Int | Float, *args)
  HTML.escape(stringable.to_s, *args)
end

module Orion::View::AssetTagHelpers
  # Returns an HTML image tag for the source. The source can be a full path or a
  # file that exists in your assets/images directory.
  def image_tag(src : String, **attrs)
    HTML.build do
      img(**attrs, src: assets_local? ? image_path(src) : image_url(src))
    end
  end

  # Computes the path to an image asset in the assets/images directory.
  # Full paths from the document root will be passed through. Used internally
  # by image_tag to build the image path.
  def image_path(src : String)
    asset_path(File.expand_path(src, "/images"))
  end

  # Computes the URL to an image asset in the assets/images directory.
  # This will call image_path internally and merge with your current host or
  # your asset host.
  def image_url(src : String)
    asset_url(File.expand_path(src, "/images"))
  end

  # Returns an HTML script tag for each of the sources provided. You can pass in
  # the filename (.js extension is optional) of JavaScript files that exist in
  # your assets/javascripts directory for inclusion into the current page or
  # you can pass the full path relative to your document root.
  def javascript_include_tag(src, **attrs)
    HTML.build do
      script(**attrs, src: assets_local? ? javascript_path(src) : javascript_url(src)) { }
    end
  end

  # Computes the path to a JavaScript asset in the assets/javascripts
  # directory. If the source filename has no extension, .js will be appended.
  # Full paths from the document root will be passed through. Used internally
  # by javascript_include_tag to build the script path.
  def javascript_path(file)
    asset_path(File.expand_path(file, "/javascripts"), extname: ".js")
  end

  # Computes the URL to a JavaScript asset in the assets/javascripts
  # directory. This will call javascript_path internally and merge with your
  # current host or your asset host.
  def javascript_url(file : String)
    asset_url(File.expand_path(file, "/javascripts"), extname: ".js")
  end

  # Returns a stylesheet link tag for the sources specified as arguments. If
  # you don't specify an extension, .css will be appended automatically.
  def stylesheet_link_tag(href, **attrs)
    HTML.build do
      link(**attrs, rel: "stylesheet", href: assets_local? ? stylesheet_path(href) : stylesheet_url(href))
    end
  end

  # Computes the path to a stylesheet asset in the assets/stylesheets
  # directory. If the source filename has no extension, .css will be appended.
  # Full paths from the document root will be passed through. Used internally by
  # stylesheet_link_tag to build the stylesheet path.
  def stylesheet_path(file)
    asset_path(File.expand_path(file, "/stylesheets"), extname: ".css")
  end

  # Computes the URL to a stylesheet asset in the assets/stylesheets
  # directory. This will call stylesheet_path internally and merge with your
  # current host or your asset host.
  def stylesheet_url(file : String)
    asset_url(File.expand_path(file, "/javascripts"), extname: ".css")
  end

  # Computes the path to an asset in the assets directory. If the source
  # filename has no extension, the provided extnam will be appended.
  # Full paths from the document root will be passed through.
  def asset_path(file, *, extname : String? = nil)
    file = extname ? "#{file}#{extname}" : file
    File.join("/assets", file)
  end

  # Computes the URL to an asset in the assets directory. This will call
  # asset_path internally and merge with your current host or your asset host.
  def asset_url(file : String, *, extname : String? = nil)
    "//#{config.asset_host || request.headers["Host"]?}#{asset_path(file, extname: extname)}"
  end

  # Returns a link tag that browsers and feed readers can use to auto-detect an
  # RSS, Atom, or JSON feed.
  def auto_discovery_link_tag(type : String, href, **attrs)
    HTML.build do
      link(**attrs, type: MIME.from_extension(".#{type}") { type }, href: href, rel: "alternate")
    end
  end

  private def assets_local?
    config.asset_host.nil? || config.asset_host == request.headers["Host"]?
  end
end
