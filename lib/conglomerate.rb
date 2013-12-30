require_relative "conglomerate/serializer"

module Conglomerate
  def self.serializer
    Module.new do
      def self.included(descendant)
        descendant.send(:include, ::Conglomerate::Serializer)
      end
    end
  end
end
