module Conglomerate
  class BuilderCall
    attr_accessor :name, :opts, :block, :builder, :array, :iterates

    def initialize(name: nil, opts: {}, block:, builder:, array:, iterates:)
      self.name = name
      self.opts = opts
      self.block = block
      self.builder = builder
      self.array = array
      self.iterates = iterates
    end

    def run(context, objects, attrs, attr_name)
      BuilderCallInstance.new(self, context, objects, attrs, attr_name).run
    end

    private

    class BuilderCallInstance
      extend Forwardable

      attr_accessor :bc, :context, :objects, :attrs, :attr_name

      delegate [:name, :opts, :block, :builder, :array, :iterates] => :bc

      def initialize(bc, context, objects, attrs, attr_name)
        self.bc = bc
        self.context = context
        self.objects = objects
        self.attrs = attrs
        self.attr_name = attr_name
      end

      def run
        return unless should_run?

        if iterates
          attrs[attr_name] ||= []

          objects.each do |item|
            attrs[attr_name] << invoke(item)
          end
        elsif array
          attrs[attr_name] ||= []
          attrs[attr_name] << invoke
        else
          attrs[attr_name] = invoke
        end
      end

      def invoke(item = nil)
        serializer = builder.serializer
        builder_klass = Class.new do
          include serializer
        end

        if item
          builder_klass.class_exec(item, &block) if block
        else
          builder_klass.class_eval(&block) if block
        end

        builder = builder_klass.new(objects, :name => name, :context => context)

        attrs = {}

        opts.each do |key, value|
          attrs[key] = value_from_proc(value)
        end

        builder.build(attrs)
      end

      def value_from_proc(value)
        value = context.instance_eval(&value) if value.respond_to?(:call)
        value
      end

      private

      def should_run?
        !opts[:if] || (opts[:if] && opts[:if].call)
      end
    end
  end
end
