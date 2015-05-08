require "me/errors"
require "me/store2"

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
      persistence.set("active_identity", identity)
      save
    end

    def active_identity
      persistence.get_or_set("active_identity", "<none>")
    end

    def git_config(identity)
      identity_for(identity)
        .fetch("git") { fail Errors::GitNotConfigured, active_identity }
    end

    def save_git_config(identity, git_config)
      identity_for(identity).set("git", git_config)
      save
    end

    def ssh_config(identity)
      identity_for(identity)
        .fetch("ssh") { fail Errors::SshNotConfigured, active_identity }
    end

    def save_ssh_config(identity, ssh_config)
      identity_for(identity).set("ssh", ssh_config)
      save
    end

    def _reset
      persistence._reset
    end

    protected

    attr_reader :persistence, :specific_identity

    private

    def load
      Store2.build
    end

    def save
      persistence.save
    end

    def identities
      persistence.get_or_set("identities", {})
      persistence.scoped("identities")
    end

    def identity_for(identity)
      fail Errors::NoActiveIdentity if identity == "<none>"
      identities.get_or_set(identity, {})
      identities.scoped(identity)
    end
  end
end
