module Orion::Middleware
  abstract def call(c : HTTP::Server::Context, &block : HTTP::Server::Context -> Nil)
end

require "./middleware/*"
