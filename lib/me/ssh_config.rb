require "me/registry"

module Me
  class SshConfig
    def initialize(keys, identity_name)
      @keys = keys
      @identity_name = identity_name
    end

    def ==(other)
      return false unless other.is_a?(SshConfig)
      self.keys == other.keys
    end

    def with_mapper(mapper)
      @mapper = mapper
      self
    end

    def configure
      return if keys.empty?
      mapper.update(keys: keys)
    end

    def activate
      fail
    end

    def build_view(view_factory)
      view_factory.new(keys: keys)
    end

    protected

    attr_reader :keys, :identity_name, :mapper
  end

  class << SshConfig
    def for_identity(identity_name)
      Registry.ssh_config_mapper_factory.find_by_identity(identity_name)
    end
  end

  class SshConfig::Mapper
    def self.find_by_identity(identity_name)
    end

    def initialize(keys, identity_name)
    end

    def find
    end

    def update(keys: nil, identity_name: nil)
    end
  end
end
