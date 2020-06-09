require "socket"
require "openssl"

class Orion::Config
  property socket : ::Socket::Server?
  property uri : String | URI | Nil
  property port : Int32? = 3000
  property path : String?
  property address : ::Socket::IPAddress | ::Socket::UNIXAddress | Nil
  property tls : OpenSSL::SSL::Context::Server?
  property host : String = "localhost"
  property reuse_port : Bool = false
end
