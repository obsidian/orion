abstract class Orion::Router
  CONSTRAINTS = [] of Constraint

  private macro setup_constraints
    {% if @type.superclass != ::Orion::Router %}
      CONSTRAINTS = ::{{@type.superclass}}::CONSTRAINTS.dup
    {% else %}
      CONSTRAINTS = [] of ::Orion::Constraint
    {% end %}
  end

  macro constraints(*constraints, headers = nil, cookies = nil, subdomain = nil, host = nil)
    scope do
      {% for constraint, i in constraints %} # Add the array of provided constraints
        CONSTRAINTS << {{constraint}}
      {% end %}
    end
  end

  macro constraints(headers = nil, cookies = nil, subdomain = nil, host = nil)
    scope do
      {% if headers %} # Check headers
        CONSTRAINTS << ::Orion::HeadersConstraint.new({{headers}}.to_h)
      {% end %}

      {% if cookies %} # Check cookies
        CONSTRAINTS << ::Orion::CookiesConstraint.new({{cookies}}.to_h)
      {% end %}

      {% if subdomain %} # Check subdomain
        CONSTRAINTS << ::Orion::SubdomainConstraint.new({{subdomain}})
      {% end %}

      {% if host %} # Check host
        CONSTRAINTS << ::Orion::HostConstraint.new({{host}})
      {% end %}

      {{ yield }}
    end
  end
end
