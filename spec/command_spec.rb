require_relative "spec_helper"
require_relative "../lib/conglomerate"

describe Conglomerate::Command do
  let(:command) {
    Conglomerate::Command.new(
      :href => "http://this.is.a.command/",
      :rel => "some_command"
    )
  }

  context "required attributes" do
    specify "href" do
      expect { Conglomerate::Command.new(:rel => "") }.to raise_error("MissingAttribute")
    end

    specify "rel" do
      expect { Conglomerate::Command.new(:href => "") }.to raise_error("MissingAttribute")
    end
  end

  context "data" do
    it "serializes properly" do
      datum = Conglomerate::Datum.new(:name => "name")

      command.data << datum
      expect(Conglomerate.serialize(command)["data"]).to include(Conglomerate.serialize(datum))
    end
  end
end
