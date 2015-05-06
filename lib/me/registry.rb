require "forwardable"

module Me
  module Registry
    extend self
    extend Forwardable

    delegate [:store_factory, :register_store_factory] => :thread_scoped
    delegate [] => :process_scoped

    private

    def process_scoped
      @_process_scoped ||= ProcessScoped.new
    end

    def thread_scoped
      Thread.current[:__me_thread_scoped_registry] ||= ThreadScoped.new
    end

    class Base
      def self.def_registry_readers(*names)
        names.each do |name|
          attr_reader(name)
          define_method(:"register_#{name}") do |value|
            instance_variable_set(:"@#{name}", value)
          end
        end
      end
    end

    class ProcessScoped < Base
      def_registry_readers
    end

    class ThreadScoped < Base
      def_registry_readers :store_factory
    end
  end
end
