struct Orion::Router::Forest
  {% for method in Orion::Router::METHODS %}
    getter {{method.downcase.id}} = Tree.new
  {% end %}
end
