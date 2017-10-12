record Orion::Router::Payload,
  proc : HTTP::Handler::Proc,
  handlers : Array(HTTP::Handler),
  label : String,
  name : String?
