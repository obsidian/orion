require "yaml"
version = YAML.parse(File.read "shard.yml")["version"].to_s
puts <<-crystal
VERSION = #{version.inspect}
crystal
