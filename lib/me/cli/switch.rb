require "forwardable"
require "me/registry"
require "me/cli/new_active_identity_view"

module Me
  module Cli
    class Switch < Struct.new(:identity)
      extend Forwardable

      def call
        activate(identity)
        NewActiveIdentityView[active_identity]
      end

      private

      delegate [:activate, :active_identity] => :store

      def store
        Registry.store_factory.new
      end
    end
  end
end
