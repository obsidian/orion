require "socket"
require "openssl"

# These are the options available when setting properties with the `config`
# method within your application.
struct Orion::Config
  property socket : ::Socket::Server?
  property uri : String | URI | Nil
  property port : Int32? = 4000
  property path : String?
  property address : ::Socket::IPAddress | ::Socket::UNIXAddress | Nil
  property tls : ::OpenSSL::SSL::Context::Server?
  property host : String = "localhost"
  property reuse_port : Bool = false
end
