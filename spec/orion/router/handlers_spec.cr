require "../../spec_helper"

module Router::HandlersSpec
  class AppendHandler
    include HTTP::Handler

    def initialize(@string : String)
    end

    def call(c : ::HTTP::Server::Context)
      call_next c
      c.response.print @string
    end
  end

  router SampleRouter do
    # use HTTP::ErrorHandler
    use AppendHandler.new ", and I am a guardian"
    root ->(c : Context) { c.response.print "I am Groot" }
    scope "scoped" do
      use AppendHandler.new ", and I am NOT a racoon"
      root ->(c : Context) { c.response.print "My name is Rocket" }
    end
  end

  describe "handlers" do
    it "should run root middleware" do
      response = SampleRouter.test_route(:get, "/")
      response.status_code.should eq 200
      response.body.should eq "I am Groot, and I am a guardian"
    end

    it "should run group middleware" do
      response = SampleRouter.test_route(:get, "/scoped")
      response.status_code.should eq 200
      response.body.should eq "My name is Rocket, and I am NOT a racoon, and I am a guardian"
    end

    it "should run handlers on unmatched routes" do
      response = SampleRouter.test_route(:get, "/unmatched")
      response.body.should eq "404 Not Found\n, and I am a guardian"
    end

    it "should run handlers on unmatched group routes" do
      response = SampleRouter.test_route(:get, "/scoped/unmatched")
      response.body.should eq "404 Not Found\n, and I am NOT a racoon, and I am a guardian"
    end
  end
end
