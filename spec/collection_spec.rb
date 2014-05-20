require_relative "spec_helper"
require_relative "../lib/conglomerate"

describe Conglomerate::Collection do
  let(:collection) { Conglomerate::Collection.new }
  subject(:serialized_empty_collection) { Conglomerate.serialize(collection) }
  subject(:reference_empty_collection) {
    {
      "version" => "1.0"
    }
  }

  it "empty collection serializes properly" do
    expect(serialized_empty_collection).to eq(reference_empty_collection)
  end

  context "links" do
    it "serializes links correctly" do
      link = Conglomerate::Link.new(
        :href => "http://this.is.a.link",
        :rel => "Something"
      )

      collection.links << link
      expect(Conglomerate.serialize(collection)["links"]).to include(Conglomerate.serialize(link))
    end
  end

  context "queries" do
    it "serializes queries correctly" do
      query = Conglomerate::Query.new(
        :href => "http://this.is.a.query",
        :rel => "Something"
      )

      collection.queries << query
      expect(Conglomerate.serialize(collection)["queries"]).to include(Conglomerate.serialize(query))
    end
  end

  context "commands" do
    it "serializes commands correctly" do
      command = Conglomerate::Command.new(
        :href => "http://this.is.a.command",
        :rel => "Something"
      )

      collection.commands << command
      expect(Conglomerate.serialize(collection)["commands"]).to include(Conglomerate.serialize(command))
    end
  end
end
