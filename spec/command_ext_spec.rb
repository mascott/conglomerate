require_relative "spec_helper"
require_relative "../lib/conglomerate"
require_relative "../lib/conglomerate/ext/commands"

class CommandExtTestSerializer
  include Conglomerate::RootBuilder.serializer

  collection do
    command :populate do
      prompt { "test 123" }
      href { populate_items_url }
      datum :id
    end
  end
end

describe "Conglomerate Command Ext" do
  let(:object) do
    double(
      "Object",
      :id => 1
    )
  end

  let(:context) do
    double(
      "Context",
      :populate_items_url => "https://example.com/items/populate"
    )
  end

  let(:test_serializer) do
    CommandExtTestSerializer.new(object, :context => context).serialize
  end

  let(:test_collection) do
    test_serializer["collection"]
  end

  context "#command" do
    it "adds a command template to the collection" do
      expect(test_collection["commands"]).to match_array(
        [
          {
            "href" => "https://example.com/items/populate",
            "rel" => "populate",
            "prompt" => "test 123",
            "data" => [
              {"name" => "id", "value" => nil}
            ]
          }
        ]
      )
    end
  end
end
