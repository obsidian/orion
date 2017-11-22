module Router::HelpersSpec
  c = ->(c : HTTP::Server::Context) {}

  class SampleRouter < Orion::Router
    get "foo", c, helper: "foo"
    get "bars/:bar_id/locations/:location_id", c, helper: "bar"
    scope helper_prefix: "scoped" do
      get "baz", c, helper: "baz"
      post "bazs", c, helper: {name: "baz", prefix: "create"}
      get "bazs", c, helper: {name: "baz", suffix: "index"}
    end
  end

  describe "helpers" do
    it "should define a basic helper" do
      SampleRouter::Helpers.foo_path.should eq "/foo"
    end

    it "should append params" do
      SampleRouter::Helpers.foo_path(f: 1, b: "2", r: true).should eq "/foo?f=1&b=2&r=true"
    end

    it "should insert url params" do
      SampleRouter::Helpers.bar_path(bar_id: 1, location_id: 5).should eq "/bars/1/locations/5"
    end

    it "should insert url params and append the rest" do
      SampleRouter::Helpers.bar_path(bar_id: 1, location_id: 5, pour: true).should eq "/bars/1/locations/5?pour=true"
    end

    it "should raise if a param is missing" do
      expect_raises do
        SampleRouter::Helpers.bar_path(bar_id: 1)
      end
    end

    context "within scope" do
      it "should scope nested routes" do
        SampleRouter::Helpers.scoped_baz_path.should eq "/baz"
      end

      it "should prefix a route" do
        SampleRouter::Helpers.create_scoped_baz_path.should eq "/bazs"
      end

      it "should suffix a route" do
        SampleRouter::Helpers.scoped_baz_index_path.should eq "/bazs"
      end
    end
  end
end
