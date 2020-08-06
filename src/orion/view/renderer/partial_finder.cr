require "inflector"
view_dir = "src/views"
controller_name = ARGV[0]
partial_name = ARGV[1]

parts = partial_name.split("/")
parts << "_" + parts.pop
filename = parts.join("/")
controller_prefix = Inflector.underscore(controller_name.gsub(/Controller::Renderer$/, ""))
controller_dir = File.join(view_dir, controller_prefix)
controller_file = File.join(controller_dir, filename)
view_file = File.join(view_dir, filename)

if File.exists? controller_file
  print controller_file
elsif File.exists? view_file
  print view_file
else
  STDERR.puts "could not find partial: #{partial_name} in (#{controller_dir}, #{view_dir}), partial filenames must begin with underscore."
  Process.exit 1
end
