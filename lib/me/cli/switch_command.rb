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
        Identity.new(name)
      end
    end
  end
end
