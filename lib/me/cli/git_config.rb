require "forwardable"
require "me/registry"

module Me
  module Cli
    class GitConfig < Struct.new(:identity, :name, :email)
      extend Forwardable

      def call
        configure
        "name:  #{git_name}\nemail: #{git_email}"
      end

      private

      delegate [:configure_git, :git_name, :git_email] => :store

      def configure
        return unless name && email
        configure_git(name, email)
      end

      def store
        Registry.store_factory.with_identity(identity)
      end
    end
  end
end
