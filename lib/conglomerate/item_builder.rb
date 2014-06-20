module Conglomerate
  module ItemBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Item

    value :href
    builder :datum, Conglomerate::DatumBuilder, :name => :data, :array => true
    builder :link, Conglomerate::LinkBuilder, :name => :links, :array => true
  end
end
