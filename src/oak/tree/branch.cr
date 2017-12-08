class Oak::Tree::Branch
  struct Context
    getter branches = [] of Branch
    getter leaves = [] of Leaf

    def initialize(branch : Branch? = nil)
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

  getter context : Context = Context.new
  getter key : String = ""
  getter priority : Int32 = 0
  protected getter kind = Kind::Normal
  delegate branches, leaves, to: @context
  private delegate sort!, to: branches
  @root = false

  def initialize
    @root = true
  end

  def initialize(@key : String, @context : Context)
    @priority = compute_priority
  end

  def initialize(@key : String, payload : Leaf? = nil)
    @priority = compute_priority
    leaves << payload if payload
  end

  def <=>(other : self)
    result = kind <=> other.kind
    return result if result != 0
    other.priority <=> priority
  end

  def add(path : String, payload : Leaf)
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

  def find(path, result_set = ResultSet.new)
    if @root && (path.bytesize == key.bytesize && path == key) && leaves?
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
      branches.each do |branch|
        remaining_path = walker.remaining_path
        if branch.should_walk?(remaining_path)
          result_set.track self
          branch.find(remaining_path, result_set)
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

    if dynamic_branches?
      dynamic_branches.each do |branch|
        if branch.should_walk?(path)
          result_set.track self
          branch.find(path, result_set)
        end
      end
    end
    result_set
  end

  def matches_constraints?(request : HTTP::Request)
    leaves.any? &.matches_constraints? request
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
