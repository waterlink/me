require "forwardable"
require "me/registry"
require "me/cli/active_identity_view"

module Me
  module Cli
    class Whoami
      extend Forwardable

      def call
        ActiveIdentityView[active_identity]
      end

      private

      delegate [:active_identity] => :store

      def store
        Registry.store_factory.new
      end
    end
  end
end
