module Oak::HashConstraint(T)
  include Constraint

  def initialize(constraints : Hash(Symbol, T))
    hash = constraints.each_with_object({} of String => T) do |(key, value), hash|
      hash[key.to_s] = value
    end
    initialize(hash)
  end

  def initialize(constraints : Hash(String, T))
    @constraints = constraints
  end
end
