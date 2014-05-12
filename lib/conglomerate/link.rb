module Conglomerate
  class Link
    include Conglomerate::Particle

    attribute :href, :type => String, :required => true
    attribute :rel, :type => String, :required => true
    attribute :name, :type => String
    attribute :render, :type => String
    attribute :prompt, :type => String
  end
end
