require "inflector"
Inflector.underscore(ARGV[0]).rstrip("_controller")
