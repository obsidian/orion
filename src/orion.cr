require "http"
require "radix"
require "shell-table"

module Orion
  record Payload,
    proc : HTTP::Handler::Proc,
    handlers : Array(HTTP::Handler),
    label : String,
    name : String?

  alias Tree = Radix::Tree(Payload)
  alias HandlerList = Array(HTTP::Handler)
  HTTP_VERBS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  {{ run "./parse_version.cr" }}
end

require "./orion/*"
