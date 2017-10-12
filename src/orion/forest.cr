struct Orion::Forest
  {% for method in Orion::HTTP_VERBS %}
    getter {{method.downcase.id}} = Tree.new
  {% end %}

  def [](method)
    {% begin %}
      case method.to_s.downcase
        {% for method in Orion::HTTP_VERBS %}
      when {{method.downcase}}
        self.{{ method.downcase.id }}
        {% end %}
      else
        raise "invalid method"
      end
    {% end %}
  end
end
