module Conglomerate
  module ParticleBuilder
    def self.included(object)
      object.send(:extend, ClassMethods)
    end

    private

    def objects
      instance_variable_get("@objects")
    end

    def name
      instance_variable_get("@_builder_name").to_s
    end

    module ClassMethods
      def self.extended(klass)
        klass.instance_variable_set("@class_methods", Module.new)
        klass.instance_variable_set("@values", [])
        klass.instance_variable_set("@builders", [])
      end

      def serializer
        mod = Module.new
        mod.send(:include, Conglomerate::MixinIvarHelper)
        mod.send(:mc_ivar_accessor, :class_methods, :values, :_builder_type, :_builder_calls, :_builder_builders, :build_override_mod)

        mod.class_methods = class_methods
        mod.values = values.dup
        mod._builder_type = instance_variable_get("@type")
        mod._builder_builders = builders.dup

        begin
          mod.build_override_mod = self::BuildOverride
        rescue NameError
        end

        mod.define_singleton_method(:included) do |klass|
          klass.send(:extend, class_methods)
          klass.send(:include, Conglomerate::BuilderSerializer)
          klass.send(:include, build_override_mod) if build_override_mod
          klass.instance_variable_set("@_builder_values", values)
          klass.instance_variable_set("@_builder_type", _builder_type)
          klass.instance_variable_set("@_builder_calls", {})
          klass.instance_variable_set("@_builder_builders", _builder_builders)
        end
        mod
      end

      private

      include Conglomerate::MixinIvarHelper
      mi_ivar_reader :values, :builders, :class_methods

      def builds(type)
        instance_variable_set("@type", type)
      end

      def value(name)
        class_methods.send(:define_method, name) do |&block|
          instance_variable_set("@#{name}", block)
        end

        values << name
      end

      def builder(command, builder, opts={})
        name = opts[:name] || command
        array = opts[:array] || false
        iterates = opts[:iterates] || false

        class_methods.send(:define_method, command) do |name=nil, opts={}, &block|
          instance_variable_get("@_builder_calls")[command] ||= []
          instance_variable_get("@_builder_calls")[command] << Conglomerate::BuilderCall.new({
            :name => name,
            :opts => opts,
            :block => block,
            :builder => builder,
            :array => array,
            :iterates => iterates
          })
        end

        builders << {
          :command => command,
          :builder => builder,
          :array => array,
          :name => name,
          :iterates => iterates
        }
      end
    end
  end
end
