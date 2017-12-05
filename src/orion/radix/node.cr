class Orion::Radix::Node ; end
require "./node/*"

class Orion::Radix::Node
  enum Kind : UInt8
    Normal
    Named
    # Optional
    Glob
  end

  include Comparable(self)

  getter context : Context = Context.new
  getter key : String = ""
  getter priority : Int32 = 0
  protected getter kind = Kind::Normal
  delegate children, payloads, payloads?, to: @context
  private delegate sort!, to: children
  @root = false

  def initialize
    @root = true
  end

  def initialize(@key : String, @context : Context)
    @priority = compute_priority
  end

  def initialize(@key : String, payload : Payload? = nil)
    @priority = compute_priority
    payloads << payload if payload
  end

  def <=>(other : self)
    result = kind <=> other.kind
    return result if result != 0
    other.priority <=> priority
  end

  def add(path : String, payload : Payload)
    if placeholder?
      @key = path
      payloads << payload
      return self
    end

    analyzer = Analyzer.new(path: path, key: key)

    if analyzer.split_on_path?
      new_key = analyzer.remaining_path

      # Find a child key that matches the remaning path
      matching_child = children.find do |child|
        child.key[0]? == new_key[0]?
      end

      if matching_child
        # add the path & payload within the child node
        matching_child.add new_key, payload
      else
        # add a new node with the remaining path
        children << Node.new(new_key, payload)
      end

      # Reprioritze node
      sort!
    elsif analyzer.exact_match?
      payloads << payload
    elsif analyzer.split_on_key?
      # Readjust the key of this node
      self.key = analyzer.matched_key

      @context = Context.new(Node.new(analyzer.remaining_key, @context))

      # Determine if the path continues
      if analyzer.remaining_path?
        # Add a new node with the remaining_path
        children << Node.new(analyzer.remaining_path, payload)
      else
        # Insert the payload
        payloads << payload
      end

      # Reprioritze node
      sort!
    end
  end

  def children?
    !@childen.empty?
  end

  def find(path, result_set = ResultSet.new)
    if @root && (path.bytesize == key.bytesize && path == key) && payloads?
      result_set.use(self)
    end

    walker = Walker.new(path: path, key: key)

    walker.while_matching do
      case walker.key_char
      when '*'
        name = walker.key_slice(walker.key_pos + 1)
        value = walker.remaining_path
        result_set.params[name] = value unless name.empty?
        result_set.use(self)
        break
      when ':'
        key_size = walker.key_param_size
        path_size = walker.path_param_size
        name = walker.key_slice(walker.key_pos + 1, key_size - 1)
        value = walker.path_slice(walker.path_pos, path_size)

        result_set.params[name] = value

        walker.key_pos += key_size
        walker.path_pos += path_size
      else
        walker.advance
      end
    end

    if walker.end?
      result_set.use(self)
    end

    if walker.path_continues?
      if walker.path_trailing_slash_end?
        result_set.use(self)
      end
      children.each do |child|
        remaining_path = walker.remaining_path
        if child.should_walk?(remaining_path)
          result_set.track self
          child.find(remaining_path, result_set)
        end
      end
    end

    if walker.key_continues?
      if walker.key_trailing_slash_end?
        result_set.use(self)
      end

      if walker.catch_all?
        walker.next_key_char unless walker.key_char == '*'
      end

      name = walker.key_slice(walker.key_pos + 1)

      result_set.params[name] = ""

      result_set.use(self)
    end

    if dynamic_children?
      dynamic_children.each do |child|
        if child.should_walk?(path)
          result_set.track self
          child.find(path, result_set)
        end
      end
    end
    result_set
  end

  def matches_constraints?(request : HTTP::Request)
    payloads.any? &.matches_constraints? request
  end

  def viz
    String.build do |io|
      viz(0, io)
    end
  end

  protected def dynamic?
    key[0] == ':' || key[0] == '*'
  end

  protected def dynamic_children?
    children.any? &.dynamic?
  end

  protected def dynamic_children
    children.select &.dynamic?
  end

  protected def key=(@key)
    @kind = Kind::Normal # reset kind on change of key
    @priority = compute_priority
  end

  protected def shared_key?(path)
    Walker.new(path: path, key: key).shared_key?
  end

  protected def should_walk?(path)
    key[0]? == '*' || key[0]? == ':' || shared_key?(path)
  end

  protected def viz(depth : Int32, io : IO)
    io.puts "  " * depth + "⌙ " + key + (payloads? ? " (payloads: #{payloads.size})" : "")
    children.each &.viz(depth + 1, io)
  end

  private def placeholder?
    @root && key.empty? && children.empty?
  end

  private def compute_priority
    Char::Reader.new(key).tap do |reader|
      while reader.has_next?
        case reader.current_char
        when '*'
          @kind = Kind::Glob
          break
        # when '('
        #   @kind = Kind::Optional
        #   break
        when ':'
          @kind = Kind::Named
          break
        else
          reader.next_char
        end
      end
    end.pos
  end

end
