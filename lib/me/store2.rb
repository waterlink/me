require "yaml"

module Me
  class Store2
    class Scoped
      def initialize(store, scope)
        @store, @scope = store, scope
      end

      def ==(other)
        return false unless other.is_a?(Scoped)
        [self.store, self.scope] ==
          [other.store, other.scope]
      end

      def scoped(*add_scope)
        Scoped.new(store, scope + add_scope)
      end

      def get(*keys)
        store.get(scope + keys)
      end

      def set(*keys, value)
        store.set(scope + keys, value)
      end

      def has?(*keys)
        store.has?(scope + keys)
      end

      def get_or_set(*keys, value)
        store.get_or_set(scope + keys, value)
      end

      def fetch(*keys, &block)
        store.fetch(scope + keys, &block)
      end

      def save
        store.save
      end

      def _reset
        store._reset
      end

      protected

      attr_reader :store, :scope
    end

    def initialize
      @data = load
    end

    def self.build
      Store2.new.scoped
    end

    def ==(other)
      other.is_a?(Store2)
    end

    def scoped(*scope)
      Scoped.new(self, scope)
    end

    def get(keys)
      keys.inject(data) { |data, key| data[key] }
    end

    def set(keys, value)
      get(keys[0...-1])[keys[-1]] = value
    end

    def has?(keys)
      get(keys[0...-1]).has_key?(keys[-1])
    end

    def get_or_set(keys, value)
      set(keys, value) unless has?(keys)
      get(keys)
    end

    def fetch(keys, &block)
      return block.call unless has?(keys)
      get(keys)
    end

    def save
      File.write(filename, to_yaml)
    end

    def to_yaml
      data.to_yaml
    end

    def _reset
      create
    end

    protected

    attr_reader :data

    private

    def load
      return create unless File.exist?(filename)
      YAML.load_file(filename)
    end

    def create
      (@data = {}).tap { save }
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
