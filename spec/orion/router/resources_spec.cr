require "../../spec_helper"

module Router::Resources::Spec
  class UsersController
    include Orion::ControllerHelper

    def profile
      response.print "profile #{request.path_params["user_id"]}"
    end

    def index
      response.print "index"
    end

    def new
      response.print "new"
    end

    def create
      response.print "create"
    end

    def show
      response.print "show #{request.path_params["user_id"]}"
    end

    def edit
      response.print "edit #{request.path_params["user_id"]}"
    end

    def update
      response.print "update #{request.path_params["user_id"]}"
    end

    def delete
      response.print "delete #{request.path_params["user_id"]}"
    end
  end

  router SampleRouter do
    resources :users do
      get "profile", action: profile
    end
  end

  context "a basic resources definition" do
    it "should return the index action" do
      response = SampleRouter.test_route(:get, SampleRouter::Helpers.users_path)
      response.status_code.should eq 200
      response.body.should eq "index"
    end

    it "should return the new action" do
      response = SampleRouter.test_route(:get, SampleRouter::Helpers.new_user_path)
      response.status_code.should eq 200
      response.body.should eq "new"
    end

    it "should return the create action" do
      response = SampleRouter.test_route(:post, SampleRouter::Helpers.users_path)
      response.status_code.should eq 200
      response.body.should eq "create"
    end

    it "should return the show action" do
      response = SampleRouter.test_route(:get, SampleRouter::Helpers.user_path user_id: 1)
      response.status_code.should eq 200
      response.body.should eq "show 1"
    end

    it "should return the edit action" do
      response = SampleRouter.test_route(:get, SampleRouter::Helpers.edit_user_path user_id: 1)
      response.status_code.should eq 200
      response.body.should eq "edit 1"
    end

    it "should return the update action" do
      response = SampleRouter.test_route(:put, SampleRouter::Helpers.user_path user_id: 1)
      response.status_code.should eq 200
      response.body.should eq "update 1"
    end

    it "should return the update action" do
      response = SampleRouter.test_route(:patch, SampleRouter::Helpers.user_path user_id: 1)
      response.status_code.should eq 200
      response.body.should eq "update 1"
    end

    it "should return the update action" do
      response = SampleRouter.test_route(:delete, SampleRouter::Helpers.user_path user_id: 1)
      response.status_code.should eq 200
      response.body.should eq "delete 1"
    end

    it "should return the profile action" do
      response = SampleRouter.test_route(:get, "users/1/profile")
      response.status_code.should eq 200
      response.body.should eq "profile 1"
    end
  end

end
