module Oak::Router::Constraints
  CONSTRAINTS = [] of Constraint

  private macro setup_constraints
    {% if @type.superclass != ::Oak::Router %}
      CONSTRAINTS = ::{{@type.superclass}}::CONSTRAINTS.dup
    {% else %}
      CONSTRAINTS = [] of ::Oak::Constraint
    {% end %}
  end

  # Constrain routes by an `Oak::Constraint`
  macro constraint(constraint)
    constraints({{constraint}}) do
      {{yield}}
    end
  end

  # Constrain routes by one or more `Oak::Constraint`s
  macro constraints(*constraints)
    scope do
      {% for constraint, i in constraints %} # Add the array of provided constraints
        CONSTRAINTS << {{constraint}}
      {% end %}
      {{yield}}
    end
  end

  # Constrain routes by a given domain
  macro host(host)
    constraint(::Oak::HostConstraint.new({{host}})) do
      {{yield}}
    end
  end

  # Constrain routes by a given subdomain
  macro subdomain(subdomain)
    constraint(::Oak::SubdomainConstraint.new({{subdomain}})) do
      {{yield}}
    end
  end
end
