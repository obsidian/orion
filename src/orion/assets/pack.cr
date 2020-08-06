require "crystar"
require "compress/gzip"
dir = ARGV[0]

io = IO::Memory.new
Compress::Gzip::Writer.open(io, level: Compress::Gzip::BEST_COMPRESSION) do |gzip|
  Crystar::Writer.open(gzip) do |tar|
    Dir.glob(File.join(dir, "**", "*"), match_hidden: true).each do |filename|
      File.open(filename) do |file|
        hdr = Crystar.file_info_header(file, file.path)
        hdr.name = filename
        tar.write_header hdr
        tar.write file.gets_to_end.to_slice
      end unless File.directory? filename
    end
  end
end
Base64.encode(io).split("\n").join.inspect(STDOUT)
