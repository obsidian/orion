require "../../spec_helper"

module Router::MethodsSpec
  {% for method in ::Orion::DSL::RequestMethods::METHODS %}
    module {{ method.capitalize.id }}
      router SampleRouter do
        {{ method.downcase.id }} "/callable", ->(c : Context){ c.response.print "callable {{ method.downcase.id }}" }
        {{ method.downcase.id }} "/block", helper: "block" do |c|
          c.response.print "block {{ method.downcase.id }}"
        end
        {{ method.downcase.id }} "/to-{{ method.downcase.id }}", to: "samples#to_{{ method.downcase.id }}"
        {{ method.downcase.id }} "/{{ method.downcase.id }}-action", controller: SamplesController, action: action_{{ method.downcase.id }}, helper: "sample_verbose"
      end

      class SamplesController < SampleRouter::BaseController
        def to_{{ method.downcase.id }}
          response.print "to {{ method.downcase.id }}"
        end

        def {{ method.downcase.id }}
          response.print "controller {{ method.downcase.id }}"
        end

        def action_{{ method.downcase.id }}
          response.print "action {{ method.downcase.id }}"
        end
      end

      describe {{ method.downcase }} do
        context "with callable" do
          it "should succeed" do
            response = test_route(SampleRouter.new, :{{ method.downcase.id }}, "/callable")
            response.status_code.should eq 200
            response.body.should eq "callable {{ method.downcase.id }}"
          end
        end

        context "with a block" do
          it "should succeed" do
            response = test_route(SampleRouter.new, :{{ method.downcase.id }}, "/block")
            response.status_code.should eq 200
            response.body.should eq "block {{ method.downcase.id }}"
          end
        end

        context "with to" do
          it "should succeed" do
            response = test_route(SampleRouter.new, :{{ method.downcase.id }}, "/to-{{ method.downcase.id }}")
            response.status_code.should eq 200
            response.body.should eq "to {{ method.downcase.id }}"
          end
        end

        context "with controller and action" do
          it "should succeed" do
            response = test_route(SampleRouter.new, :{{ method.downcase.id }}, "/{{ method.downcase.id }}-action")
            response.status_code.should eq 200
            response.body.should eq "action {{ method.downcase.id }}"
          end
        end
      end
    end
  {% end %}
end
