module Conglomerate
  module DatumBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Datum

    module BuildOverride
      def build(attrs = {})
        item = objects.first
        val = item.send(_builder_name) if item && item.respond_to?(_builder_name)

        attrs = {
          :name => _builder_name,
          :value => val
        }.merge(attrs)

        super(attrs)
      end
    end

    value :name
    value :value
    value :prompt
  end
end
