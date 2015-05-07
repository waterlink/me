require "forwardable"
require "me/registry"
require "me/cli/new_active_identity_view"

module Me
  module Cli
    class SwitchCommand < Struct.new(:name)
      extend Forwardable

      def call
        activate
        active_identity.build_view(NewActiveIdentityView)
      end

      private

      delegate [:activate] => :identity

      def active_identity
        Identity.active
      end

      def identity
        Identity.new(name)
      end
    end
  end
end
