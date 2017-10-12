require "../spec_helper"

module RouterSpec
  class Router < Orion::Router
    root ->(c : Context) { c.response.print "I am Groot" }
  end

  describe "a basic router" do
    it "should run a basic route" do
      response = Router.test_route(:get, "/")
      response.status_code.should eq 200
      response.body.should eq "I am Groot"
    end
  end
end
