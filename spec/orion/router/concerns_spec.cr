require "../../spec_helper"

module Router::ConcernsSpec
  class Router < Orion::Router
    concern :messagable do
      get "messages/new", ->(c : Context) { c.response.print "lets send a message" }
    end

    scope "users" do
      concerns :messagable
    end

    scope "groups" do
      concerns :messagable
    end
  end

  describe "concerns" do
    it "should be present when included" do
      response = Router.test_route(:get, "/users/messages/new")
      response.status_code.should eq 200
      response.body.should eq "lets send a message"
    end
  end
end
