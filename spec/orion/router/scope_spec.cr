require "../../spec_helper"

module Router::ScopeSpec
  router SampleRouter do
    get "home", ->(c : Context) { c.response.print c.request.base_path }
    scope "messages" do
      get "new", ->(c : Context) { c.response.print c.request.base_path }
    end
  end

  describe "scope" do
    context "out of scope" do
      it "should have the default base path" do
        response = SampleRouter.test_route(:get, "/home")
        response.status_code.should eq 200
        response.body.should eq "/"
      end
    end

    context "within scope" do
      it "should set the base path" do
        response = SampleRouter.test_route(:get, "/messages/new")
        response.status_code.should eq 200
        response.body.should eq "/messages"
      end
    end
  end
end
