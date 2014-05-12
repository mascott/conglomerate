module Conglomerate
  class Item
    include Conglomerate::Particle

    attribute :href, :type => String

    array :data, :contains => Datum
    array :links, :contains => Link
  end
end
