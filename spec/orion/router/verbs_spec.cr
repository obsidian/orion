module Router::VerbsSpec
  {% for verb in Orion::HTTP_VERBS %}
    module {{ verb.capitalize.id }}
      class SamplesController
        include Orion::Routable

        def to_{{verb.downcase.id}}
          "to {{verb.id}}"
        end

        def {{verb.downcase.id}}
          "controller {{verb.id}}"
        end

        def action_{{verb.downcase.id}}
          "action {{verb.id}}"
        end
      end

      router SampleRouter do
        {{verb.downcase.id}} "/callable", ->(c : Context){ c.response.print "callable {{verb.downcase.id}}" }
        {{verb.downcase.id}} "/to-{{verb.downcase.id}}", to: "Samples#to_{{verb.downcase.id}}"
        {{verb.downcase.id}} "/{{verb.downcase.id}}-actionless", controller: SamplesController
        {{verb.downcase.id}} "/{{verb.downcase.id}}-action", controller: SamplesController, action: action_{{verb.downcase.id}}, helper: "sample_verbose"
      end

      describe {{ verb }} do
        context "with callable" do
          it "should succeed" do
          end
        end
      end
    end
  {% end %}
end
