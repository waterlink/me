require "me/ssh_config"
require "me/cli/ssh_config_view"

module Me
  module Cli
    class SshConfigCommand < Struct.new(:identity_name, :keys)
      def call
        ssh_config.configure
        current_ssh_config.build_view(SshConfigView)
      end

      private

      def ssh_config
        Registry.ssh_config_mapper_factory.new(keys, identity_name).find
      end

      def current_ssh_config
        SshConfig.for_identity(identity_name)
      end
    end
  end
end
