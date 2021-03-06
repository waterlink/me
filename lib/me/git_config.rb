require "me/registry"
require "me/git_activation"

module Me
  # Represents piece of personalised git configuration
  class GitConfig
    def initialize(name, email, identity_name)
      @name = name
      @email = email
      @identity_name = identity_name
    end

    def with_mapper(mapper)
      @mapper = mapper
      self
    end

    def ==(other)
      return false unless other.is_a?(GitConfig)
      self.equality_fields == other.equality_fields
    end

    def configure
      return unless name && email
      mapper.update(name: name, email: email)
    end

    def activate
      activation.call
      activation
    end

    def build_view(view_factory)
      view_factory.new(name: name, email: email)
    end

    protected

    attr_reader :name, :email, :identity_name, :mapper

    def equality_fields
      [name, email]
    end

    private

    def activation
      @_activation ||= GitActivation.new(name, email)
    end
  end

  class << GitConfig
    def for_identity(identity_name)
      Registry.git_config_mapper_factory.find_by_identity(identity_name)
    end
  end

  class GitConfig::Mapper
    def self.find_by_identity(identity_name)
    end

    def initialize(name, email, identity_name)
    end

    def find
    end

    def update(name: nil, email: nil)
    end
  end
end
