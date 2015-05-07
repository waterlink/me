require "forwardable"
require "me/ssh_config"
require "me/cli/ssh_config_view"

module Me
  module Cli
    class SshConfigCommand < Struct.new(:identity_name, :keys)
      extend Forwardable

      def call
        configure
        current_ssh_config.build_view(SshConfigView)
      end

      private

      delegate [:configure] => :ssh_config

      def ssh_config
        SshConfig.new(keys, identity_name)
      end

      def current_ssh_config
        SshConfig.for_identity(identity_name)
      end
    end
  end
end
