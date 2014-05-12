require_relative "spec_helper"
require_relative "../lib/conglomerate"

describe Conglomerate::Query do
  let(:query) {
    Conglomerate::Query.new(
      :href => "http://this.is.a.query/",
      :rel => "some_query"
    )
  }

  context "required attributes" do
    specify "href" do
      expect { Conglomerate::Query.new(:rel => "") }.to raise_error("MissingAttribute")
    end

    specify "rel" do
      expect { Conglomerate::Query.new(:href => "") }.to raise_error("MissingAttribute")
    end
  end

  context "data" do
    it "serializes properly" do
      datum = Conglomerate::Datum.new(:name => "name")

      query.data << datum
      expect(Conglomerate.serialize(query)["data"]).to include(Conglomerate.serialize(datum))
    end
  end
end
