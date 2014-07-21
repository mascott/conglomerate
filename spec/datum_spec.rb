require_relative "spec_helper"
require_relative "../lib/conglomerate"

describe Conglomerate::Datum do
  context "required attributes" do
    specify "name" do
      expect { Conglomerate::Datum.new }.to raise_error("MissingAttribute")
    end
  end

  context "optional attributes" do
    specify "value" do
      datum = Conglomerate::Datum.new(:name => "name")
      expect(datum).to respond_to(:"value=")
    end

    specify "prompt" do
      datum = Conglomerate::Datum.new(:name => "name")
      expect(datum).to respond_to(:"prompt=")
      expect { datum.prompt = 3 }.to raise_error
    end

    specify "type" do
      datum = Conglomerate::Datum.new(:name => "name")
      expect(datum).to respond_to(:"type=")
      expect { datum.type = 3 }.to raise_error
    end
  end
end
