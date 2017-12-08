class Oak::Tree
  include HTTP::Handler

  @root = Branch.new
  delegate find, add, visualize, to: @root

  def call(context : ::HTTP::Server::Context)
    path = context.request.path
    find(path.rchop(File.extname(path))).call(context)
  end
end

require "./tree/*"
