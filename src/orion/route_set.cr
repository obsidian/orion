struct Orion::RouteSet
  private alias MethodHash = Hash(Symbol, Orion::Payload)
  private alias PathHash = Hash(String, MethodHash)

  @routes = {} of String => Hash(Symbol, Orion::Payload)

  delegate inspect, to: @routes

  def add(*, method : Symbol, path : String, payload : Orion::Payload)
    (@routes[path] ||= MethodHash.new)[method] = payload
  end

  def table
    rows = @routes.each_with_object([] of Array(String)) do |(path, methods), rows|
      methods.each do |method, payload|
        color = case method
                when :GET, :HEAD
                  :light_green
                when :PUT, :PATCH
                  :light_yellow
                when :DELETE
                  :light_red
                else
                  :cyan
                end
        method_string = method.to_s.colorize(color).to_s
        rows << [method_string, path, payload.label]
      end
    end
    ShellTable.new(
      labels: %w{METHOD PATH ACTION},
      label_color: :white,
      rows: rows
    )
  end
end
