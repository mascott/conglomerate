require_relative "conglomerate/tree_serializer"
require_relative "conglomerate/array"
require_relative "conglomerate/particle"
require_relative "conglomerate/serializer"
require_relative "conglomerate/link"
require_relative "conglomerate/error"
require_relative "conglomerate/datum"
require_relative "conglomerate/template"
require_relative "conglomerate/item"
require_relative "conglomerate/query"
require_relative "conglomerate/command"
require_relative "conglomerate/collection"
require_relative "conglomerate/tree_deserializer"
require_relative "conglomerate/root"

require_relative "conglomerate/mixin_ivar_helper"
require_relative "conglomerate/builder_call"

require_relative "conglomerate/builder_serializer"
require_relative "conglomerate/particle_builder"
require_relative "conglomerate/link_builder"
require_relative "conglomerate/datum_builder"
require_relative "conglomerate/query_builder"
require_relative "conglomerate/template_builder"
require_relative "conglomerate/item_builder"
require_relative "conglomerate/collection_builder"
require_relative "conglomerate/root_builder"

module Conglomerate
  def self.serialize(serializable)
    Conglomerate::TreeSerializer.new(serializable).serialize
  end

  def self.serializer
    Module.new do
      def self.included(descendant)
        descendant.send(:include, ::Conglomerate::Serializer)
      end
    end
  end
end
