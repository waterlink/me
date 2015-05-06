require "forwardable"
require "me/registry"

module Me
  module Cli
    class Whoami
      extend Forwardable

      def call
        "Active identity: #{active_identity}"
      end

      private

      delegate [:active_identity] => :store

      def store
        Registry.store_factory.new
      end
    end
  end
end
