module Orion::DSL::Helpers
  private macro define_helper(*, base_path, path, spec)
    {% name_parts = PREFIXES + [] of StringLiteral %}

    {% if spec.is_a? BoolLiteral %}
      {% raise "Cannot use a boolean helper outside of a scope." if PREFIXES.size == 0 %}
    {% elsif spec.is_a?(NamedTupleLiteral) || spec.is_a?(HashLiteral) %}
      {% name_parts.unshift(spec[:prefix]) if spec[:prefix] %}
      {% name_parts.push(spec[:name]) if spec[:name] %}
      {% name_parts.push(spec[:suffix]) if spec[:suffix] %}
    {% elsif spec.is_a? StringLiteral %}
      {% name_parts.push(spec) if spec %}
    {% else %}
      {% raise "Unsupported spec type: #{spec.class_name}" %}
    {% end %}

    {% method_name = name_parts.map(&.id).join("_").id %}

    module ::{{ RouteHelpers }}
      # Returns the full path for `{{ method_name.id }}`
      def self.{{ method_name.id }}_path(**params)
        path = ::Orion::DSL.normalize_path(base_path: {{ base_path }}, path: {{ path }})
        result = TREE.find(path).not_nil!
        path_param_names = result.params.keys

        {% "Convert all the params to a string" %}
        params_hash = ({} of String => String).tap do |memo|
          params.each do |key, value|
            memo[key.to_s] = value.to_s
            result.params.delete key.to_s
          end
        end

        raise Orion::ParametersMissing.new(result.params.keys) unless result.params.keys.empty?

        # Assign the path params
        path_param_names.each do |name|
          path = path.gsub /(:|\*)#{name}/, params_hash[name]
          params_hash.delete name
        end

        query = HTTP::Params.encode(params_hash) unless params_hash.empty?

        URI.new(path: path, query: query).to_s
      end

      def {{ method_name.id }}_path(**params)
        ::{{ RouteHelpers }}.{{ method_name.id }}_path(**params)
      end

      # Returns the full url for `{{ method_name.id }}`
      def {{ method_name.id }}_url(**params)
        uri = URI.parse {{ method_name.id }}_path(**params, host: request.host_with_port)
        uri.host = @context.request.host_with_port
      end
    end
  end
end
