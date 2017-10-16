require "../spec_helper"

params = {} of String => String

module RouterSpec
  class Router < Orion::Router
    root ->(c : Context) { c.response.print "I am Groot" }
    get "/:first/:second", ->(c : Context) { params = c.request.query_params }
  end

  describe "a basic router" do
    it "should run a basic route" do
      response = Router.test_route(:get, Router::Helpers.root_path)
      response.status_code.should eq 200
      response.body.should eq "I am Groot"
    end

    it "should parse params" do
      response = Router.test_route(:get, "/foo/bar")
      response.status_code.should eq 200
      params["first"].should eq "foo"
      params["second"].should eq "bar"
    end
  end
end
