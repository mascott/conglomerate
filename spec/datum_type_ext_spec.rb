require_relative "spec_helper"
require_relative "../lib/conglomerate"
require_relative "../lib/conglomerate/ext/datum_type"

describe Conglomerate::Datum do
  context "optional attributes" do
    specify "type" do
      datum = Conglomerate::Datum.new(:name => "name")
      expect(datum).to respond_to(:"type=")
      expect { datum.type = 3 }.to raise_error
    end
  end
end
