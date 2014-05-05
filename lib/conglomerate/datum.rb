module Conglomerate
  class Datum
    include Conglomerate::Particle

    attribute :name, :type => String, :required => true
    attribute :value
    attribute :prompt, :type => String
  end
end
