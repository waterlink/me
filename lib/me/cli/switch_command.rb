require "me/identity"
require "me/cli/new_active_identity_view"

module Me
  module Cli
    class SwitchCommand < Struct.new(:name)
      def call
        identity.activate
        active_identity.build_view(NewActiveIdentityView)
      end

      private

      def active_identity
        Identity.active
      end

      def identity
        Registry.identity_mapper_factory.new(name).find
      end
    end
  end
end
