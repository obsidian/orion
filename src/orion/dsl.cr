require "./dsl/*"

# The `Orion::DSL` module contains all the macros and methods that are available
# when creating an Orion application. See the various submodules to see each
# macro and/or method you can invoke when building your app.
module Orion::DSL
  # Setup the router
  private macro included
    module RouteHelpers
      extend self
    end

    class BaseController < Orion::Controller::Base
      include RouteHelpers
    end

    # :nodoc:
    ROUTER_INITIALIZED = true
    # :nodoc:
    BASE_PATH = "/"
    # :nodoc:
    CONSTRAINTS = [] of ::Orion::Constraint
    # :nodoc:
    CONCERNS = {} of Symbol => String
    # :nodoc:
    HANDLERS = [] of HTTP::Handler
    # :nodoc:
    PREFIXES = [] of String
    # :nodoc:
    TREE = Tree.new
    # :nodoc:
    CONTROLLER = BaseController

    {% if @type.stringify == "<Program>" %}
      # :nodoc:
      ORION_CONFIG = ::Orion::Config.new

      def config
        ORION_CONFIG
      end

      macro finished
        ::Orion::Router.start(TREE, config: config)
      end
    {% end %}

    include ::Orion::DSL::Macros

    match "*", ::Orion::Handlers::NotFound.new
  end

  # :nodoc:
  alias Tree = Oak::Tree(Action)
  # :nodoc:
  alias Context = HTTP::Server::Context
  # :nodoc:
  alias Response = HTTP::Server::Response
  # :nodoc:
  alias Request = HTTP::Request
  # :nodoc:
  alias WebSocket = HTTP::WebSocket

  # :nodoc:
  CONTROLLER = nil

  # :nodoc:
  def self.normalize_path(*, base_path : String, path : String)
    return base_path if path.empty?
    parts = [base_path, path].map(&.to_s)
    String.build do |str|
      parts.each_with_index do |part, index|
        part.check_no_null_byte

        str << "/" if index > 0

        byte_start = 0
        byte_count = part.bytesize

        if index > 0 && part.starts_with?("/")
          byte_start += 1
          byte_count -= 1
        end

        if index != parts.size - 1 && part.ends_with?("/")
          byte_count -= 1
        end

        str.write part.unsafe_byte_slice(byte_start, byte_count)
      end
    end
  end
end
