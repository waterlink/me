module Me
  module Errors
    class Base < RuntimeError
      def name
        self.class.name
      end

      def build_view(view_factory)
        view_factory.new(self)
      end
    end

    class HasIdentity < Base
      def initialize(identity)
        @identity = identity
      end

      def build_view(view_factory)
        view_factory.new(self, identity)
      end

      protected

      attr_reader :identity
    end

    class GitNotConfigured < HasIdentity; end
    class SshNotConfigured < HasIdentity; end

    class NoActiveIdentity < Base; end
  end
end
