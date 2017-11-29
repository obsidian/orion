require "http"
require "radix"
require "shell-table"

module Orion
  class Payload
    getter proc : HTTP::Handler::Proc
    getter handlers : Array(HTTP::Handler)
    getter label : String
    getter constraints : Array(Constraint.class)
    property helper : String?

    def initialize(@proc, @handlers, @constraints, @label); end
  end

  alias Tree = Radix::Tree(Payload)
  alias HandlerList = Array(HTTP::Handler)
  HTTP_VERBS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  {{ run "./parse_version.cr" }}
end

macro router(name)
  class {{ name }} < Orion::Router
    {{yield}}
  end
end

require "./orion/*"
