struct Orion::Radix::Walker
  getter path : String
  getter key : String
  getter key_reader : Char::Reader
  getter path_reader : Char::Reader

  def self.detect_param_size(reader)
    # save old position
    old_pos = reader.pos

    # move forward until '/' or EOL is detected
    while reader.has_next?
      break if reader.current_char == '/'

      reader.next_char
    end

    # calculate the size
    size = reader.pos - old_pos

    # restore old position
    reader.pos = old_pos

    size
  end

  def initialize(*, @key : String, @path : String)
    @key_reader = Char::Reader.new(key)
    @path_reader = Char::Reader.new(path)
  end

  def while_matching
    while key_reader.has_next? && path_reader.has_next? && (key_reader.current_char == '*' || key_reader.current_char == ':' || path_reader.current_char == key_reader.current_char)
      yield
    end
  end

  def shared_key?
    if (path_reader.current_char != key_reader.current_char) && marker?
      return false
    end

    different = false

    while (path_continues? && path_char != '/') && (key_continues? && !marker?)
      if path_reader.current_char != key_reader.current_char
        different = true
        break
      end

      path_reader.next_char
      key_reader.next_char
    end

    !different && (!key_reader.has_next? || marker?)
  end

  def path_continues?
    path_reader.has_next?
  end

  def catch_all?
    key_reader.pos < key.bytesize && (
      (key_char == '/' && peek_key_char == '*') || key_char == '*'
    )
  end

  def path_trailing_slash_end?
    key.bytesize > 0 && path_reader.pos + 1 == path.bytesize && path_reader.current_char == '/'
  end

  def key_trailing_slash_end?
    key_reader.pos + 1 == key.bytesize && key_reader.current_char == '/'
  end

  def key_continues?
    key_reader.has_next?
  end

  def advance
    key_reader.next_char
    path_reader.next_char
  end

  def remaining_path
    path_slice path_pos
  end

  def marker?
    key_char == '/' || key_char == ':' || key_char == '*'
  end

  def end?
    !path_reader.has_next? && !key_reader.has_next?
  end

  def path_char
    path_reader.current_char
  end

  def key_char
    key_reader.current_char
  end

  def peek_key_char
    key_reader.peek_next_char
  end

  def next_key_char
    key_reader.next_char
  end

  def key_slice(*args)
    key_reader.string.byte_slice(*args)
  end

  def path_slice(*args)
    path_reader.string.byte_slice(*args)
  end

  def key_pos
    key_reader.pos
  end

  def key_pos=(value)
    key_reader.pos = value
  end

  def path_pos
    path_reader.pos
  end

  def path_pos=(value)
    path_reader.pos = value
  end

  def key_param_size
    self.class.detect_param_size(key_reader)
  end

  def path_param_size
    self.class.detect_param_size(path_reader)
  end
end
