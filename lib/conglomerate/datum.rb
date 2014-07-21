module Conglomerate
  class Datum
    include Conglomerate::Particle

    attribute :name, :type => String, :required => true
    attribute :value, :cull => false
    attribute :prompt, :type => String
    attribute :type, :type => String
  end
end
