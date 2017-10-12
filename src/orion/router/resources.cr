abstract class Orion::Router
  macro resources(name, controller, *, shallow = false, only = nil, except = nil)
    resources name, controller, *, shallow = false, only = nil, except = nil do
    end
  end

  macro resources(name, controller, *, shallow = false, only = nil, except = nil)
    {% if shallow %}
      shallow do
        resources({{ name }}, {{ controller }}, only: {{ only }}, except: {{ except }}) do
          {{ yield }}
        end
      end
    {% else %}
      {% singular_name run "./inflector/singularize.cr", name %}
      {% plural_name run "./inflector/pluralize.cr", name %}

      scope "/#{plural_name}" do
        {% if ((!only || (only && only.includes?(:index))) && (except && !except.includes?(:index))) %}
          root controller: {{controller}}, action: index, name: {{ "#{plural_name}_index" }}
        {% end %}

        {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
          get {{ "/new" }}, controller: {{controller}}, action: new, name: {{ "new_#{singular_name}" }}
        {% end %}

        {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
          post {{ "/" }}, controller: {{controller}}, action: create, name: {{ "create_#{singular_name}" }}
        {% end %}

        {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
          get {{ "/:id" }}, controller: {{controller}}, action: show, name: {{ "#{singular_name}" }}
        {% end %}

        {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
          get {{ "/:id/edit" }}, controller: {{controller}}, action: edit, name: {{ "edit_#{singular_name}" }}
        {% end %}

        {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
          put {{ "/:id" }}, controller: {{controller}}, action: update, name: {{ "update_#{singular_name}" }}
        {% end %}

        {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
          patch {{ "/:id" }}, controller: {{controller}}, action: update
        {% end %}

        {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
          delete {{ "/:id" }}, controller: {{controller}}, action: destroy, name: {{ "delete_#{singular_name}" }}
        {% end %}

        {{ yield }}
      end
    {% end %}
  end

  macro resource(name, controller, *, only = nil, except = nil)
    resource name, controller, *, only = nil, except = nil do
    end
  end

  macro resource(name, controller, *, only = nil, except = nil)
    {% singular_name run "./inflector/singularize.cr", name %}

    scope "/#{singular_name}" do
      {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
        get {{ "/new" }}, controller: {{controller}}, action: new, name: {{ "new_#{singular_name}" }}
      {% end %}

      {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
        post {{ "/" }}, controller: {{controller}}, action: create, name: {{ "create_#{singular_name}" }}
      {% end %}

      {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
        get {{ "/" }}, controller: {{controller}}, action: show, name: {{ "#{singular_name}" }}
      {% end %}

      {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
        get {{ "/edit" }}, controller: {{controller}}, action: edit, name: {{ "edit_#{singular_name}" }}
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        put {{ "/" }}, controller: {{controller}}, action: update, name: {{ "update_#{singular_name}" }}
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        patch {{ "/" }}, controller: {{controller}}, action: update
      {% end %}

      {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
        delete {{ "/" }}, controller: {{controller}}, action: destroy, name: {{ "delete_#{singular_name}" }}
      {% end %}

      {{ yield }}
    end
  end
end
