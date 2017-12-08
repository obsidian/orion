require "./hash_constraint"

struct Oak::ParamsConstraint
  include HashConstraint(Regex)

  def matches?(request : ::HTTP::Request)
    @constraints.all? do |key, regex|
      if value = request.path_params[key]?
        regex.match value
      end
    end
  end
end