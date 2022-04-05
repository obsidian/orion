require "oak"
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
    # :nodoc:
    ORION_CONFIG = ::Orion::Config.new

    # Add the controller
    class BaseController < Orion::Controller::Base
      include RouteHelpers
    end

    def self.config
      ORION_CONFIG
    end

    def self.new(*args, **opts)
      ::Orion::Router.new(TREE, *args, **opts, strip_extension: config.strip_extension)
    end

    def self.start
      start config: config
    end

    def self.start(*args, **opts)
      ::Orion::Router.start(TREE, *args, **opts)
    end

    include ::Orion::DSL::Macros

    use ::Orion::Handlers::Config.new(ORION_CONFIG)

    macro finished
      {% if @type.stringify == "<Program>" %}
        start unless ::Orion::FLAGS["started"]?
      {% end %}
    end
  end

  # :nodoc:
  alias Tree = Oak::Tree(Action)
  # :nodoc:
  alias Context = ::Orion::Server::Context
  # :nodoc:
  alias Response = ::Orion::Server::Response
  # :nodoc:
  alias Request = ::Orion::Server::Request
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
