module Orion::Router::Constraints
  # :nodoc:
  CONSTRAINTS = [] of Constraint

  private macro setup_constraints
    {% if @type.superclass != ::Orion::Router %}
      CONSTRAINTS = ::{{@type.superclass}}::CONSTRAINTS.dup
    {% else %}
      CONSTRAINTS = [] of ::Orion::Constraint
    {% end %}
  end

  # Constrain routes by an `Orion::Constraint`
  macro constraint(constraint)
    constraints({{ constraint }}) do
      {{ yield }}
    end
  end

  # Constrain routes by one or more `Orion::Constraint`s
  macro constraints(*constraints)
    scope do
      {% for constraint, i in constraints %} # Add the array of provided constraints
        CONSTRAINTS << {{ constraint }}
      {% end %}
      {{ yield }}
    end
  end

  # Constrain routes by a given domain
  macro host(host)
    constraint(::Orion::HostConstraint.new({{ host }})) do
      {{ yield }}
    end
  end

  # Constrain routes by a given subdomain
  macro subdomain(subdomain)
    constraint(::Orion::SubdomainConstraint.new({{ subdomain }})) do
      {{ yield }}
    end
  end
end
