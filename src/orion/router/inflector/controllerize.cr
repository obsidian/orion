require "inflector"

print Inflector.pluralize(Inflector.camelize(ARGV[0]))
