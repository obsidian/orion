require "random/secure"
require "inflector"

print "#{ARGV[0]}_#{Random::Secure.hex}"
