require "me/thread_scope"
require "me/store2"

module Me
  # Represents certain person, or person in certain role or situation
  class Identity
    def initialize(name)
      @name = name
    end

    def ==(other)
      return false unless other.is_a?(Identity)
      self.name == other.name
    end

    def build_view(view_factory)
      view_factory.new(name: name)
    end

    def activate
      mapper.update(active_identity: name)
    end

    def git_config
      fail
    end

    def ssh_config
      fail
    end

    def with_mapper(mapper)
      @mapper = mapper
      self
    end

    protected

    attr_reader :name, :mapper
  end

  class << Identity
    def active
      Registry.identity_mapper_factory.new.find
    end

    def build(mapper:, name:, active_identity:)
      Identity.new(name).with_mapper(mapper)
    end
  end

  # @abstract
  class Identity::Mapper
    def initialize(name = nil)
    end

    def find
    end

    def update(name: nil, active_identity: nil)
    end
  end
end
