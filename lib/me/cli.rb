require "thor"

require "me/store"
require "me/registry"
require "me/errors"
require "me/error_presenter"

require "me/mappers/identity_store2"

require "me/cli/whoami_command"
require "me/cli/switch_command"
require "me/cli/git_config_command"
require "me/cli/ssh_config_command"
require "me/cli/git_not_configured_view"
require "me/cli/ssh_not_configured_view"

module Me
  module Cli
    ERROR_VIEW_FACTORIES = {
      "Me::Errors::GitNotConfigured" => GitNotConfiguredView,
      "Me::Errors::SshNotConfigured" => SshNotConfiguredView,
    }

    Registry.register_store_factory(Store)
    Registry.register_error_view_factories(ERROR_VIEW_FACTORIES)
    Registry.register_identity_mapper_factory(Me::Mappers::IdentityStore2)

    class BaseApp < Thor
      private

      def render(&blk)
        puts ErrorPresenter.new.call(&blk).to_s
      end
    end

    class Config < BaseApp
      desc "git NAME [GIT_NAME GIT_EMAIL]", "Configure corresponding git config options. Omit optional params to show current configuration"
      def git(identity, name=nil, email=nil)
        render { GitConfigCommand.new(identity, name, email).call }
      end

      desc "ssh NAME [SSH_KEYS]", "Configure ssh-agent to use provided ssh keys. Omit optional params to show current configuration"
      def ssh(identity, *keys)
        render { SshConfigCommand.new(identity, keys).call }
      end
    end

    class App < BaseApp
      desc "whoami", "Show current identity"
      def whoami
        render { WhoamiCommand.new.call }
      end

      desc "switch NAME", "Switch to specified identity"
      def switch(identity)
        render { SwitchCommand.new(identity).call }
      end

      default_task :whoami

      desc "config CONFIG_NAME", "Configure identities"
      subcommand "config", Config
    end
  end
end
