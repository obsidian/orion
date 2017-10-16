abstract class Orion::Router
  macro resources(name, controller, *, shallow = false, only = nil, except = nil, concerns = nil)
    resources(name, controller, *, shallow: shallow, only: only, except: except, concerns: concerns){}
  end

  macro resources(name, controller, *, shallow = false, only = nil, except = nil, concerns = nil)
    {% if shallow %}
      shallow do
        resources({{ name }}, {{ controller }}, only: {{ only }}, except: {{ except }}) do
          {{ yield }}
        end
      end
    {% else %}
      {% singular_name = run "./inflector/singularize.cr", name %}
      {% plural_name = run "./inflector/pluralize.cr", name %}

      {% if ((!only || (only && only.includes?(:index))) && (except && !except.includes?(:index))) %}
        get "/#{plural_name}", controller: {{controller}}, action: index, name: {{ "#{plural_name}_index" }}
      {% end %}

      scope "/#{plural_name}", name: {{ singular_name }} do

        {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
          get {{ "/new" }}, controller: {{controller}}, action: new, prefix_name: "new"
        {% end %}

        {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
          post {{ "/" }}, controller: {{controller}}, action: create, prefix_name: "create"
        {% end %}

        scope {{ "/:#{singular_name}_id" }}, concerns: concerns do

          {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
            get {{ "/" }}, controller: {{controller}}, action: show
          {% end %}

          {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
            get {{ "/edit" }}, controller: {{controller}}, action: edit, prefix_name: "edit"
          {% end %}

          {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
            put {{ "/" }}, controller: {{controller}}, action: update, prefix_name: "update"
          {% end %}

          {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
            patch {{ "/" }}, controller: {{controller}}, action: update
          {% end %}

          {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
            delete {{ "/" }}, controller: {{controller}}, action: destroy, prefix_name: "delete"
          {% end %}

          {{ yield }}

        end
      end
    {% end %}
  end

  macro resource(name, controller, *, only = nil, except = nil, concerns = nil)
    resource(name, controller, *, only: only, except: except, concerns: concerns) {}
  end

  macro resource(name, controller, *, only = nil, except = nil, concerns = nil)
    {% singular_name = run("./inflector/singularize.cr", name) %}

    scope "/#{singular_name}", concerns: concerns, name: {{singular_name}} do

      {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
        get {{ "/new" }}, controller: {{controller}}, action: new, prefix_name: "new"
      {% end %}

      {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
        post {{ "/" }}, controller: {{controller}}, action: create, prefix_name: "create"
      {% end %}

      {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
        get {{ "/" }}, controller: {{controller}}, action: show
      {% end %}

      {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
        get {{ "/edit" }}, controller: {{controller}}, action: edit, prefix_name: "edit"
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        put {{ "/" }}, controller: {{controller}}, action: update, prefix_name: "update"
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        patch {{ "/" }}, controller: {{controller}}, action: update
      {% end %}

      {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
        delete {{ "/" }}, controller: {{controller}}, action: destroy, prefix_name: "delete"
      {% end %}

      {{ yield }}
    end
  end
end
