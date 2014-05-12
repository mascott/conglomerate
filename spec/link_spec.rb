require_relative "spec_helper"
require_relative "../lib/conglomerate"

describe Conglomerate::Link do
  context "required attributes" do
    specify "href" do
      expect { Conglomerate::Link.new(:rel => "") }.to raise_error("MissingAttribute")
    end

    specify "rel" do
      expect { Conglomerate::Link.new(:href => "") }.to raise_error("MissingAttribute")
    end
  end
end
