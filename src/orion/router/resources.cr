module Orion::Router::Resources
  macro resources(name, *, controller = nil, only = nil, except = nil, id_constraint = nil, format = nil, accept = nil, id_param = nil)
    {% raise "resource name must be a symbol" unless name.is_a? SymbolLiteral %}
    {% name = name.id %}
    {% singular_name = run "./inflector/singularize.cr", name %}
    {% id_param = (id_param || "#{singular_name.id}_id").id.stringify %}
    {% singular_underscore_name = run("./inflector/underscore.cr", singular_name) %}
    {% controller = controller || run("./inflector/controllerize.cr", name) + "Controller" %}
    {% underscore_name = run("./inflector/underscore.cr", name) %}

    scope {{ "/#{name}" }} do
      CONTROLLER = {{ controller }}

      {% if format %}
        CONSTRAINTS << ::Orion::FormatConstraint.new({{ format }})
      {% end %}

      {% if accept %}
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ accept }})
      {% end %}

      scope helper_prefix: {{ underscore_name }} do
        resource_action(:get, "/", :index, only: {{ only }}, except: {{ except }}, helper: true)
        resource_action(:post, "/", :create, only: {{ only }}, except: {{ except }})
      end

      scope helper_prefix: {{ singular_underscore_name }} do
        resource_action(:get, "/new", :new, only: {{ only }}, except: {{ except }}, helper: { prefix: "new" })
      end

      scope {{ "/:#{id_param.id}" }}, helper_prefix: {{ singular_underscore_name.stringify }} do
        {% if id_constraint %}
          CONSTRAINTS << ::Orion::ParamsConstraint.new({ {{ id_param }} => {{ id_constraint }} })
        {% end %}

        resource_action(:get, "", :show, only: {{ only }}, except: {{ except }}, helper: true)
        resource_action(:get, "/edit", :edit, only: {{ only }}, except: {{ except }}, helper: { prefix: "edit" })
        resource_action(:put, "", :update, only: {{ only }}, except: {{ except }})
        resource_action(:patch, "", :update, only: {{ only }}, except: {{ except }})
        resource_action(:delete, "", :delete, only: {{ only }}, except: {{ except }})

        {{ yield }}
      end
    end
  end

  macro resource(name, *, controller = nil, only = nil, except = nil, format = nil, accept = nil)
    {% raise "resource name must be a symbol" unless name.is_a? SymbolLiteral %}
    {% name = name.id %}
    {% controller = controller || run("./inflector/controllerize.cr", name) + "Controller" %}
    {% underscore_name = run("./inflector/underscore.cr", name) %}

    scope {{ "/#{name}" }}, helper_prefix: {{ underscore_name }} do
      CONTROLLER = {{ controller }}

      {% if format %}
        CONSTRAINTS << ::Orion::FormatConstraint.new({{ format }})
      {% end %}

      {% if accept %}
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ accept }})
      {% end %}

      resource_action(:get, "/new", :new, only: {{ only }}, except: {{ except }}, helper: { prefix: "new" })
      resource_action(:post, "", :create, only: {{ only }}, except: {{ except }})
      resource_action(:get, "", :show, only: {{ only }}, except: {{ except }}, helper: true)
      resource_action(:get, "/edit", :edit, only: {{ only }}, except: {{ except }}, helper: { prefix: "edit" })
      resource_action(:put, "", :update, only: {{ only }}, except: {{ except }})
      resource_action(:patch, "", :update, only: {{ only }}, except: {{ except }})
      resource_action(:delete, "", :delete, only: {{ only }}, except: {{ except }})

      {{ yield }}
    end
  end

  private macro resource_action(method, path, action, *, only = nil, except = nil, helper = false)
    {% except = !except || except.is_a?(ArrayLiteral) ? except : [except] %}
    {% only = !only || only.is_a?(ArrayLiteral) ? only : [only] %}
    {% if (!only || only.includes?(action)) && (!except || !except.includes?(action)) %}
      {{ method.id }}({{ path }}, action: {{ action.id }}, helper: {{ helper }})
    {% end %}
  end
end
