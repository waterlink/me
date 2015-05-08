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

  class Identity::Store2Mapper
    def initialize(name = nil)
      @name = name || active_identity
    end

    def find
      Identity.build(
        mapper: self,
        name: name,
        active_identity: active_identity,
      )
    end

    def update(name: nil, active_identity:)
      store.set("active_identity", active_identity)
    end

    protected

    attr_reader :name

    private

    def active_identity
      store.get_or_set("active_identity", "<none>")
    end

    def store
      @_store ||= Store2.build
    end

    def scoped
      @_scoped ||= store.scoped("identities", name)
    end
  end
end
