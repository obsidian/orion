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

  class PersonController
    include Orion::ControllerHelper

    def profile
      response.print "profile"
    end

    def new
      response.print "new"
    end

    def create
      response.print "create"
    end

    def show
      response.print "show"
    end

    def edit
      response.print "edit"
    end

    def update
      response.print "update"
    end

    def delete
      response.print "delete"
    end
  end

  router SampleRouter do
    resources :users do
      get "profile", action: profile
    end

    resources :users_constrained, controller: UsersController, id_constraint: /^\d{4}$/, id_param: :user_id
    resources :users_api, controller: UsersController, id_param: :user_id, format: "json"
    resources :users_api_2, controller: UsersController, id_param: :user_id, accept: "application/json"

    resource :person do
      get "profile", action: profile
    end
    resource :person_api, controller: PersonController, format: "json"
    resource :person_api_2, controller: PersonController, accept: "application/json"
  end

  describe ".resources" do
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

    context "with an id constraint" do
      it "should return 200 when matched" do
        response = SampleRouter.test_route(:get, "users_constrained/9999")
        response.status_code.should eq 200
        response.body.should eq "show 9999"
      end

      it "should return 404 when not matched" do
        response = SampleRouter.test_route(:get, "users_constrained/9")
        response.status_code.should eq 404
      end
    end

    context "with a format constraint" do
      it "should return 200 when matched" do
        response = SampleRouter.test_route(:get, "users_api/1.json")
        response.status_code.should eq 200
        response.body.should eq "show 1"
      end

      it "should return 404 when not matched" do
        response = SampleRouter.test_route(:get, "users_api/1")
        response.status_code.should eq 404
      end
    end

    context "with an accept constraint" do
      it "should return 200 when matched with format" do
        response = SampleRouter.test_route(:get, "users_api_2/1.json")
        response.status_code.should eq 200
        response.body.should eq "show 1"
      end

      it "should return 200 when matched with header" do
        response = SampleRouter.test_route(:get, "users_api_2/1", headers: {"Accept" => "application/json"})
        response.status_code.should eq 200
        response.body.should eq "show 1"
      end

      it "should return 404 when not matched" do
        response = SampleRouter.test_route(:get, "users_api_2/1")
        response.status_code.should eq 404
      end
    end
  end

  describe ".resource" do
    it "should return the new action" do
      response = SampleRouter.test_route(:get, SampleRouter::Helpers.new_person_path)
      response.status_code.should eq 200
      response.body.should eq "new"
    end

    it "should return the create action" do
      response = SampleRouter.test_route(:post, SampleRouter::Helpers.person_path)
      response.status_code.should eq 200
      response.body.should eq "create"
    end

    it "should return the show action" do
      response = SampleRouter.test_route(:get, SampleRouter::Helpers.person_path)
      response.status_code.should eq 200
      response.body.should eq "show"
    end

    it "should return the edit action" do
      response = SampleRouter.test_route(:get, SampleRouter::Helpers.edit_person_path)
      response.status_code.should eq 200
      response.body.should eq "edit"
    end

    it "should return the update action" do
      response = SampleRouter.test_route(:put, SampleRouter::Helpers.person_path)
      response.status_code.should eq 200
      response.body.should eq "update"
    end

    it "should return the update action" do
      response = SampleRouter.test_route(:patch, SampleRouter::Helpers.person_path)
      response.status_code.should eq 200
      response.body.should eq "update"
    end

    it "should return the update action" do
      response = SampleRouter.test_route(:delete, SampleRouter::Helpers.person_path)
      response.status_code.should eq 200
      response.body.should eq "delete"
    end

    it "should return the profile action" do
      response = SampleRouter.test_route(:get, "person/profile")
      response.status_code.should eq 200
      response.body.should eq "profile"
    end

    context "with a format constraint" do
      it "should return 200 when matched" do
        response = SampleRouter.test_route(:get, "person_api.json")
        response.status_code.should eq 200
        response.body.should eq "show"
      end

      it "should return 404 when not matched" do
        response = SampleRouter.test_route(:get, "person_api")
        response.status_code.should eq 404
      end
    end

    context "with an accept constraint" do
      it "should return 200 when matched with format" do
        response = SampleRouter.test_route(:get, "person_api_2.json")
        response.status_code.should eq 200
        response.body.should eq "show"
      end

      it "should return 200 when matched with header" do
        response = SampleRouter.test_route(:get, "person_api_2", headers: {"Accept" => "application/json"})
        response.status_code.should eq 200
        response.body.should eq "show"
      end

      it "should return 404 when not matched" do
        response = SampleRouter.test_route(:get, "person_api_2")
        response.status_code.should eq 404
      end
    end
  end
end
