module Me
  module ThreadScope
    extend self

    NAMESPACE = :__me

    def [](name)
      scope[name]
    end

    def []=(name, value)
      scope[name] = value
    end

    def _reset
      current[NAMESPACE] = {}
    end

    private

    def scope
      current[NAMESPACE] ||= {}
    end

    def current
      Thread.current
    end
  end
end
