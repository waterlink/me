require "me"

require "thor"

module Me
  module Cli
    class Config < Thor
      desc "git NAME GIT_FULL_NAME GIT_EMAIL", "Configure corresponding git config options"
      def git(name, full_name, email)
        puts "git config --global user.name '#{full_name}'"
        puts "git config --global user.email '#{email}'"
      end

      desc "ssh NAME SSH_KEYS", "Configure ssh-agent to use provided ssh keys"
      def ssh(name, *keys)
        puts "ssh-add -D"
        keys.each do |key|
          puts "ssh-add '#{key}'"
        end
      end
    end

    class App < Thor
      desc "whoami", "Show current identity"
      def whoami
        puts "Active identity: #{active_identity}"
      end

      desc "switch NAME", "Switch to specified identity"
      def switch(name)
        self._active_identity = name
        whoami
      end

      default_task :whoami

      desc "config CONFIG_NAME", "Configure identities"
      subcommand "config", Config

      attr_accessor :_active_identity

      private

      def active_identity
        _active_identity || "<none>"
      end
    end
  end
end
