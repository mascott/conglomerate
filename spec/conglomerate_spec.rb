require_relative "spec_helper"
require_relative "../lib/conglomerate"

class ConglomerateTestSerializer
  include Conglomerate.serializer

  href { test_url }
  item_href { |item| item_url(item.id) }

  attribute :description, :template => true
  attribute :id
  attribute :event_id, :rel => :event do |item|
    event_url(item.event_id)
  end
  attribute :roster_id, :rel => :roster do |item|
    roster_url(item.roster_id)
  end
  attribute :team_ids, :rel => :teams do |item|
    team_url(item.team_ids.join(","))
  end
  attribute :user_ids, :rel => :users do |item|
    user_url(item.user_ids.join(","))
  end

  link :events do
    events_url
  end

  query :search, :data => :id do
    search_items_url
  end
end

class ConglomerateExtraTestSerializer
  include Conglomerate.serializer

  attribute :id
end

class ConglomerateNullSerializer
  include Conglomerate.serializer
end

describe Conglomerate do
  let(:object) do
    double(
      "Object",
      :id => 1,
      :description => "Tasty Burgers",
      :event_id => 2,
      :roster_id => nil,
      :team_ids => [1,2],
      :user_ids => []
    )
  end

  let(:context) do
    request = double("Request", :original_url => "https://example.com/items")
    double(
      "Context",
      :request => request,
      :search_items_url => "https://example.com/items/search",
    ).tap do |context|
      allow(context).to receive(:item_url).with(1) {
        "https://example.com/items/1"
      }
      allow(context).to receive(:event_url).with(2) {
        "https://example.com/events/2"
      }
      allow(context).to receive(:events_url) {
        "https://example.com/events"
      }
      allow(context).to receive(:team_url).with("1,2") {
        "https://example.com/teams/1,2"
      }
      allow(context).to receive(:test_url) { "abc" }
    end
  end

  let(:test_serializer) do
    ConglomerateTestSerializer.new(object, :context => context).serialize
  end

  let(:extra_test_serializer) do
    ConglomerateExtraTestSerializer.new(object, :context => context).serialize
  end

  let(:null_serializer) do
    ConglomerateNullSerializer.new(object, :context => context).serialize
  end

  let(:test_collection) { test_serializer["collection"] }

  let(:extra_test_collection) { extra_test_serializer["collection"] }

  let(:null_collection) { null_serializer["collection"] }

  describe "#version" do
    it "sets version to 1.0" do
      expect(null_collection["version"]).to eq("1.0")
      expect(test_collection["version"]).to eq("1.0")
    end
  end

  describe "#href" do
    it "in context, uses the block to set the collection href" do
      expect(test_collection["href"]).to eq("abc")
    end

    it "uses 'request.original_url' if preset 'rails_current_url' used" do
      expect(extra_test_collection["href"]).to eq("https://example.com/items")
    end
  end

  describe "#query" do
    it "doesn't include any query templates if none are provided" do
      expect(null_collection.keys).to_not include("queries")
    end

    it "adds a query template to the collection" do
      expect(test_collection["queries"]).to match_array(
        [
          {
            "href" => "https://example.com/items/search",
            "rel" => "search",
            "data" => [
              {"name" => "id", "value" => ""}
            ]
          }
        ]
      )
    end
  end

  describe "#attribute(s)" do
    context "items" do
      it "skips items if there are no attributes" do
        expect(null_collection.keys).to_not include("items")
      end

      it "doesn't have an items array if items is empty" do
        test_serializer = ConglomerateTestSerializer
        .new(nil, :context => context)
        .serialize
        test_collection = test_serializer["collection"]
        expect(test_collection.keys).to_not include("items")
      end

      it "includes an items array if attributes and objects present" do
        expect(test_collection["items"]).to eq(
          [
            {
              "href" => "https://example.com/items/1",
              "data" => [
                {"name" => "description", "value" => "Tasty Burgers"},
                {"name" => "id", "value" => 1},
                {"name" => "event_id", "value" => 2},
                {"name" => "roster_id", "value" => nil},
                {"name" => "team_ids", "value" => [1,2]},
                {"name" => "user_ids", "value" => []}
              ],
              "links" => [
                {"rel" => "event", "href" => "https://example.com/events/2"},
                {"rel" => "teams", "href" => "https://example.com/teams/1,2"}
              ]
            }
          ]
        )
      end

      it "doesn't include links if there are none" do
        expect(extra_test_collection["items"]).to eq(
          [
            {
              "data" => [
                {"name" => "id", "value" => 1}
              ]
            }
          ]
        )
      end
    end

    context "template" do
      it "skips template if there are no attributes for a template" do
        expect(null_collection.keys).to_not include("template")
      end

      it "includes a valid template if attributes have them" do
        expect(test_collection["template"]["data"]).to match_array(
          [
            {"name" => "description", "value" => ""}
          ]
        )
      end
    end
  end

  describe "#link" do
    it "skips links if there are none present" do
      expect(null_collection.keys).to_not include("links")
    end

    it "adds links if they are present" do
      expect(test_collection["links"]).to match_array(
        [
          {"rel" => "events", "href" => "https://example.com/events"}
        ]
      )
    end
  end

  describe "#item_link" do
    it "adds links if they are present" do
      expect(test_collection["items"][0]["links"]).to include(
        {"rel" => "teams", "href" => "https://example.com/teams/1,2"}
      )
    end
  end
end
