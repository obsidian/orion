require "json"

module Orion::API
  # Base JSON Serializer
  # Provides a clean API for serializing objects to JSON
  #
  # Usage:
  #   class UserSerializer < Orion::API::Serializer(User)
  #     attributes :id, :email, :name
  #     attribute :created_at { |user| user.created_at.to_s("%Y-%m-%d") }
  #
  #     has_many :posts, serializer: PostSerializer
  #     has_one :profile, serializer: ProfileSerializer
  #
  #     # Conditional attributes
  #     attribute :admin, if: ->(user : User) { user.admin? }
  #   end
  #
  #   UserSerializer.new(@user).to_json
  #   UserSerializer.new(@users).to_json  # Array support
  abstract class Serializer(T)
    # Class-level storage for serializer configuration
    @@attributes = [] of Symbol
    @@attribute_blocks = {} of Symbol => Proc(T, JSON::Any)
    @@attribute_conditions = {} of Symbol => Proc(T, Bool)
    @@relationships = {} of Symbol => NamedTuple(type: Symbol, serializer: Serializer.class)

    getter object : T | Array(T)
    getter meta : Hash(String, JSON::Any)?
    getter include : Array(Symbol)?

    def initialize(
      @object : T | Array(T),
      @meta : Hash(String, JSON::Any)? = nil,
      @include : Array(Symbol)? = nil
    )
    end

    # Define which attributes to serialize
    macro attributes(*attrs)
      {% for attr in attrs %}
        {% @@attributes << attr %}
      {% end %}
    end

    # Define a custom attribute with block
    macro attribute(name, if condition = nil, &block)
      {% @@attributes << name %}

      {% if block %}
        @@attribute_blocks[{{ name }}] = ->(object : T) {
          value = {{ block.body }}
          JSON.parse(value.to_json)
        }
      {% end %}

      {% if condition %}
        @@attribute_conditions[{{ name }}] = {{ condition }}
      {% end %}
    end

    # Define a has_many relationship
    macro has_many(name, serializer klass, if condition = nil)
      @@relationships[{{ name }}] = {
        type: :has_many,
        serializer: {{ klass }}
      }

      {% if condition %}
        @@attribute_conditions[{{ name }}] = {{ condition }}
      {% end %}
    end

    # Define a has_one/belongs_to relationship
    macro has_one(name, serializer klass, if condition = nil)
      @@relationships[{{ name }}] = {
        type: :has_one,
        serializer: {{ klass }}
      }

      {% if condition %}
        @@attribute_conditions[{{ name }}] = {{ condition }}
      {% end %}
    end

    # Serialize to JSON
    def to_json : String
      if @object.is_a?(Array)
        serialize_collection.to_json
      else
        serialize_single.to_json
      end
    end

    # Serialize to JSON::Any
    def as_json : JSON::Any
      if @object.is_a?(Array)
        JSON.parse(serialize_collection.to_json)
      else
        JSON.parse(serialize_single.to_json)
      end
    end

    private def serialize_collection : Hash(String, JSON::Any)
      result = {} of String => JSON::Any

      items = @object.as(Array(T)).map do |item|
        serialize_item(item)
      end

      result["data"] = JSON.parse(items.to_json)

      if meta = @meta
        result["meta"] = JSON.parse(meta.to_json)
      end

      result
    end

    private def serialize_single : Hash(String, JSON::Any)
      result = {} of String => JSON::Any
      result["data"] = JSON.parse(serialize_item(@object.as(T)).to_json)

      if meta = @meta
        result["meta"] = JSON.parse(meta.to_json)
      end

      result
    end

    private def serialize_item(object : T) : Hash(String, JSON::Any)
      attributes = {} of String => JSON::Any

      # Serialize defined attributes
      self.class.attributes.each do |attr|
        # Check condition
        if condition = self.class.attribute_conditions[attr]?
          next unless condition.call(object)
        end

        # Use custom block or default getter
        value = if block = self.class.attribute_blocks[attr]?
                  block.call(object)
                else
                  JSON.parse(object.{{ attr.id }}.to_json)
                end

        attributes[attr.to_s] = value
      end

      # Serialize relationships (if included)
      if include = @include
        self.class.relationships.each do |name, config|
          next unless include.includes?(name)

          # Check condition
          if condition = self.class.attribute_conditions[name]?
            next unless condition.call(object)
          end

          related = object.{{ name.id }}
          next unless related

          serializer = config[:serializer]
          attributes[name.to_s] = case config[:type]
                                  when :has_many
                                    serializer.new(related).as_json
                                  when :has_one
                                    serializer.new(related).as_json
                                  else
                                    JSON.parse("null")
                                  end
        end
      end

      attributes
    end

    # Class methods for accessing configuration
    def self.attributes
      @@attributes
    end

    def self.attribute_blocks
      @@attribute_blocks
    end

    def self.attribute_conditions
      @@attribute_conditions
    end

    def self.relationships
      @@relationships
    end
  end

  # JSON:API compliant serializer
  # Follows https://jsonapi.org/ specification
  #
  # Usage:
  #   class UserJSONAPISerializer < Orion::API::JSONAPISerializer(User)
  #     type "users"
  #     attributes :email, :name
  #     has_many :posts
  #   end
  abstract class JSONAPISerializer(T)
    getter object : T | Array(T)
    getter? include_relationships : Bool

    @@type : String?
    @@attributes = [] of Symbol
    @@relationships = {} of Symbol => Symbol  # name => type

    def initialize(@object : T | Array(T), @include_relationships : Bool = false)
    end

    macro type(name)
      @@type = {{ name }}
    end

    macro attributes(*attrs)
      {% for attr in attrs %}
        {% @@attributes << attr %}
      {% end %}
    end

    macro has_many(name, type = nil)
      @@relationships[{{ name }}] = {{ type || name }}
    end

    macro has_one(name, type = nil)
      @@relationships[{{ name }}] = {{ type || name }}
    end

    def to_json : String
      as_json.to_json
    end

    def as_json : Hash(String, JSON::Any)
      if @object.is_a?(Array)
        {
          "data" => JSON.parse(@object.as(Array).map { |item| resource_object(item) }.to_json)
        }
      else
        {
          "data" => JSON.parse(resource_object(@object.as(T)).to_json)
        }
      end
    end

    private def resource_object(object : T) : Hash(String, JSON::Any)
      result = {
        "id"   => JSON.parse(object.id.to_json),
        "type" => JSON.parse((@@type || "unknown").to_json),
      }

      # Add attributes
      attrs = {} of String => JSON::Any
      self.class.attributes.each do |attr|
        attrs[attr.to_s] = JSON.parse(object.{{ attr.id }}.to_json)
      end
      result["attributes"] = JSON.parse(attrs.to_json)

      # Add relationships (if requested)
      if @include_relationships
        rels = {} of String => JSON::Any
        self.class.relationships.each do |name, type|
          related = object.{{ name.id }}
          rels[name.to_s] = if related.is_a?(Array)
                              JSON.parse({data: related.map { |r| {id: r.id, type: type} }}.to_json)
                            else
                              JSON.parse({data: {id: related.id, type: type}}.to_json)
                            end
        end
        result["relationships"] = JSON.parse(rels.to_json) unless rels.empty?
      end

      result
    end

    def self.attributes
      @@attributes
    end

    def self.relationships
      @@relationships
    end
  end
end
