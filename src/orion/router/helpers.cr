abstract class Orion::Router
  private macro define_helper(*, method, path, name, prefix_name, suffix_name)
    {% name_parts = PREFIXES %}
    {% name_parts.unshift(prefix_name) if prefix_name %}
    {% name_parts.push(name) }
    {% name_parts.push(suffix_name) if prefix_name %}
    {% method_name = "#{name_parts.map(&.id).join("_").id}_path" %}

    module ROUTER::Helpers
      extend self

      {% raise "a route named `#{name}` already exists" if @type.has_method? method_name %}
      def {{method_name.id}}(**params)
        path = {{path}}
        result = ROUTER::FOREST.{{method.downcase.id}}.find(path)
        raise "unable to build path" unless result.found?
        path_param_names = result.params.keys
        params_hash = ({} of String => String).tap do |memo|
          params.each do |key, value|
            memo[key.to_s] = value.to_s
          end
        end

        params_hash.select { |name, _| path_param_names.includes? name }.each do |name, value|
          path = path.gsub /(:|\*)#{name}/, ""
        end

        url_params = params_hash.reject do |name, _|
          path_param_names.includes? name
        end

        query = HTTP::Params.encode(url_params) unless url_params.empty?

        URI.new(path: path, query: query).to_s.tap { |p| puts p }
      end
    end
  end
end
