require "inflector"
layout_dir = "src/views/layouts"
filename = ARGV[0]
layout_file = File.join(layout_dir, filename)

if File.exists? layout_file
  print layout_file
else
  STDERR.puts "could not find layout: #{layout_file} in (#{layout_dir})"
  Process.exit 1
end
