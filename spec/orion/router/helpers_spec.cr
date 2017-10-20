module Router::HelpersSpec
  c = ->(c : HTTP::Server::Context) {}

  class Router < Orion::Router
    get "foo", c, name: "foo"
    get "bars/:bar_id/locations/:location_id", c, name: "bar"
    scope name: "scoped" do
      get "baz", c, name: "baz"
      post "bazs", c, name: "baz", prefix: "create"
      get "bazs", c, name: "baz", suffix: "index"
    end
  end

  describe "helpers" do
    it "should define a basic helper" do
      Router::Helpers.foo_path.should eq "/foo"
    end

    it "should append params" do
      Router::Helpers.foo_path(f: 1, b: "2", r: true).should eq "/foo?f=1&b=2&r=true"
    end

    it "should insert url params" do
      Router::Helpers.bar_path(bar_id: 1, location_id: 5).should eq "/bars/1/locations/5"
    end

    it "should insert url params and append the rest" do
      Router::Helpers.bar_path(bar_id: 1, location_id: 5, pour: true).should eq "/bars/1/locations/5?pour=true"
    end

    it "should raise if a param is missing" do
      expect_raises do
        Router::Helpers.bar_path(bar_id: 1)
      end
    end

    context "within scope" do
      it "should scope nested routes" do
        Router::Helpers.scoped_baz_path.should eq "/baz"
      end

      it "should prefix a route" do
        Router::Helpers.create_scoped_baz_path.should eq "/bazs"
      end

      it "should suffix a route" do
        Router::Helpers.scoped_baz_index_path.should eq "/bazs"
      end
    end
  end
end
