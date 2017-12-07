require "../../spec_helper"

module Router::ConstraintsSpec
  class TestConstraint
    include Oak::Constraint

    def matches?(request : ::HTTP::Request)
      request.headers["TEST"]? == "true"
    end
  end

  router SampleRouter do
    get "resources/:id", ->(c : Context) { c.response.print "resource #{c.request.path_params["id"]}" }, constraints: {id: /\d{4}/}
    get "alpha", ->(c : Context) { c.response.print "is js" }, format: "js"
    get "bravo", ->(c : Context) { c.response.print "is js or jsx" }, format: /jsx?/
    get "charlie", ->(c : Context) { c.response.print "is an image" }, accept: "image/*"
    get "delta", ->(c : Context) { c.response.print "is a png image" }, accept: "image/png"
    get "echo", ->(c : Context) { c.response.print "is a png image with unicode" }, accept: "image/png; charset=utf-8"
    get "foxtrot", ->(c : Context) { c.response.print "is any image" }, accept: /image\/.*/

    constraints host: "example.org" do
      get "golf", ->(c : Context) { c.response.print "at host" }
    end

    constraints subdomain: "example" do
      get "hotel", ->(c : Context) { c.response.print "at subdomain" }
    end

    constraints headers: {"ContentType" => "application/json"} do
      get "juliet", ->(c : Context) { c.response.print "matches headers" }
    end

    constraints cookies: {"monster" => "blue"} do
      get "kilo", ->(c : Context) { c.response.print "matches cookies" }
    end

    constraints TestConstraint.new do
      get "lima", ->(c : Context) { c.response.print "matches cookies" }
    end
  end

  describe "constraints" do
    describe "for params" do
      context "if matched" do
        it "should pass" do
          response = SampleRouter.test_route(:get, "/resources/9999")
          response.status_code.should eq 200
          response.body.should eq "resource 9999"
        end
      end

      context "if not matched" do
        it "should not pass" do
          response = SampleRouter.test_route(:get, "/resources/123")
          response.status_code.should eq 404
        end
      end
    end

    describe "checking format" do
      context "with a string" do
        context "if matched" do
          it "should pass" do
            response = SampleRouter.test_route(:get, "/alpha.js")
            response.status_code.should eq 200
            response.body.should eq "is js"
          end
        end

        context "if not matched" do
          it "should not pass" do
            response = SampleRouter.test_route(:get, "/alpha.cr")
            response.status_code.should eq 404
          end
        end
      end
    end
  end
end
