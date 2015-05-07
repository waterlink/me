require "yaml"
require "me/errors"

module Me
  class IdentityStore < Struct.new(:store, :identity)
    def activate
      store.activate(identity)
    end

    def active_identity
      store.active_identity
    end

    def git_config
      store.git_config(identity)
    end

    def save_git_config(hash)
      store.save_git_config(identity, hash)
    end

    def ssh_config
      store.ssh_config(identity)
    end

    def save_ssh_config(hash)
      store.save_ssh_config(identity, hash)
    end
  end

  class Store
    def initialize
      @persistence = load
    end

    def self.with_identity(identity)
      IdentityStore.new(new, identity)
    end

    def ==(other)
      other.is_a?(Store)
    end

    def activate(identity)
      persistence["active_identity"] = identity
      save
    end

    def active_identity
      persistence.fetch("active_identity", "<none>")
    end

    def git_config(identity)
      identity_for(identity)
        .fetch("git") { fail Errors::GitNotConfigured, active_identity }
    end

    def save_git_config(identity, git_config)
      identity_for(identity)["git"] = git_config
      save
    end

    def ssh_config(identity)
      identity_for(identity)
        .fetch("ssh") { fail Errors::SshNotConfigured, active_identity }
    end

    def save_ssh_config(identity, ssh_config)
      identity_for(identity)["ssh"] = ssh_config
      save
    end

    def _reset
      create
    end

    protected

    attr_reader :persistence, :specific_identity

    private

    def load
      return create unless File.exist?(filename)
      YAML.load_file(filename)
    end

    def create
      (@persistence = {}).tap { save }
    end

    def save
      File.write(filename, persistence.to_yaml)
    end

    def filename
      "#{user_home}/.me#{filename_suffix}.yml"
    end

    def user_home
      ENV.fetch("HOME")
    end

    def filename_suffix
      Environment.wrap(ENV.fetch("ME_ENV", NullEnvironment.new))
    end

    def identities
      persistence["identities"] ||= {}
    end

    def identity_for(identity)
      fail Errors::NoActiveIdentity if identity == "<none>"
      identities[identity] ||= {}
    end

    class Environment < Struct.new(:value)
      def self.wrap(env)
        return env if env.is_a?(self)
        new(env)
      end

      def to_s
        "_#{value}"
      end
    end

    class NullEnvironment < Environment
      def to_s
        ""
      end
    end
  end
end
