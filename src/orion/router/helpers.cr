abstract class Orion::Router
  HELPER_PATHS = [] of String
  private macro define_helper(*, method, path, name, prefix, suffix)
    {% name_parts = PREFIXES + [] of StringLiteral %}
    {% name_parts.unshift(prefix) if prefix %}
    {% name_parts.push(name) }
    {% name_parts.push(suffix) if suffix %}
    {% method_name = name_parts.map(&.id).join("_").id %}
    ROUTER::FOREST.{{method.downcase.id}}.find(normalize_path({{path}})).payload.helper = {{ method_name.stringify }}

    module ROUTER::Helpers
      extend self

      {% raise "a route named `#{name}` already exists" if @type.has_method? method_name %}
      def {{method_name.id}}_path(**params)
        path = Helpers.%full_path
        result = ROUTER::FOREST.{{method.downcase.id}}.find(path)
        raise "unable to build path" unless result.found?
        path_param_names = result.params.keys

        # Convert all the params to a string
        params_hash = ({} of String => String).tap do |memo|
          params.each do |key, value|
            memo[key.to_s] = value.to_s
          end
        end

        # Assign the path params
        path_param_names.each do |name|
          path = path.gsub /(:|\*)#{name}/, params_hash[name]
          params_hash.delete name
        end

        query = HTTP::Params.encode(params_hash) unless params_hash.empty?

        URI.new(path: path, query: query).to_s
      end
    end

    # make the full path available
    protected def ROUTER::Helpers.%full_path
      ::{{@type}}.normalize_path({{path}})
    end
  end
end
