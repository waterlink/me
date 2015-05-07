require "yaml"
require "me/errors"

module Me
  class Store
    def initialize(identity = nil)
      @persistence = load
      @specific_identity = identity
    end

    def activate(identity)
      persistence["active_identity"] = identity
      save
    end

    def activate!
      activate(active_identity)
    end

    def active_identity
      specific_identity || persistence.fetch("active_identity", "<none>")
    end

    def git_name
      git_config["name"]
    end

    def git_email
      git_config["email"]
    end

    def configure_git(name, email)
      git_config!["name"] = name
      git_config!["email"] = email
      save
    end

    def ssh_keys
      ssh_config["keys"]
    end

    def configure_ssh(keys)
      ssh_config!["keys"] = keys
      save
    end

    def self.with_identity(identity)
      new(identity)
    end

    def with_identity(identity)
      active_identity.tap do |old_identity|
        activate(identity)
        yield
        activate(old_identity)
      end
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

    def git_config
      identity.fetch("git") { fail Errors::GitNotConfigured, active_identity }
    end

    def git_config!
      identity["git"] ||= {}
    end

    def ssh_config
      identity.fetch("ssh") { fail Errors::SshNotConfigured, active_identity }
    end

    def ssh_config!
      identity["ssh"] ||= {}
    end

    def identity
      fail Errors::NoActiveIdentity if active_identity == "<none>"
      persistence[active_identity] ||= {}
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
