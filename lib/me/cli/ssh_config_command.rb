require "forwardable"
require "me/registry"
require "me/cli/ssh_config_view"

module Me
  module Cli
    class SshConfigCommand < Struct.new(:identity, :keys)
      extend Forwardable

      def call
        configure
        SshConfigView[ssh_keys]
      end

      private

      delegate [:configure_ssh, :ssh_keys] => :store

      def configure
        return if keys.empty?
        configure_ssh(keys)
      end

      def store
        Registry.store_factory.with_identity(identity)
      end
    end
  end
end
