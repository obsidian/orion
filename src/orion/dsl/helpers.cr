# Route helpers provide type-safe methods to generate paths and URLs to defined routes
# in your application. By including the `Helpers` module on the router (i.e. `MyApplicationRouter::Helpers`)
# you can access any helper defined in the router by `{{name}}_path` to get its corresponding
# route. In addition, when you have a `@context : HTTP::Server::Context` instance var,
# you will also be able to access a `{{name}}_url` to get the full URL.
#
# ```crystal
# scope "users", helper_prefix: "user" do
#   get "/new", to: "users#new", helper: "new"
# end
#
# class UsersController < BaseController
#   def new
#     File.open("new.html") { |f| IO.copy(f, response) }
#   end
#
#   def show
#     user = User.find(request.path_params["id"])
#     response.headers["Location"] = new_user_path
#     response.status_code = 301
#     response.close
#   end
# end
# ```
#
# #### Making route helpers from your routes
#
# In order to make a helper from your route, you can use the `helper` named argument in your route.
#
# ```crystal
# scope "users" do
#   get "/new", to: "Users#new", helper: "new"
# end
# ```
#
# #### Using route helpers in your code
#
# As you add helpers they are added to the nested `Helpers` module of your router.
# you may include this module anywhere in your code to get access to the methods,
# or call them on the module directly.
#
# _If `@context : HTTP::Server::Context` is present in the class, you will also be
# able to use the `{helper}_url` versions of the helpers._
#
# ```crystal
# resources :users
#
# class User
#   include RouteHelpers
#
#   def route
#     user_path user_id: self.id
#   end
# end
#
# puts RouteHelpers.users_path
# ```
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
        uri = URI.parse {{ method_name.id }}_path(**params, host: request.headers["Host"]?)
        uri.host = @context.request.headers["Host"]?
      end
    end
  end
end
