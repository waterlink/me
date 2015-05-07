require "forwardable"
require "me/git_config"
require "me/cli/git_config_view"

module Me
  module Cli
    class GitConfigCommand < Struct.new(:identity_name, :name, :email)
      extend Forwardable

      def call
        configure
        current_git_config.build_view(GitConfigView)
      end

      private

      delegate [:configure] => :git_config

      def git_config
        GitConfig.new(name, email, identity_name)
      end

      def current_git_config
        GitConfig.for_identity(identity_name)
      end
    end
  end
end
