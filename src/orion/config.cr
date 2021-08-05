require "socket"
require "openssl"

# These are the options available when setting properties with the `config`
# method within your application.
class Orion::Config
  struct ReadOnly
    getter port : Int32?
    getter address : ::Socket::IPAddress | ::Socket::UNIXAddress | Nil
    getter host : String?
    getter path : String?
    getter name : String
    getter uri : URI?
    getter workers : Int32 | Int64
    getter asset_host : String?
    getter cache : Orion::Cache
    getter logger : Log?

    def initialize(config : Orion::Config)
      @port = config.port
      @address = config.address
      @host = config.host
      @path = config.path
      @name = config.name
      @uri = config.uri
      @workers = config.workers
      @asset_host = config.asset_host
      @cache = config.cache
      @logger = config.logger
    end
  end

  setter port : Int32? = 4000
  setter address : ::Socket::IPAddress | ::Socket::UNIXAddress | Nil
  setter host : String = ::Socket::IPAddress::LOOPBACK
  setter path : String?

  property name : String = File.basename Dir.current
  property socket : ::Socket::Server?
  property tls : ::OpenSSL::SSL::Context::Server?
  property reuse_port : Bool = false
  property autoclose : Bool = true
  property strip_extension : Bool = false
  property workers : Int32 | Int64 = 1
  property asset_host : String? = nil
  property cache : Orion::Cache = Orion::Cache.new
  property logger : Log? = Log.for(Orion)

  def port=(port : String)
    self.port = port.to_i32
  end

  def port=(port : Nil)
  end

  def uri=(uri : String)
    self.uri = URI.parse(uri)
  end

  def uri=(uri : URI)
    case uri.scheme
    when "tcp"
      self.address = Socket::IPAddress.parse(uri)
    when "unix"
      self.address = Socket::UNIXAddress.parse(uri)
    when "tls"
      self.address = Socket::IPAddress.parse(uri)
      self.tls = OpenSSL::SSL::Context::Server.from_hash(HTTP::Params.parse(uri.query || ""))
    else
      raise ArgumentError.new "Unsupported socket type: #{uri.scheme}"
    end
  end

  def uri
    case {address = self.address, tls = self.tls}
    when {::Socket::IPAddress, ::OpenSSL::SSL::Context::Server}
      URI.new(scheme: "tls", host: address.address, port: address.port)
    when {::Socket::IPAddress, Nil}
      URI.new(scheme: "tcp", host: address.address, port: address.port)
    when {::Socket::UNIXAddress, _}
      URI.new(scheme: "unix", path: address.path)
    else
      nil
    end
  end

  def host
    case (address = @address)
    when ::Socket::IPAddress
      address.address
    when ::Socket::UNIXAddress
      nil
    else
      @host
    end
  end

  def port
    case (address = @address)
    when ::Socket::IPAddress
      address.port
    when ::Socket::UNIXAddress
      nil
    else
      @port
    end
  end

  def path
    case (address = @address)
    when ::Socket::UNIXAddress
      address.path
    when ::Socket::IPAddress
      nil
    else
      @path
    end
  end

  def address
    address = @address
    host = @host
    port = @port
    path = @path
    return address if address
    return ::Socket::IPAddress.new(host, port) if host && port
    return ::Socket::UNIXAddress.new(path) if path
  end

  def readonly
    ReadOnly.new self
  end
end
