struct Oak::Tree::Result(T)
  @@id = 0
  @id : Int32
  @matched = {} of HTTP::Request => T
  @nodes = [] of Branch(T)
  getter params = {} of String => String
  getter leaves = [] of T

  def initialize
    @id = @@id += 1
  end

  def key
    String.build do |io|
      @nodes.each do |node|
        io << node.key
      end
    end
  end

  def track(branch : Branch(T))
    @nodes << branch
    self
  end

  def use(branch : Branch(T))
    track branch
    @leaves.replace branch.leaves
    self
  end
end
