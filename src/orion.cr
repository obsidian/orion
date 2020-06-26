require "oak"
require "kilt"
require "./http"
require "./macro"
require "./orion/*"

module Orion
  {{ run "./parse_version.cr" }}
end
