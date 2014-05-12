module Conglomerate
  class Template
    include Conglomerate::Particle

    array :data, :contains => Datum
  end
end
