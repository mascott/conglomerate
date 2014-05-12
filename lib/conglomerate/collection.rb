module Conglomerate
  class Collection
    include Particle

    attribute :version, :default => "1.0"
    attribute :href

    attribute :template, :type => Template
    attribute :error, :type => Error

    array :items, :contains => Item
    array :links, :contains => Link
    array :queries, :contains => Query
  end
end
