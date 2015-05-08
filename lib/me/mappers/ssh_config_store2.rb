require "me/store2"
require "me/ssh_config"

module Me
  module Mappers
    class SshConfigStore2 < SshConfig::Mapper
      def self.find_by_identity(identity_name)
        new(nil, identity_name).find
      end

      def initialize(keys, identity_name)
        @identity_name = identity_name
        @keys = keys || fetch_keys
      end

      def find
        SshConfig
          .new(keys, identity_name)
          .with_mapper(self)
      end

      def update(keys: nil, identity_name: nil)
        return unless keys
        identity.get_or_set("ssh", {})
        scoped.set("keys", keys)
        scoped.save
      end

      private

      attr_reader :identity_name, :keys

      def fetch_keys
        scoped.get("keys")
      end

      def store
        @_store ||= Store2.build
      end

      def identity
        @_identity ||= store.scoped("identities", identity_name)
      end

      def scoped
        @_scoped ||= identity.scoped("ssh")
      end
    end
  end
end
