require "http"
require "radix"
require "shell-table"

module Orion
  class Payload
    getter proc : HTTP::Handler::Proc
    getter handlers : Array(HTTP::Handler)
    getter label : String
    property helper : String?

    def initialize(@proc, @handlers, @label) ; end
  end

  alias Tree = Radix::Tree(Payload)
  alias HandlerList = Array(HTTP::Handler)
  HTTP_VERBS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  {{ run "./parse_version.cr" }}
end

require "./orion/*"
