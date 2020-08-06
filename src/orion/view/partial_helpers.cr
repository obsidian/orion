module Orion::View::PartialHelpers
  # Render a view partial
  macro render(*, partial, locals = NamedTuple.new)
    {% raise "Cannot call render outside a def" unless @def %}
    {% partial_file = run("./renderer/partial_finder.cr", @type.name, partial) %}
    {% partial_token = run("./renderer/tokenize.cr", partial_file) %}
    __template_string_{{ partial_token }}__(__cache_key__, {{ locals }}, __locals__)
  end

  # Render a collection into a partial
  macro render(*, partial, collection, cached = false)
    {% raise "Cannot call render outside a def" unless @def %}
    @collection.each do |item|
      cache_if({{ cached }}, item) do
        render(partial: {{ partial }}, locals: { item: {{ item }} })
      end
    end
  end
end
