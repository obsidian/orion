require "mime-types"
require "./http"
require "./macro"
require "./oak/*"

module Oak
  {{ run "./parse_version.cr" }}
end
