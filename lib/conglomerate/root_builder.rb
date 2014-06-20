module Conglomerate
  module RootBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Root

    builder :collection, Conglomerate::CollectionBuilder
  end
end
