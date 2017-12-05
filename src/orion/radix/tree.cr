class Orion::Radix::Tree
  include Orion::Handler

  @root = Node.new
  delegate find, add, visualize, to: @root

  def call(context : ::HTTP::Server::Context)
    path = context.request.path
    find(path.rchop(File.extname(path))).call(context)
  end
end
