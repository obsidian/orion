require "../../spec_helper"

module Router::ConcernsSpec
  router SampleRouter do
    concern :messagable do
      get "messages/new", ->(c : Context) { c.response.print "lets send a message" }
    end

    scope "users" do
      implements :messagable
    end

    scope "groups" do
      implements :messagable
    end
  end

  describe "concerns" do
    it "should be present when included" do
      response = SampleRouter.test_route(:get, "/users/messages/new")
      response.status_code.should eq 200
      response.body.should eq "lets send a message"
    end
  end
end
