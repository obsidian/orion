require "digest/sha1"

print "Scope_#{Digest::SHA1.hexdigest(ARGV[0])}"
