module Conglomerate
  module MixinIvarHelper
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    private

    module ClassMethods
      def mc_ivar_writer(*names)
        names.each do |name|
          self.send(:define_singleton_method, "#{name}=") do |val|
            instance_variable_set("@#{name}", val)
          end
        end
      end

      def mc_ivar_reader(*names)
        names.each do |name|
          self.send(:define_singleton_method,name) do
            instance_variable_get("@#{name}")
          end
        end
      end

      def mi_ivar_writer(*names)
        names.each do |name|
          self.send(:define_method, "#{name}=") do |val|
            instance_variable_set("@#{name}", val)
          end
        end
      end

      def mi_ivar_reader(*names)
        names.each do |name|
          self.send(:define_method,name) do
            instance_variable_get("@#{name}")
          end
        end
      end

      def mc_ivar_accessor(*names)
        mc_ivar_writer(*names)
        mc_ivar_reader(*names)
      end

      def mi_ivar_accessor(*names)
        mi_ivar_writer(*names)
        mi_ivar_reader(*names)
      end
    end
  end
end
