require "../../spec_helper"

module Router::MatchSpec
  class SamplesController
    include Orion::Routable

    def to_match
      response.print "to match"
    end

    def match
      response.print "controller match"
    end

    def action_match
      response.print "action match"
    end
  end

  router SampleRouter do
    match "/callable", ->(c : Context){ c.response.print "callable match" }
    match "/to-match", to: "Samples#to_match"
    match "/match-actionless", controller: SamplesController
    match "/match-action", controller: SamplesController, action: action_match, helper: "sample_verbose"
  end

  {% for verb in Orion::HTTP_VERBS %}
    describe {{ verb.downcase }} do
      context "with callable" do
        it "should succeed" do
          response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/callable")
          response.status_code.should eq 200
          response.body.should eq "callable match"
        end
      end

      context "with to" do
        it "should succeed" do
          response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/to-match")
          response.status_code.should eq 200
          response.body.should eq "to match"
        end
      end

      context "with controller" do
        it "should succeed" do
          response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/match-actionless")
          response.status_code.should eq 200
          response.body.should eq "controller match"
        end
      end

      context "with controller and action" do
        it "should succeed" do
          response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/match-action")
          response.status_code.should eq 200
          response.body.should eq "action match"
        end
      end
    end
  {% end %}
end
