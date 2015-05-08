require "me/git_config"
require "me/cli/git_config_view"

module Me
  module Cli
    class GitConfigCommand < Struct.new(:identity_name, :name, :email)
      def call
        git_config.configure
        current_git_config.build_view(GitConfigView)
      end

      private

      def git_config
        Registry.git_config_mapper_factory.new(name, email, identity_name).find
      end

      def current_git_config
        GitConfig.for_identity(identity_name)
      end
    end
  end
end
