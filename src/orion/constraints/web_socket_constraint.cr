# :nodoc:
struct Orion::WebSocketConstraint
  include Constraint

  def matches?(request : ::HTTP::Request)
    return false unless upgrade = request.headers["Upgrade"]?
    return false unless upgrade.compare("websocket", case_insensitive: true) == 0

    request.headers.includes_word?("Connection", "Upgrade")
  end
end
