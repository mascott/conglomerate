module Conglomerate
  class Query
    include Conglomerate::Particle

    attribute :href, :type => String, :required => true
    attribute :rel, :type => String, :required => true
    attribute :name, :type => String
    attribute :prompt, :type => String

    array :data, :contains => Datum
  end
end
