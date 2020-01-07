require "oak"
require "./http"
require "./macro"
require "./orion/*"

module Orion
  {{ run "./parse_version.cr" }}
end
