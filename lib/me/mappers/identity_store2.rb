require "me/identity"

module Me
  module Mappers
    class IdentityStore2 < Identity::Mapper
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

      def update(name: nil, active_identity: nil)
        return unless active_identity
        store.set("active_identity", active_identity)
        store.save
      end

      protected

      attr_reader :name

      private

      def active_identity
        store.get_or_set("active_identity", "<none>")
      end

      def store
        @_store ||= Store.build
      end
    end
  end
end
