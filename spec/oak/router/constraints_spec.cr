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

    host "example.org" do
      get "golf", ->(c : Context) { c.response.print "at host" }
    end

    subdomain "example" do
      get "hotel", ->(c : Context) { c.response.print "at subdomain" }
    end

    constraint TestConstraint.new do
      get "lima", ->(c : Context) { c.response.print "matches custom" }
    end

    constraints TestConstraint.new do
      get "zulu", ->(c : Context) { c.response.print "matches customs" }
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

    describe "checking accept" do
      context "with a string" do
        context "if matched" do
          it "should pass" do
            response = SampleRouter.test_route(:get, "/delta", headers: { "Accept" => "image/png" })
            response.status_code.should eq 200
            response.body.should eq "is a png image"
          end
        end

        context "if matched by extension" do
          it "should pass" do
            response = SampleRouter.test_route(:get, "/delta.png")
            response.status_code.should eq 200
            response.body.should eq "is a png image"
          end
        end

        context "if matched by wildcard" do
          it "should pass" do
            response = SampleRouter.test_route(:get, "/delta", headers: { "Accept" => "*/*" })
            response.status_code.should eq 200
            response.body.should eq "is a png image"
          end
        end

        # context "if matched by partial" do
        #   it "should pass" do
        #     response = SampleRouter.test_route(:get, "/delta", headers: { "Accept" => "image/*" })
        #     response.status_code.should eq 200
        #     response.body.should eq "is a png image"
        #   end
        # end

        context "if not matched" do
          it "should not pass" do
            response = SampleRouter.test_route(:get, "/delta")
            response.status_code.should eq 404
          end
        end
      end
    end
  end
end
