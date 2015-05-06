require "forwardable"
require "me/registry"

module Me
  module Cli
    class SshConfig < Struct.new(:identity, :keys)
      extend Forwardable

      def call
        configure
        "keys:\n#{key_list}"
      end

      private

      delegate [:configure_ssh, :ssh_keys] => :store

      def configure
        return if keys.empty?
        configure_ssh(keys)
      end

      def key_list
        ssh_keys.map { |x| "- #{x}" }.join("\n")
      end

      def store
        Registry.store_factory.with_identity(identity)
      end
    end
  end
end
