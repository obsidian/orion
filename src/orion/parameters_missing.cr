class Orion::ParametersMissing < Exception
  def initialize(keys : Array(String))
    initialize("Missing parameters: #{keys.join(", ")}")
  end
end
