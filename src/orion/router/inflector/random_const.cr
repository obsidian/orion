require "secure_random"
require "inflector"

print "#{ARGV[0]}_#{SecureRandom.hex}"
