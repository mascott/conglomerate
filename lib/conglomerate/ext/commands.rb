module Conglomerate
  class Command
    include Conglomerate::Particle

    attribute :href, :type => String, :required => true
    attribute :rel, :type => String, :required => true
    attribute :name, :type => String
    attribute :prompt, :type => String

    array :data, :contains => Datum
  end

  class CommandBuilder
    include Conglomerate::ParticleBuilder

    builds Conglomerate::Command

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

Conglomerate::CollectionBuilder.send(:builder, :command, Conglomerate::CommandBuilder, :name => :commands, :array => true)
