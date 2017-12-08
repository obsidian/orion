module Oak::Tree(T)
  def self.new
    Branch(T).new
  end
end

require "./tree/*"
