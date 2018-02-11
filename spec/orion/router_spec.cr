require "../spec_helper"

params = {} of String => String

module RouterSpec
  router Router do
    root ->(c : Context) { c.response.print "I am Groot" }
    get "/:first/:second", ->(c : Context) { params = c.request.path_params }
    put "/hello", ->(c : Context) { c.response.print "I put things" }
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

  describe "method override header" do
    it "should override the header" do
      response = Router.test_route(:get, "/hello", headers: { "X-Method-Override" => "PUT" })
      response.status_code.should eq 200
      response.body.should eq "I put things"
    end
  end

  describe "missing route" do
    it "should return 404" do
      response = Router.test_route(:get, "/missing")
      response.status_code.should eq 404
    end
  end
end
