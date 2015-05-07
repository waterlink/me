require "forwardable"
require "me/registry"
require "me/identity"
require "me/cli/active_identity_view"

module Me
  module Cli
    class Whoami
      extend Forwardable

      def call
        active_identity.build_view(ActiveIdentityView)
      end

      private

      def active_identity
        Identity.active
      end
    end
  end
end
