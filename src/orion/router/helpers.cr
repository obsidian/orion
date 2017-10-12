abstract class Orion::Router
  private macro define_helper(name, path, router, method)
    {% method_name = "#{name.id}_path" %}

    module Helpers
      {% raise "a route named `#{name}` already exists" if @type.has_method? method_name %}
      def {{method_name.id}}(**params)
        result = {{router}}::FOREST[method].find(path)
        raise "unable to build path" unless result.found?
        path_param_names = result.payload.params.keys

        params = params.to_hash.each_with_object({} of String => String) do |(name, value), memo|
          memo[name.to_s] = [value.to_s]
        end

        params.select { |name, _| path_param_names.include? name }.each do |name, value|
          path
        end

        url_params = params

        query = HTTP::Params.encode(hash)
      end
    end
  end
end
