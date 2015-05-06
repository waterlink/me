require "forwardable"
require "me/registry"

module Me
  module Cli
    class Switch < Struct.new(:identity)
      extend Forwardable

      def call
        activate(identity)
        "New active identity: #{active_identity}"
      end

      private

      delegate [:activate, :active_identity] => :store

      def store
        Registry.store_factory.new
      end
    end
  end
end
