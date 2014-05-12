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
require_relative "conglomerate/collection"
require_relative "conglomerate/tree_deserializer"

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
