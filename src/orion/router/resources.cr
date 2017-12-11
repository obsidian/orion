module Orion::Router::Resources
  macro resources(name, controller, *, only = nil, except = nil, id_constraint = nil)
    {% singular_name = run "./inflector/singularize.cr", name %}
    {% plural_name = run "./inflector/pluralize.cr", name %}

    scope "/#{plural_name}" do
      {% if format %}
        CONSTRAINTS << ::Orion::FormatConstraint.new({{ format }})
      {% end %}

      {% if accept %}
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ accept }})
      {% end %}

      scope helper_prefix: {{ plural_name }} do
        {% if ((!only || (only && only.includes?(:index))) && (except && !except.includes?(:index))) %}
          get "/", controller: {{ controller }}, action: index, helper: true
        {% end %}

        {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
          post {{ "/" }}, controller: {{ controller }}, action: create
        {% end %}
      end

      scope {{ "/:#{singular_name}_id" }}, helper_prefix: {{ singular_name }} do
        {% if id_constraint %}
          CONSTRAINTS << ::Orion::ParamsConstraint.new({ "#{singular_name}_id" => id_constraint })
        {% end %}

        {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
          get {{ "/new" }}, controller: {{ controller }}, action: new, helper: { prefix: "new" }
        {% end %}

        {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
          get {{ "/" }}, controller: {{ controller }}, action: show, helper: true
        {% end %}

        {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
          get {{ "/edit" }}, controller: {{ controller }}, action: edit, helper: { prefix: "edit" }
        {% end %}

        {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
          put {{ "/" }}, controller: {{ controller }}, action: update
        {% end %}

        {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
          patch {{ "/" }}, controller: {{ controller }}, action: update
        {% end %}

        {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
          delete {{ "/" }}, controller: {{ controller }}, action: destroy
        {% end %}

        {{ yield }}
      end
    end
  end

  macro resources(*args, **params)
    resources(*args, **params){}
  end

  macro resource(name, controller, *, only = nil, except = nil, format = nil, accept = nil)
    {% singular_name = run("./inflector/singularize.cr", name) %}

    scope "/#{singular_name}", helper_prefix: {{ singular_name }} do
      {% if format %}
        CONSTRAINTS << ::Orion::FormatConstraint.new({{ format }})
      {% end %}

      {% if accept %}
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ accept }})
      {% end %}

      {% if ((!only || (only && only.includes?(:new))) && (except && !except.includes?(:new))) %}
        get {{ "/new" }}, controller: {{ controller }}, action: new, helper: { prefix: "new" }
      {% end %}

      {% if ((!only || (only && only.includes?(:create))) && (except && !except.includes?(:create))) %}
        post {{ "/" }}, controller: {{ controller }}, action: create
      {% end %}

      {% if ((!only || (only && only.includes?(:show))) && (except && !except.includes?(:show))) %}
        get {{ "/" }}, controller: {{ controller }}, action: show, helper: true
      {% end %}

      {% if ((!only || (only && only.includes?(:edit))) && (except && !except.includes?(:edit))) %}
        get {{ "/edit" }}, controller: {{ controller }}, action: edit, helper: { prefix: "edit" }
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        put {{ "/" }}, controller: {{ controller }}, action: update
      {% end %}

      {% if ((!only || (only && only.includes?(:update))) && (except && !except.includes?(:update))) %}
        patch {{ "/" }}, controller: {{ controller }}, action: update
      {% end %}

      {% if ((!only || (only && only.includes?(:destroy))) && (except && !except.includes?(:destroy))) %}
        delete {{ "/" }}, controller: {{ controller }}, action: destroy
      {% end %}

      {{ yield }}
    end

    macro resource(*args, **params)
      resource(*args, **params) {}
    end
  end
end
