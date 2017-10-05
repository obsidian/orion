abstract class Orion::Router
  getter routes = {} of String => Hash(Symbol, Payload)

  def self.routes
    new.routes
  end

  def self.route_table
    new.route_table
  end

  def route_table
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
