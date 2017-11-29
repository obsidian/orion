module Router::VerbsSpec
  {% for verb in Orion::HTTP_VERBS %}
    module {{ verb.capitalize.id }}
      class SamplesController
        include Orion::Routable

        def to_{{verb.downcase.id}}
          response.print "to {{verb.downcase.id}}"
        end

        def {{verb.downcase.id}}
          response.print "controller {{verb.downcase.id}}"
        end

        def action_{{verb.downcase.id}}
          response.print "action {{verb.downcase.id}}"
        end
      end

      router SampleRouter do
        {{verb.downcase.id}} "/callable", ->(c : Context){ c.response.print "callable {{verb.downcase.id}}" }
        {{verb.downcase.id}} "/to-{{verb.downcase.id}}", to: "Samples#to_{{verb.downcase.id}}"
        {{verb.downcase.id}} "/{{verb.downcase.id}}-actionless", controller: SamplesController
        {{verb.downcase.id}} "/{{verb.downcase.id}}-action", controller: SamplesController, action: action_{{verb.downcase.id}}, helper: "sample_verbose"
      end

      describe {{ verb.downcase }} do
        context "with callable" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/callable")
            response.status_code.should eq 200
            response.body.should eq "callable {{verb.downcase.id}}"
          end
        end

        context "with to" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/to-{{verb.downcase.id}}")
            response.status_code.should eq 200
            response.body.should eq "to {{verb.downcase.id}}"
          end
        end

        context "with controller" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/{{verb.downcase.id}}-actionless")
            response.status_code.should eq 200
            response.body.should eq "controller {{verb.downcase.id}}"
          end
        end

        context "with controller and action" do
          it "should succeed" do
            response = SampleRouter.test_route(:{{ verb.downcase.id }}, "/{{verb.downcase.id}}-action")
            response.status_code.should eq 200
            response.body.should eq "action {{verb.downcase.id}}"
          end
        end
      end
    end
  {% end %}
end
