class Oak::Tree::Branch(T)
  struct Context(T)
    getter branches = [] of Branch(T)
    getter leaves = [] of T

    def initialize(branch : Branch(T)? = nil)
      branches << branch if branch
    end
  end

  enum Kind : UInt8
    Normal
    Named
    # Optional
    Glob
  end

  include Comparable(self)

  getter context = Context(T).new
  getter key : String = ""
  getter priority : Int32 = 0
  protected getter kind = Kind::Normal
  delegate branches, leaves, to: @context
  private delegate sort!, to: branches
  @root = false

  def initialize
    @root = true
  end

  def initialize(@key : String, @context : Context(T))
    @priority = compute_priority
  end

  def initialize(@key : String, payload : T? = nil)
    @priority = compute_priority
    leaves << payload if payload
  end

  def <=>(other : self)
    result = kind <=> other.kind
    return result if result != 0
    other.priority <=> priority
  end

  def add(path : String, payload : T)
    if placeholder?
      @key = path
      leaves << payload
      return self
    end

    analyzer = Analyzer.new(path: path, key: key)

    if analyzer.split_on_path?
      new_key = analyzer.remaining_path

      # Find a child key that matches the remaning path
      matching_child = branches.find do |branch|
        branch.key[0]? == new_key[0]?
      end

      if matching_child
        # add the path & payload within the child Branch
        matching_child.add new_key, payload
      else
        # add a new Branch with the remaining path
        branches << Branch.new(new_key, payload)
      end

      # Reprioritze Branch
      sort!
    elsif analyzer.exact_match?
      leaves << payload
    elsif analyzer.split_on_key?
      # Readjust the key of this Branch
      self.key = analyzer.matched_key

      @context = Context.new(Branch.new(analyzer.remaining_key, @context))

      # Determine if the path continues
      if analyzer.remaining_path?
        # Add a new Branch with the remaining_path
        branches << Branch.new(analyzer.remaining_path, payload)
      else
        # Insert the payload
        leaves << payload
      end

      # Reprioritze Branch
      sort!
    end
  end

  def leaves?
    !@childen.empty?
  end

  def search(path)
    ([] of Result(T)).tap do |results|
      search(path) do |result|
        results << result
      end
    end
  end

  def search(path, &block : Result(T) -> _)
    search(path, Result(T).new, &block)
  end

  protected def search(path, result : Result(T), &block : Result(T) -> _) : Nil

    if @root && (path.bytesize == key.bytesize && path == key) && leaves?
      block.call result.use(self)
      result = Result(T).new
    end

    walker = Walker.new(path: path, key: key)

    walker.while_matching do
      case walker.key_char
      when '*'
        name = walker.key_slice(walker.key_pos + 1)
        value = walker.remaining_path
        result.params[name] = value unless name.empty?
        block.call result.use(self)
        result = Result(T).new
        break
      when ':'
        key_size = walker.key_param_size
        path_size = walker.path_param_size
        name = walker.key_slice(walker.key_pos + 1, key_size - 1)
        value = walker.path_slice(walker.path_pos, path_size)

        result.params[name] = value

        walker.key_pos += key_size
        walker.path_pos += path_size
      else
        walker.advance
      end
    end

    if walker.end?
      block.call result.use(self)
      result = Result(T).new
    end

    if walker.path_continues?
      if walker.path_trailing_slash_end?
        block.call result.use(self)
        result = Result(T).new
      end
      branches.each do |branch|
        remaining_path = walker.remaining_path
        if branch.should_walk?(remaining_path)
          result.track self
          branch.search(remaining_path, result) do |inner_result|
            block.call inner_result
          end
          result = Result(T).new
        end
      end
    end

    if walker.key_continues?
      if walker.key_trailing_slash_end?
        block.call result.use(self)
        result = Result(T).new
      end

      if walker.catch_all?
        walker.next_key_char unless walker.key_char == '*'
      end

      name = walker.key_slice(walker.key_pos + 1)

      result.params[name] = ""

      block.call result.use(self)
      result = Result(T).new
    end

    if dynamic_branches?
      dynamic_branches.each do |branch|
        if branch.should_walk?(path)
          result.track self
          branch.search(path) do |inner_result|
            block.call inner_result
            result = Result(T).new
          end
        end
      end
    end
  end

  def visualize
    String.build do |io|
      visualize(0, io)
    end
  end

  protected def dynamic?
    key[0] == ':' || key[0] == '*'
  end

  protected def dynamic_branches?
    branches.any? &.dynamic?
  end

  protected def dynamic_branches
    branches.select &.dynamic?
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

  protected def visualize(depth : Int32, io : IO)
    io.puts "  " * depth + "⌙ " + key + (leaves? ? " (leaves: #{leaves.size})" : "")
    branches.each &.visualize(depth + 1, io)
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

  private def leaves?
    !leaves.empty?
  end

  private def placeholder?
    @root && key.empty? && leaves.empty?
  end
end
