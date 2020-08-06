require "uuid"

module Assets
  def self.unpack(pack)
    File.join(Dir.tempdir, "orion", "pack", UUID.random.to_s).tap do |dir|
      io = IO::Memory.new
      Base64.decode(pack, io)
      Compress::Gzip::Reader.open(io.rewind) do |gzip|
        Crystar::Reader.open(gzip) do |tar|
          tar.each_entry do |entry|
            filename = File.join(dir, entry.name)
            Dir.mkdir_p(File.dirname(filename))
            File.open filename, "w+" do |file|
              IO.copy entry.io, file
            end
          end
        end
      end
    end
  end
end
