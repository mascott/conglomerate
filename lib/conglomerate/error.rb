module Conglomerate
  class Error
    include Conglomerate::Particle

    attribute :title, :type => String
    attribute :code, :type => String
    attribute :message, :type => String
  end
end
