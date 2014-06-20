module Conglomerate
  module LinkBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Link

    module BuildOverride
      def build(attrs = {})
        super(attrs.merge({
          :rel => _builder_name
        }))
      end
    end

    value :href
    value :rel
    value :name
    value :render
    value :prompt
  end
end
