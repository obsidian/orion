require "inflector"
view_dir = "src/views"
controller_name = ARGV[0]
filename = ARGV[1]

controller_prefix = Inflector.underscore(controller_name).gsub(/_controller$/, "")
controller_dir = File.join(view_dir, controller_prefix)
controller_file = File.join(controller_dir, filename)
view_file = File.join(view_dir, filename)

if File.exists? controller_file
  print controller_file
elsif File.exists? view_file
  print view_file
else
  STDERR.puts "could not find view: #{filename} in (#{controller_dir}, #{view_dir})"
  Process.exit 1
end
