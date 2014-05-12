module Conglomerate
  class Array
    include Enumerable

    def initialize(type)
      self.type = type
      self.storage = []
    end

    def <<(val)
      if type
        raise "TypeMismatch" unless val.is_a?(type)
      end

      storage << val
    end

    def empty?
      storage.empty?
    end

    def each(&block)
      storage.each(&block)
    end

    private

    attr_accessor :storage, :type
  end
end
