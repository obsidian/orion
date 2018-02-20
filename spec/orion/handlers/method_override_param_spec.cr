require "../../spec_helper"

describe Orion::Middleware::MethodOverrideParam do
  context "given a query param" do
    it "should set override the method" do
      context = mock_context(:get, "/?_method=POST")
      Orion::Middleware::MethodOverrideParam.new.call(context) {}
      context.request.method.should eq "POST"
    end
  end

  context "given a form param" do
    it "should set override the method" do
      io = IO::Memory.new
      builder = HTTP::FormData::Builder.new(io)
      builder.field("_method", "POST")
      builder.finish
      io.rewind
      context = mock_context(:get, "/", body: io, headers: { "Content-Type" => "multipart/form-data; boundary=\"#{builder.boundary}\"" })
      Orion::Middleware::MethodOverrideParam.new.call(context) {}
      context.request.method.should eq "POST"
    end
  end
end
