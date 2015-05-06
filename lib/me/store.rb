require "yaml"

module Me
  class GitNotConfigured < RuntimeError; end
  class NoActiveIdentity < RuntimeError; end

  class Store
    def initialize
      @persistence = load
    end

    def activate(identity)
      persistence["active_identity"] = identity
      save
    end

    def active_identity
      persistence.fetch("active_identity", "<none>")
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

    private

    attr_reader :persistence

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
      identity.fetch("git") { raise GitNotConfigured }
    end

    def git_config!
      identity["git"] ||= {}
    end

    def identity
      raise NoActiveIdentity if active_identity == "<none>"
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
