require "../spec_helper"

params = {} of String => String

module RouterSpec
  router Router do
    static "/assets", "./spec/fixtures"
    root ->(c : Context) { c.response.print "I am Groot" }
    root to: "sample#action"
    root to: "SampleController#action"
    root controller: SampleController, action: action
    root do |c|
      params = c.request.path_params
    end
    get "/:first/:second", ->(c : Context) { params = c.request.path_params }
    get "/:first/:second", to: "sample#action"
    get "/:first/:second", to: "SampleController#action"
    get "/:first/:second", to: "SampleController#action"
    get "/:first/:second", controller: SampleController, action: action
    get "/:first/:second" do |c|
      params = c.request.path_params
    end
    head "/:first/:second", ->(c : Context) { params = c.request.path_params }
    head "/:first/:second", to: "sample#action"
    head "/:first/:second", to: "SampleController#action"
    head "/:first/:second", controller: SampleController, action: action
    head "/:first/:second" do |c|
      params = c.request.path_params
    end
    post "/:first/:second", ->(c : Context) { params = c.request.path_params }
    post "/:first/:second", to: "sample#action"
    post "/:first/:second", to: "SampleController#action"
    post "/:first/:second", controller: SampleController, action: action
    post "/:first/:second" do |c|
      params = c.request.path_params
    end
    put "/:first/:second", ->(c : Context) { params = c.request.path_params }
    put "/:first/:second", to: "sample#action"
    put "/:first/:second", to: "SampleController#action"
    put "/:first/:second", controller: SampleController, action: action
    put "/:first/:second" do |c|
      params = c.request.path_params
    end
    delete "/:first/:second", ->(c : Context) { params = c.request.path_params }
    delete "/:first/:second", to: "sample#action"
    delete "/:first/:second", to: "SampleController#action"
    delete "/:first/:second", controller: SampleController, action: action
    delete "/:first/:second" do |c|
      params = c.request.path_params
    end
    connect "/:first/:second", ->(c : Context) { params = c.request.path_params }
    connect "/:first/:second", to: "sample#action"
    connect "/:first/:second", to: "SampleController#action"
    connect "/:first/:second", controller: SampleController, action: action
    connect "/:first/:second" do |c|
      params = c.request.path_params
    end
    options "/:first/:second", ->(c : Context) { params = c.request.path_params }
    options "/:first/:second", to: "sample#action"
    options "/:first/:second", to: "SampleController#action"
    options "/:first/:second", controller: SampleController, action: action
    options "/:first/:second" do |c|
      params = c.request.path_params
    end
    trace "/:first/:second", ->(c : Context) { params = c.request.path_params }
    trace "/:first/:second", to: "sample#action"
    trace "/:first/:second", to: "SampleController#action"
    trace "/:first/:second", controller: SampleController, action: action
    trace "/:first/:second" do |c|
      params = c.request.path_params
    end
    patch "/:first/:second", ->(c : Context) { params = c.request.path_params }
    patch "/:first/:second", to: "sample#action"
    patch "/:first/:second", to: "SampleController#action"
    patch "/:first/:second", controller: SampleController, action: action
    patch "/:first/:second" do |c|
      params = c.request.path_params
    end
    match "/:first/:second", ->(c : Context) { params = c.request.path_params }
    match "/:first/:second", to: "sample#action"
    match "/:first/:second", to: "SampleController#action"
    match "/:first/:second", controller: SampleController, action: action
    match "/:first/:second" do |c|
      params = c.request.path_params
    end
    put "/hello", ->(c : Context) { c.response.print "I put things" }
    ws "/socket", ->(s : WebSocket, c : Context) {
      s.send "hello world"
    }
    ws "/:first/:second", to: "web_socket_sample#action"
    ws "/:first/:second", to: "WebSocketSampleController#action"
    ws "/:first/:second", controller: WebSocketSampleController, action: action
    ws "/:first/:second" do |s, c|
      s.send "hello world"
    end
  end

  class SampleController < Router::BaseController
    def action
      params = request.path_params
    end
  end

  class WebSocketSampleController < Router::BaseWebSocketController
    def action
      ws.send "hello world"
    end
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
      response = Router.test_route(:get, "/hello", headers: {"X-Method-Override" => "PUT"})
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
