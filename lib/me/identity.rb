require "me/thread_scope"

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
      store.activate!
    end

    protected

    attr_reader :name

    def store
      @_store ||= Registry.store_factory.with_identity(name)
    end
  end

  class << Identity
    def active
      new(store.active_identity)
    end

    private

    def store
      ThreadScope[:identity_store] ||= Registry.store_factory.new
    end
  end
end
