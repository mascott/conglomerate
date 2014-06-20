module Conglomerate
  module TemplateBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Template

    module BuildOverride
      def build(attrs = {})
        instance_variable_set("@objects", nil)
        super
      end
    end

    builder :datum, Conglomerate::DatumBuilder, :name => :data, :array => true
  end
end
