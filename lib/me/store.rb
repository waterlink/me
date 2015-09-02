require "store2"

module Me
  module Store
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

  class << Store
    def build
      store2.build
    end

    private

    def store2
      @_store2 ||= Store2.open(filename)
    end

    def filename
      File.join(user_home, ".me#{filename_suffix}.yml")
    end

    def user_home
      ENV.fetch("HOME")
    end

    def filename_suffix
      Store::Environment.wrap(
        ENV.fetch("ME_ENV", Store::NullEnvironment.new)
      )
    end
  end
end
