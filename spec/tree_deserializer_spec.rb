require_relative "spec_helper"
require_relative "../lib/conglomerate"

require "json"

describe Conglomerate::TreeDeserializer do
  it "deserializes collection with error" do
    json = '{"collection":{"version":"1.0","href":"https://apiv3.teamsnap.com/","links":[{"rel":"root","href":"https://apiv3.teamsnap.com/"},{"rel":"self","href":"https://apiv3.teamsnap.com/"}],"error":{"message":"translation missing: en.errors.messages.unauthorized"}}}'
    obj = JSON.parse(json)
    deserializer = Conglomerate::TreeDeserializer.new(obj)
    tree = deserializer.deserialize

    expect(tree.class).to eq(Conglomerate::Collection)
    expect(tree.error.class).to eq(Conglomerate::Error)
    expect(tree.href).to eq("https://apiv3.teamsnap.com/")
  end

  it "deserializes collection with items" do
    obj = {
      "collection" => {
        "version" => "1.0",
        "href" => "http://example.com/",
        "items" => [
          { "href" => "http://example.com/1", "data" => [{
            "name" => "is_unicorn", "value" => true
          }]}
        ]
      }
    }

    deserializer = Conglomerate::TreeDeserializer.new(obj)
    tree = deserializer.deserialize

    expect(
      tree.items.first.data.find { |datum| datum.name == "is_unicorn" }.value
    ).to eq(true)
  end
end
