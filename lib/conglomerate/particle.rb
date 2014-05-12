module Conglomerate
  module Particle
    def self.included(object)
      object.send(:extend, ClassMethods)
    end

    def initialize(attributes = {})
      self.class.attributes.each do |attr, attr_metadata|
        if attr_metadata[:required]
          raise "MissingAttribute" unless attributes[attr] || attributes[attr.to_s]
        end

        if attr_metadata[:type] == :array
          self.instance_variable_set("@#{attr}", Conglomerate::Array.new(attr_metadata[:contains]))
        end
      end

      attributes.each do |key, value|
        attrs = self.class.attributes
        if attrs[key.to_sym] && attrs[key.to_sym][:type] == :array
          array = value
          value = Conglomerate::Array.new(attrs[key.to_sym][:contains])
          array.each { |item| value << item }
          self.instance_variable_set("@#{key}", value)
        end

        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end
    end

    private

    module ClassMethods
      def self.extended(klass)
        klass.instance_variable_set("@attributes", {})
      end

      def attributes
        instance_variable_get("@attributes").dup
      end

      private

      def array(attr, contains: nil, cull: true)
        attribute(attr, :type => :array, :contains => contains, :cull => cull)
      end

      def attribute(attr, default: nil, type: nil, contains: nil, cull: true, required: nil)
        instance_variable_get("@attributes")[attr] = {
          :default => default,
          :type => type,
          :contains => contains,
          :cull => cull,
          :required => required
        }

        self.send(:attr_reader, attr)

        if type != :array
          self.send(:define_method, :"#{attr}=") do |val|
            attr_metadata = self.class.attributes[attr]

            if type = attr_metadata[:type]
              raise "TypeMismatch" if !val.is_a?(type)
            end

            self.instance_variable_set("@#{attr}", val)
          end
        end
      end
    end
  end
end
