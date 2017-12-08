module Oak::Router::Resources
  macro resources(name, controller, *, shallow = false, only = nil, except = nil)
    resources(name, controller, *, shallow: shallow, only: only, except: except){}
  end

  macro resources(name, controller, *, shallow = false, only = nil, except = nil)
    {% if shallow %}
      shallow do
        resources({{ name }}, {{ controller }}, only: {{ only }}, except: {{ except }}) do
          {{ yield }}
        end
      end
    {% else %}
      {% singular_name = run "./inflector/singularize.cr", name %}
      {% plural_name = run "./inflector/pluralize.cr", name %}

      scope "/#{plural_name}" do

        scope helper_prefix: {{ plural_name }} do
          {% if ((!only || (only && only.includes?(:index))) && (except && !except.includes?(:index))) %}
            get "/", controller: {{controller}}, action: index, helper: true
          {% end %}

          {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
            post {{ "/" }}, controller: {{controller}}, action: create
          {% end %}
        end

        scope {{ "/:#{singular_name}_id" }}, helper_prefix: {{ singular_name }} do

          {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
            get {{ "/new" }}, controller: {{controller}}, action: new, helper: { prefix: "new" }
          {% end %}

          {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
            get {{ "/" }}, controller: {{controller}}, action: show, helper: true
          {% end %}

          {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
            get {{ "/edit" }}, controller: {{controller}}, action: edit, helper: { prefix: "edit" }
          {% end %}

          {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
            put {{ "/" }}, controller: {{controller}}, action: update
          {% end %}

          {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
            patch {{ "/" }}, controller: {{controller}}, action: update
          {% end %}

          {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
            delete {{ "/" }}, controller: {{controller}}, action: destroy
          {% end %}

          {{ yield }}

        end
      end
    {% end %}
  end

  macro resource(name, controller, *, only = nil, except = nil)
    resource(name, controller, *, only: only, except: except) {}
  end

  macro resource(name, controller, *, only = nil, except = nil)
    {% singular_name = run("./inflector/singularize.cr", name) %}

    scope "/#{singular_name}", helper_prefix: {{singular_name}} do

      {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
        get {{ "/new" }}, controller: {{controller}}, action: new, helper: { prefix: "new" }
      {% end %}

      {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
        post {{ "/" }}, controller: {{controller}}, action: create
      {% end %}

      {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
        get {{ "/" }}, controller: {{controller}}, action: show, helper: true
      {% end %}

      {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
        get {{ "/edit" }}, controller: {{controller}}, action: edit, helper: { prefix: "edit" }
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        put {{ "/" }}, controller: {{controller}}, action: update
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        patch {{ "/" }}, controller: {{controller}}, action: update
      {% end %}

      {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
        delete {{ "/" }}, controller: {{controller}}, action: destroy
      {% end %}

      {{ yield }}
    end
  end
end
