module Orion::Controller
  # Parameter Helpers
  # Provides unified access to parameters from various sources
  #
  # Usage:
  #   post "/users" do
  #     name = params["name"]
  #     email = params["email"]
  #   end
  module ParamHelpers
    # Unified params that merges path_params, query_params
    # Priority: path_params > query_params
    def params : ParamsHash
      @_params ||= ParamsHash.new(context)
    end

    # Strong parameters support
    class ParamsHash
      def initialize(@context : Orion::Server::Context)
        @permitted_keys = Set(String).new
      end

      # Get parameter value
      def [](key : String | Symbol) : String
        self[key]? || raise ParametersMissing.new("Missing parameter: #{key}")
      end

      def []?(key : String | Symbol) : String?
        key_str = key.to_s

        # Check path params first (highest priority)
        if value = @context.request.path_params[key_str]?
          return value
        end

        # Check query params
        if value = @context.request.query_params[key_str]?
          return value
        end

        # Check form/body params (if parsed)
        # This would require middleware to parse body
        nil
      end

      # Get parameter as specific type
      def get(key : String | Symbol, type : T.class) : T forall T
        value = self[key]?
        return nil if value.nil? && T == Nil

        case type
        when Int32.class
          value.to_i32
        when Int64.class
          value.to_i64
        when Float64.class
          value.to_f64
        when Bool.class
          value.in?("true", "1", "yes", "on")
        else
          value.as(T)
        end
      end

      # Check if parameter exists
      def has_key?(key : String | Symbol) : Bool
        !!self[key]?
      end

      # Get all parameter keys
      def keys : Array(String)
        (@context.request.path_params.keys + @context.request.query_params.keys).uniq
      end

      # Convert to hash
      def to_h : Hash(String, String)
        result = {} of String => String
        keys.each do |key|
          result[key] = self[key]
        end
        result
      end

      # Strong parameters - require specific key
      def require(key : String | Symbol) : StrongParams
        key_str = key.to_s
        raise ParametersMissing.new("Missing parameter: #{key}") unless has_key?(key)
        StrongParams.new(self, key_str)
      end

      # Strong parameters - permit specific keys
      def permit(*keys : String | Symbol) : Hash(String, String)
        result = {} of String => String
        keys.each do |key|
          if value = self[key]?
            result[key.to_s] = value
          end
        end
        result
      end
    end

    # Strong params for nested parameters
    class StrongParams
      def initialize(@params : ParamsHash, @key : String)
      end

      def permit(*keys : String | Symbol) : Hash(String, String)
        # Simplified - in full implementation would handle nested params
        result = {} of String => String
        keys.each do |key|
          full_key = "#{@key}[#{key}]"
          if value = @params[full_key]?
            result[key.to_s] = value
          end
        end
        result
      end

      def []?(key : String | Symbol) : String?
        @params["#{@key}[#{key}]"]?
      end

      def [](key : String | Symbol) : String
        self[key]? || raise ParametersMissing.new("Missing parameter: #{@key}[#{key}]")
      end
    end
  end
end
