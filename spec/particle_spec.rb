require_relative "spec_helper"
require_relative "../lib/conglomerate"

class ParticleTest
  include Conglomerate::Particle

  attribute :default, :default => "this is the default value"
  attribute :string, :type => String
end

describe Conglomerate::Particle do
  subject(:serialized_particle_test) { Conglomerate.serialize(ParticleTest.new) }
  subject(:mass_assigned) { ParticleTest.new(:string => "An string", :default => "Not an default") }

  it "default values are exposed when serialized" do
    expect(serialized_particle_test["default"]).to eq("this is the default value")
  end

  it "enforces type on attributes" do
    particle_test = ParticleTest.new
    expect {
      particle_test.string = 1
    }.to raise_error("TypeMismatch")
  end

  it "allows mass-assignment via constructor" do
    expect(mass_assigned.string).to eq("An string")
    expect(mass_assigned.default).to eq("Not an default")
  end
end
