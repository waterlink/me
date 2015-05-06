require "thor"

require "me/store"

module Me
  module Cli
    class Config < Thor
      desc "git NAME GIT_FULL_NAME GIT_EMAIL", "Configure corresponding git config options"
      def git(name, full_name, email)
        store.with_identity(name) do
          store.configure_git(full_name, email)
        end
      end

      desc "ssh NAME SSH_KEYS", "Configure ssh-agent to use provided ssh keys"
      def ssh(name, *keys)
        puts "ssh-add -D"
        keys.each do |key|
          puts "ssh-add '#{key}'"
        end
      end

      private

      def store
        @_store ||= Store.new
      end
    end

    class App < Thor
      desc "whoami", "Show current identity"
      def whoami
        puts "Active identity: #{active_identity}"
      end

      desc "switch NAME", "Switch to specified identity"
      def switch(name)
        store.activate(name)
        whoami
      end

      default_task :whoami

      desc "config CONFIG_NAME", "Configure identities"
      subcommand "config", Config

      private

      def active_identity
        store.active_identity
      end

      def store
        @_store ||= Store.new
      end
    end
  end
end
