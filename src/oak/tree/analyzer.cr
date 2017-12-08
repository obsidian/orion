struct Oak::Tree::Analyzer
  getter path : String
  getter key : String
  getter key_reader : Char::Reader
  getter path_reader : Char::Reader

  def initialize(*, @key : String, @path : String)
    @key_reader = Char::Reader.new(key)
    @path_reader = Char::Reader.new(path)

    # step through each reader until they no longer match
    while path_reader.has_next? && key_reader.has_next?
      break if path_reader.current_char != key_reader.current_char
      path_reader.next_char
      key_reader.next_char
    end
  end

  def exact_match?
    at_end_of_path? && path_pos_at_end_of_key?
  end

  def matched_key
    key_reader.string.byte_slice(0, key_reader.pos)
  end

  def matched_path
    path_reader.string.byte_slice(0, path_reader.pos)
  end

  def remaining_key
    key.byte_slice(path_reader.pos)
  end

  def remaining_path
    path_reader.string.byte_slice(path_reader.pos)
  end

  def split_on_key?
    !path_reader_at_zero_pos? || remaining_key?
  end

  def split_on_path?
    path_reader_at_zero_pos? || (remaining_path? && path_larger_than_key?)
  end

  def remaining_path?
    path_reader.pos < path.bytesize
  end

  private def at_end_of_path?
    path_reader.pos == path.bytesize
  end

  private def path_larger_than_key?
    path_reader.pos >= key.bytesize
  end

  private def path_pos_at_end_of_key?
    path_reader.pos == key.bytesize
  end

  private def path_reader_at_zero_pos?
    path_reader.pos == 0
  end

  private def remaining_key?
    path_reader.pos < key.bytesize
  end
end
