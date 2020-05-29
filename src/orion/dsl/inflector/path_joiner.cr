base = ARGV[0]
path = ARGV[1]
parts = [base, path].map(&.to_s)
joined_path = String.build do |str|
  parts.each_with_index do |part, index|
    part.check_no_null_byte

    str << "/" if index > 0

    byte_start = 0
    byte_count = part.bytesize

    if index > 0 && part.starts_with?("/")
      byte_start += 1
      byte_count -= 1
    end

    if index != parts.size - 1 && part.ends_with?("/")
      byte_count -= 1
    end

    str.write part.unsafe_byte_slice(byte_start, byte_count)
  end
end
puts joined_path
