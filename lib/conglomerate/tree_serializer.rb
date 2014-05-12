module Conglomerate
  class TreeSerializer
    def initialize(object)
      self.object = object
    end

    def serialize(item = object)
      if Conglomerate::Particle === item
        serialize_particle(item)
      elsif Conglomerate::Array === item
        serialize_array(item)
      elsif Array === item
        serialize_array(item)
      elsif item.is_a?(Numeric) || item.is_a?(String) || item.nil?
        item
      end
    end

    private

    attr_accessor :object

    def serialize_particle(particle)
      attributes = particle.class.attributes

      attributes.inject({}) do |hash, (attr, attr_metadata)|
        hash.tap do |h|
          attribute = particle.send(attr)
          attribute ||= attr_metadata[:default]

          unless attr_metadata[:cull] && cull_attribute(attribute)
            h[attr.to_s] = serialize(attribute)
          end
        end
      end
    end

    def serialize_array(array)
      array.map do |item|
        serialize(item)
      end
    end

    def cull_attribute(attribute)
      !attribute || (Conglomerate::Array === attribute && attribute.empty?)
    end
  end
end
