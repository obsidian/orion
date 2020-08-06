require "./view/*"

module Orion::View
  @rendered = false

  private macro setup_hooks!
    {% if @type.class? || @type.struct? %}
      alias ParentRenderer = ::Orion::View::Renderer
      class Renderer < ParentRenderer ; end

      private def __renderer__
        Renderer.new(self)
      end

      macro inherited
        {% verbatim do %}
          alias ParentRenderer = {{ @type.superclass }}::Renderer
          class Renderer < ParentRenderer ; end
          private def __renderer__
            Renderer.new(self)
          end
        {% end %}
      end
    {% else %}
      macro included
        setup_hooks!
      end
    {% end %}
  end

  setup_hooks!

  # Include a helper module in the view
  # Use this to add helpers to a view from a module
  macro view_helper(mod)
    class Renderer < ParentRenderer
      include {{ mod }}
    end
  end

  # A block that can be read by the view.
  # Use this to define methods that can be accessed by the view
  macro view_helper(&block)
    class Renderer < ParentRenderer
      {{ yield }}
    end
  end

  # Define a layout to be used within the controller
  macro layout(filename, *, locals = NamedTuple.new)
    {% raise "Cannot call layout within a def" if @def %}
    {% if filename == false %}
      {% layout_token = nil %}
    {% else %}
      {% layout_file = run("./view/renderer/layout_finder.cr", filename) %}
      {% layout_token = run("./view/renderer/tokenize.cr", layout_file) %}
    {% end %}

    # Render a view
    macro render(*, view = @def.name, layout = true, locals = NamedTuple.new, layout_locals = nil)
      \{% raise "Cannot call render outside a def" unless @def %}
      render_with_layout({{ layout_token }}, \{{ layout }}, \{{ view }}, {{ locals }}, \{{ layout_locals }}, \{{ locals }})
    end
  end

  # No layout by default
  layout false

  # :nodoc:
  private macro render_with_layout(layout_token, layout_option, view, layout_locals, layout_local_overrides, locals)
    raise ::Orion::DoubleRenderError.new("Already rendered, check #{self.class.name}") if @rendered

    # Render the view without a layout
    {% if layout_token == nil || layout_option == false || layout_option == nil %}
      {% view_file = run("./view/renderer/view_finder.cr", @type.name, view) %}
      {% view_token = run("./view/renderer/tokenize.cr", view_file) %}
      __renderer__.__template_{{ view_token }}__("", false, {{ locals }})
      @rendered = true

    # Render in a layout with the provided layout token
    {% elsif layout_option == true %}
      {% view_file = run("./view/renderer/view_finder.cr", @type.name, view) %}
      {% view_token = run("./view/renderer/tokenize.cr", view_file) %}
      __renderer__.__template_{{ layout_token }}__("", {{ layout_locals }}, {{ locals }}) do
        __renderer__.__template_string_{{ view_token }}__("", {{ locals }}, {{ layout_local_overrides }}, {{ layout_locals }})
      end
      @rendered = true

    # Generate a new layout token and
    {% elsif layout_option.is_a? StringLiteral %}
      {% layout_file = run("./view/renderer/layout_finder.cr", filename) %}
      {% layout_token = run("./view/renderer/tokenize.cr", layout_file) %}
      render_with_layout({{ layout_token }}, true, {{ view }}, {{ layout_locals }}, {{ layout_local_overrides }}, {{ locals }})

    # Raise if the expected shape is wrong
    {% else %}
      {% raise "layout must be of type `String | Nil | Bool`" %}
    {% end %}
  end
end
