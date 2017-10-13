require "inflector"

puts Inflector.pluralize(Inflector.camelize(ARGV[0])).inspect
