require "forwardable"
require "me/thread_scope"

module Me
  module Registry
    extend self
    extend Forwardable

    delegate [
      :store_factory, :register_store_factory,
      :identity_mapper_factory, :register_identity_mapper_factory,
      :git_config_mapper_factory, :register_git_config_mapper_factory,
      :ssh_config_mapper_factory, :register_ssh_config_mapper_factory,
    ] => :thread_scoped

    delegate [:error_view_factories, :register_error_view_factories] => :process_scoped

    private

    def process_scoped
      @_process_scoped ||= ProcessScoped.new
    end

    def thread_scoped
      ThreadScope[:thread_scoped_registry] ||= ThreadScoped.new
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
      def_registry_readers :error_view_factories
    end

    class ThreadScoped < Base
      def_registry_readers :store_factory,
                           :identity_mapper_factory,
                           :git_config_mapper_factory,
                           :ssh_config_mapper_factory
    end
  end
end
