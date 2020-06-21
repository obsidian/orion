# A common way in Orion to route is to do so against a known resource. This method
# will create a series of routes targeted at a specific controller.
#
# _The following is an example controller definition and the matching
# resources definition._
#
# ```crystal
# class PostsController
#   include Orion::ControllerHelper
#   include ResponseHelpers
#
#   def index
#     @posts = Post.all
#     render :index
#   end
#
#   def new
#     @post = Post.new
#     render :new
#   end
#
#   def create
#     post = Post.create(request)
#     redirect to: post_path post_id: post.id
#   end
#
#   def show
#     @post = Post.find(request.path_params["post_id"])
#   end
#
#   def edit
#     @post = Post.find(request.path_params["post_id"])
#     render :edit
#   end
#
#   def update
#     post = Post.find(request.path_params["post_id"])
#     HTTP::FormData.parse(request) do |part|
#       post.attributes[part.name] = part.body.gets_to_end
#     end
#     redirect to: post_path post_id: post.id
#   end
#
#   def delete
#     post = Post.find(request.path_params["post_id"])
#     post.delete
#     redirect to: posts_path
#   end
#
# end
#
# resources :posts
# ```
#
# #### Including/Excluding Actions
#
# By default, the actions `index`, `new`, `create`, `show`, `edit`, `update`, `delete`
# are included. You may include or exclude explicitly by using the `only` and `except` params.
#
# > NOTE: The index action is not added for [singular resources](#singular-resources).
#
# ```crystal
# resources :posts, except: [:edit, :update]
# resources :users, only: [:new, :create, :show]
# ```
#
# #### Nested Resources and Routes
#
# You can add nested resources and member routes by providing a block to the
# `resources` definition.
#
# ```crystal
# resources :posts do
#   post "feature", action: feature
#   resources :likes
#   resources :comments
# end
# ```
#
# #### Singular Resources
#
# In addition to using the collection of `resources` method, You can also add
# singular resources which do not provide a `id_param` or `index` action.
#
# ```crystal
# resource :profile
# ```
#
# #### Customizing ID
#
# You can customize the ID path parameter by passing the `id_param` parameter.
#
# ```crystal
# resources :posts, id_param: :article_id
# ```
#
# #### Constraining the ID
#
# You can set constraints on the ID parameter by passing the `id_constraint` parameter.
#
# See `Orion::DSL::Constraints` for more details on constraints.
#
# ```crystal
# resources :posts, id_constraint: /^\d{4}$/
# ```
module Orion::DSL::Resources
  macro resources(name, *, controller = nil, only = nil, except = nil, id_constraint = nil, format = nil, accept = nil, id_param = nil, content_type = nil, type = nil)
    {% raise "resource name must be a symbol" unless name.is_a? SymbolLiteral %}
    {% name = name.id %}
    {% singular_name = run "./inflector/singularize.cr", name %}
    {% id_param = (id_param || "#{singular_name.id}_id").id.stringify %}
    {% singular_underscore_name = run("./inflector/underscore.cr", singular_name) %}
    {% controller = controller || run("./inflector/controllerize.cr", name.downcase) %}
    {% underscore_name = run("./inflector/underscore.cr", name) %}

    scope {{ "/#{name}" }}, controller: {{ controller }} do
      {% if content_type %} # Define the content type constraint
        CONSTRAINTS << ::Orion::ContentTypeConstraint.new({{ content_type }})
      {% end %}

      {% if type %} # Define the content type and accept constraint
        CONSTRAINTS << ::Orion::ContentTypeConstraint.new({{ type }})
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ type }})
      {% end %}

      {% if format %} # Define the format constraint
        CONSTRAINTS << ::Orion::FormatConstraint.new({{ format }})
      {% end %}

      {% if accept %} # Define the accept constraint
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ accept }})
      {% end %}

      scope helper_prefix: {{ underscore_name }} do
        resource_action(:get, "/", :index, only: {{ only }}, except: {{ except }}, helper: true)
        resource_action(:post, "/", :create, only: {{ only }}, except: {{ except }})
      end

      scope helper_prefix: {{ singular_underscore_name }} do
        resource_action(:get, "/new", :new, only: {{ only }}, except: {{ except }}, helper: { prefix: "new" })
      end

      scope {{ "/:#{id_param.id}" }}, helper_prefix: {{ singular_underscore_name.stringify }} do
        {% if id_constraint %}
          CONSTRAINTS << ::Orion::ParamsConstraint.new({ {{ id_param }} => {{ id_constraint }} })
        {% end %}

        resource_action(:get, "", :show, only: {{ only }}, except: {{ except }}, helper: true)
        resource_action(:get, "/edit", :edit, only: {{ only }}, except: {{ except }}, helper: { prefix: "edit" })
        resource_action(:put, "", :update, only: {{ only }}, except: {{ except }})
        resource_action(:patch, "", :update, only: {{ only }}, except: {{ except }})
        resource_action(:delete, "", :delete, only: {{ only }}, except: {{ except }})

        {{ yield }}
      end
    end
  end

  macro resource(name, *, controller = nil, only = nil, except = nil, format = nil, accept = nil, content_type = nil, type = nil)
    {% raise "resource name must be a symbol" unless name.is_a? SymbolLiteral %}
    {% name = name.id %}
    {% controller = controller || run("./inflector/controllerize.cr", name.downcase) %}
    {% underscore_name = run("./inflector/underscore.cr", name) %}

    scope {{ "/#{name}" }}, helper_prefix: {{ underscore_name }}, controller: {{ controller }} do
      {% if content_type %} # Define the content type constraint
        CONSTRAINTS << ::Orion::ContentTypeConstraint.new({{ content_type }})
      {% end %}

      {% if type %} # Define the content type and accept constraint
        CONSTRAINTS << ::Orion::ContentTypeConstraint.new({{ type }})
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ type }})
      {% end %}

      {% if format %} # Define the format constraint
        CONSTRAINTS << ::Orion::FormatConstraint.new({{ format }})
      {% end %}

      {% if accept %} # Define the accept constraint
        CONSTRAINTS << ::Orion::AcceptConstraint.new({{ accept }})
      {% end %}

      resource_action(:get, "/new", :new, only: {{ only }}, except: {{ except }}, helper: { prefix: "new" })
      resource_action(:post, "", :create, only: {{ only }}, except: {{ except }})
      resource_action(:get, "", :show, only: {{ only }}, except: {{ except }}, helper: true)
      resource_action(:get, "/edit", :edit, only: {{ only }}, except: {{ except }}, helper: { prefix: "edit" })
      resource_action(:put, "", :update, only: {{ only }}, except: {{ except }})
      resource_action(:patch, "", :update, only: {{ only }}, except: {{ except }})
      resource_action(:delete, "", :delete, only: {{ only }}, except: {{ except }})

      {{ yield }}
    end
  end

  private macro resource_action(method, path, action, *, only = nil, except = nil, helper = false)
    {% except = !except || except.is_a?(ArrayLiteral) ? except : [except] %}
    {% only = !only || only.is_a?(ArrayLiteral) ? only : [only] %}
    {% if (!only || only.includes?(action)) && (!except || !except.includes?(action)) %}
      {{ method.id }}({{ path }}, action: {{ action.id }}, helper: {{ helper }})
    {% end %}
  end
end
