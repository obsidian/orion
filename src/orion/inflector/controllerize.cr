require "inflector"

if ARGV[0][0].ascii_uppercase?
  print ARGV[0] + "Controller"
else
  print Inflector.camelize(ARGV[0]) + "Controller"
end
