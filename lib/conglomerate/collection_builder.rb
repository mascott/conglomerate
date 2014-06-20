module Conglomerate
  module CollectionBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Collection

    value :href
    builder :item, Conglomerate::ItemBuilder, :name => :items, :array => true, :iterates => true
    builder :link, Conglomerate::LinkBuilder, :name => :links, :array => true
    builder :query, Conglomerate::QueryBuilder, :name => :queries, :array => true
    builder :template, Conglomerate::TemplateBuilder, :name => :template
  end
end
