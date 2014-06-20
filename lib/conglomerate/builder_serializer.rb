module Conglomerate
  module BuilderSerializer
    include Conglomerate::MixinIvarHelper

    mi_ivar_accessor :objects, :context, :_builder_name

    def initialize(objects, name: nil, context: nil)
      self.objects = [*objects].compact
      self.context = context
      self._builder_name = name.to_s
    end

    def build(attrs = {})
      internal_build(attrs)
    end

    def serialize
      Conglomerate.serialize(build)
    end

    private

    attr_accessor :object

    def internal_build(attrs = {})
      builder_values.each do |name|
        value = get_class_value(name)
        value = value_from_proc(value)
        attrs[name.to_sym] = value if attrs[name.to_sym] == nil
      end

      builder_builders.each do |b|
        run_builder_calls(b, attrs)
      end

      self.object = builder_type.new(attrs)

      object
    end

    def run_builder_calls(b, attrs)
      calls = builder_calls[b[:command]] || []

      calls.each do |call|
        call.run(context, objects, attrs, b[:name])
      end
    end

    def builder_type
      self.class.instance_variable_get("@_builder_type")
    end

    def builder_values
      self.class.instance_variable_get("@_builder_values")
    end

    def builder_calls
      self.class.instance_variable_get("@_builder_calls")
    end

    def builder_builders
      self.class.instance_variable_get("@_builder_builders")
    end

    def get_class_value(name)
      self.class.instance_variable_get("@#{name}")
    end

    def value_from_proc(value)
      value = context.instance_eval(&value) if value.respond_to?(:call)
      value
    end

    def context
      instance_variable_get("@context")
    end
  end
end
