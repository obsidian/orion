require "../../spec_helper"

module Router::VerbsSpec
  {% for verb in ::HTTP::VERBS %}
    module {{ verb.capitalize.id }}
      class SamplesController
        include Orion::ControllerHelper

        def to_{{ verb.downcase.id }}
          response.print "to {{ verb.downcase.id }}"
        end

        def {{ verb.downcase.id }}
          response.print "controller {{ verb.downcase.id }}"
        end

        def action_{{ verb.downcase.id }}
          response.print "action {{ verb.downcase.id }}"
        end
      end

      router SampleRouter do
        {{ verb.downcase.id }} "/callable", ->(c : Context){ c.response.print "callable {{ verb.downcase.id }}" }
        {{ verb.downcase.id }} "/block", helper: "block" do |c|
          c.response.print "block {{ verb.downcase.id }}"
        end
        {{ verb.downcase.id }} "/to-{{ verb.downcase.id }}", to: "samples#to_{{ verb.downcase.id }}"
        {{ verb.downcase.id }} "/{{ verb.downcase.id }}-action", controller: SamplesController, action: action_{{ verb.downcase.id }}, helper: "sample_verbose"
      end

      describe {{ verb.downcase }} do
        context "with callable" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/callable")
            response.status_code.should eq 200
            response.body.should eq "callable {{ verb.downcase.id }}"
          end
        end

        context "with a block" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/block")
            response.status_code.should eq 200
            response.body.should eq "block {{ verb.downcase.id }}"
          end
        end

        context "with to" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/to-{{ verb.downcase.id }}")
            response.status_code.should eq 200
            response.body.should eq "to {{ verb.downcase.id }}"
          end
        end

        context "with controller and action" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/{{ verb.downcase.id }}-action")
            response.status_code.should eq 200
            response.body.should eq "action {{ verb.downcase.id }}"
          end
        end
      end
    end
  {% end %}
end
