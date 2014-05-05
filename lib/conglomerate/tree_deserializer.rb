module Conglomerate
  class TreeDeserializer
    PARTICLES = [Collection, Item, Error, Template, Datum, Query, Item]

    def initialize(object)
      self.object = object
    end

    def deserialize(item = object)
      raise "ObjectNotCollectionRoot" if !object["collection"]
      deserialize_particle(object["collection"], Collection)
    end

    private

    attr_accessor :object

    def deserialize_particle(object, klass)
      attributes = {}
      attribute_info = klass.attributes

      attribute_info.each do |attr, attr_metadata|
        attr = attr.to_s
        if object[attr]
          attributes[attr] = deserialize_attribute(object[attr], attr_metadata)
        end
      end

      particle = klass.new(attributes)
    end

    def deserialize_attribute(attribute, attr_metadata)
      if PARTICLES.include?(attr_metadata[:type])
        deserialize_particle(attribute, attr_metadata[:type])
      elsif attr_metadata[:type] == :array
        raise "ArrayExpected" unless attribute.is_a?(::Array)
        deserialize_array(attribute, attr_metadata[:contains])
      else
        attribute
      end
    end

    def deserialize_array(items, contains)
      array = Conglomerate::Array.new(contains)

      items.each do |item|
        array << deserialize_particle(item, contains)
      end

      array
    end
  end
end
