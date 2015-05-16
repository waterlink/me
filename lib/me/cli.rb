require "thor"

# common
require "me/registry"
require "me/executor"
require "me/errors"
require "me/error_presenter"

# mappers
require "me/mappers/identity_store2"
require "me/mappers/git_config_store2"
require "me/mappers/ssh_config_store2"

# commands
require "me/cli/whoami_command"
require "me/cli/switch_command"
require "me/cli/activate_command"
require "me/cli/git_config_command"
require "me/cli/ssh_config_command"

# views
require "me/cli/git_not_configured_view"
require "me/cli/ssh_not_configured_view"

module Me
  module Cli
    ERROR_VIEW_FACTORIES = {
      "Me::Errors::GitNotConfigured" => GitNotConfiguredView,
      "Me::Errors::SshNotConfigured" => SshNotConfiguredView,
    }

    Registry.register_kernel(Kernel)
    Registry.register_executor_factory(Executor)
    Registry.register_error_view_factories(ERROR_VIEW_FACTORIES)
    Registry.register_identity_mapper_factory(Me::Mappers::IdentityStore2)
    Registry.register_git_config_mapper_factory(Me::Mappers::GitConfigStore2)
    Registry.register_ssh_config_mapper_factory(Me::Mappers::SshConfigStore2)

    class BaseApp < Thor
      private

      def render(&blk)
        _render(ErrorPresenter.new.call(&blk))
      end

      def _render(views)
        return _render([views]) unless views.is_a?(Array)
        views.map { |v| puts v.to_s }
      end
    end

    class Config < BaseApp
      desc "git NAME [GIT_NAME GIT_EMAIL]", "Configure corresponding git config options. Omit optional params to show current configuration"
      def git(identity, name=nil, email=nil)
        render { GitConfigCommand[identity, name, email].call }
      end

      desc "ssh NAME [SSH_KEYS]", "Configure ssh-agent to use provided ssh keys. Omit optional params to show current configuration"
      def ssh(identity, *keys)
        render { SshConfigCommand[identity, keys].call }
      end
    end

    class App < BaseApp
      desc "whoami", "Show current identity"
      def whoami
        render { WhoamiCommand.new.call }
      end

      desc "switch NAME", "Switch to specified identity"
      def switch(identity)
        render { SwitchCommand[identity].call }
      end

      desc "activate", "Activates configuration for current identity"
      def activate
        render { ActivateCommand.new.call }
      end

      default_task :activate

      desc "config CONFIG_NAME", "Configure identities"
      subcommand "config", Config
    end
  end
end
