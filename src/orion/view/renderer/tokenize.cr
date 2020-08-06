file = File.expand_path(ARGV[0])
print "#{file.sub(/^#{Dir.current}\/src\/views\//, "").gsub(/[^A-Za-z0-9_]/, "_")}"
