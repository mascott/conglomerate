module Conglomerate
  module QueryBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Query

    module BuildOverride
      def build(attrs = {})
        instance_variable_set("@objects", nil)
        super(attrs.merge({
          :rel => _builder_name
        }))
      end
    end

    value :href
    value :rel
    value :name
    value :prompt

    builder :datum, Conglomerate::DatumBuilder, :name => :data, :array => true
  end
end
