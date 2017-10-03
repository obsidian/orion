require "../spec_helper"

describe Orion::Router do
  it "mounts an app" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/app", io))
    io.tap(&.rewind).gets_to_end.should contain "app"
  end

  it "renders a proc" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/proc", io))
    io.tap(&.rewind).gets_to_end.should contain "proc"
  end

  it "renders a proc" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/callable", io))
    io.tap(&.rewind).gets_to_end.should contain "callable"
  end

  it "renders a route" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/foo/world", io))
    io.tap(&.rewind).gets_to_end.should contain "world"
  end

  it "runs middleware" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/foo/world", io))
    io.tap(&.rewind).gets_to_end.should contain "at root"
  end

  it "does not run group middleware" do
    io = IO::Memory.new
    SampleRouter.new.call(mock_context(:get, "/foo/world", io))
    io.tap(&.rewind).gets_to_end.should_not contain "in group"
  end

  context "within a group" do
    it "renders a route" do
      io = IO::Memory.new
      SampleRouter.new.call(mock_context(:get, "/in_group/mars", io))
      io.tap(&.rewind).gets_to_end.should contain "mars"
    end

    it "runs root middleware" do
      io = IO::Memory.new
      SampleRouter.new.call(mock_context(:get, "/in_group/mars", io))
      io.tap(&.rewind).gets_to_end.should contain "at root"
    end

    it "runs group middleware" do
      io = IO::Memory.new
      SampleRouter.new.call(mock_context(:get, "/in_group/mars", io))
      io.tap(&.rewind).gets_to_end.should contain "in group"
    end

    it "does not run deep group middleware" do
      io = IO::Memory.new
      SampleRouter.new.call(mock_context(:get, "/in_group/mars", io))
      io.tap(&.rewind).gets_to_end.should_not contain "in deep group"
    end
  end

  context "clear handlers" do
    it "clears handlers" do
      io = IO::Memory.new
      SampleRouter.new.call(mock_context(:get, "/in_group/no/handlers", io))
      text = io.tap(&.rewind).gets_to_end
      text.should contain "no handlers"
      text.should_not contain "at root"
    end
  end
end
