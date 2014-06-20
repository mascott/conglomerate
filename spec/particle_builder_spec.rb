require_relative "spec_helper"
require_relative "../lib/conglomerate"

class ConglomerateTestParticleSerializer
  include Conglomerate::RootBuilder.serializer

  collection do
    href { test_url }

    item "RSpec::Mocks::Double" do |item|
      href { item_url(item.id) }

      datum :description, :prompt => "awesome"
      datum :id
      datum :event_id
      datum :roster_id
      datum :team_ids

      datum :event_date_time
      datum :event_date
      datum :event_time

      datum :is_available

      link :event, :href => Proc.new{ event_url(item.event_id) }
      link :roster, :href => Proc.new{ roster_url(item.roster_id) }, :if => Proc.new{ item.roster_id }
      link :teams, :href => Proc.new{ team_url(item.team_ids.join(",")) }
      link :users, :href => Proc.new{ users_search_url(:object_id => item.id) }
    end

    link :events, :href => Proc.new { events_url }
    query :search, :href => Proc.new { search_items_url } do
      datum :id
    end

    template do
      datum :repeats, :prompt => "true|false"
      datum :description, :prompt => "awesome"
    end
  end
end

class ConglomerateExtraTestParticleSerializer
  include Conglomerate::RootBuilder.serializer

  collection do
    item do
      datum :id
    end
  end
end

class ConglomerateNullParticleSerializer
  include Conglomerate::RootBuilder.serializer

  collection do
  end
end

describe Conglomerate do
  let(:object) do
    double(
      "Object",
      :id => 1,
      :description => "Tasty Burgers",
      :event_date_time => DateTime.parse("1981-11-28T10:00:00+00:00"),
      :event_date => Date.parse("1981-11-28"),
      :event_time => Time.parse("1981-11-28T10:00:00+00:00"),
      :event_id => 2,
      :roster_id => nil,
      :team_ids => [1,2],
      :user_ids => [],
      :is_available => false
    )
  end

  let(:context) do
    request = double("Request", :original_url => "https://example.com/items")
    double(
      "Context",
      :request => request,
      :search_items_url => "https://example.com/items/search",
      :populate_items_url => "https://example.com/items/populate",
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
      allow(context).to receive(:users_search_url).with(:object_id => 1) {
        "def"
      }
    end
  end

  let(:test_serializer) do
    ConglomerateTestParticleSerializer.new(object, :context => context).serialize
  end

  let(:extra_test_serializer) do
    ConglomerateExtraTestParticleSerializer.new(object, :context => context).serialize
  end

  let(:null_serializer) do
    ConglomerateNullParticleSerializer.new(object, :context => context).serialize
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

    it "isn't included if the href is nil" do
      expect(null_collection["href"]).to be_nil
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
              {"name" => "id", "value" => nil}
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
        test_serializer = ConglomerateTestParticleSerializer
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
                {"name" => "description", "value" => "Tasty Burgers", "prompt" => "awesome"},
                {"name" => "id", "value" => 1},
                {"name" => "event_id", "value" => 2},
                {"name" => "roster_id", "value" => nil},
                {"name" => "team_ids", "value" => [1,2]},
                {"name" => "event_date_time", "value" => "1981-11-28T10:00:00Z"},
                {"name" => "event_date", "value" => "1981-11-28"},
                {"name" => "event_time", "value" => "1981-11-28T10:00:00Z"},
                {"name" => "is_available", "value" => false}
              ],
              "links" => [
                {"rel" => "event", "href" => "https://example.com/events/2"},
                {"rel" => "teams", "href" => "https://example.com/teams/1,2"},
                {"rel" => "users", "href" => "def"}
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
            {"name" => "description", "value" => nil, "prompt" => "awesome"},
            {"name" => "repeats", "value" => nil, "prompt" => "true|false"}
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
