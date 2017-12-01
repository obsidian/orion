abstract class Orion::Router
  CONSTRAINTS = [] of Orion::Constraint.class

  private macro setup_constraints
    {% if @type.superclass != ::Orion::Router %}
      CONSTRAINTS = ::{{@type.superclass}}::CONSTRAINTS.dup
    {% else %}
      CONSTRAINTS = [] of Orion::Radix::Constraint.class
    {% end %}
  end

  macro constraints(constraints_class)
    scope do
      CONSTRAINTS << {{constraints_class}}

      {{ yield }}
    end
  end

  macro constraints(*, headers = nil, cookies = nil, subdomain = nil, host = nil, port = nil)
    scope do
      {% constraints_class = run "./inflector/random_const.cr", "CustomConstraints" %}
      # :nodoc:
      class {{constraints_class}} < ::Orion::Radix::Constraint

        def matches?
          {% if headers %} # Check headers
            {% for key, value in headers %}
              return false unless request.headers[{{key.stringify}}] == {{value}} || request.headers[{{key.stringify}}] =~ {{value}}
            {% end %}
          {% end %}

          {% if cookies %} # Check cookies
            {% for key, value in cookies %}
              return false unless request.cookies[{{key.stringify}}] == {{value}} || request.cookies[{{key.stringify}}] =~ {{value}}
            {% end %}
          {% end %}

          {% if subdomain %} # Check subdomain
            host_parts = request.host.to_s.split('.')
            last_host_part = host_parts.pop
            host_parts.pop unless last_host_part = "localhost"
            subdomain = host_parts.join('.')
            return false unless subdomain == {{subdomain}} || subdomain =~ {{subdomain}}
          {% end %}

          {% if host %} # Check host
            return false unless request.host == {{host}} || request.host =~ {{host}}
          {% end %}

          {% if port %} # Check port
            return false unless request.host_with_port.to_s.split(':')[-1] =~ {{port}}
          {% end %}
        end
      end
      CONSTRAINTS << {{constraints_class}}

      {{ yield }}
    end
  end
end
