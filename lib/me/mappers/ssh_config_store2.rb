require "me/ssh_config"
require "me/errors"
require "me/store"

module Me
  module Mappers
    class SshConfigStore2 < SshConfig::Mapper
      def self.find_by_identity(identity_name)
        new(nil, identity_name).find
      end

      def initialize(keys, identity_name)
        @identity_name = identity_name
        @keys = fetch_keys(keys)
      end

      def find
        ensure_present
        SshConfig
          .new(keys, identity_name)
          .with_mapper(self)
      end

      def update(keys: nil, identity_name: nil)
        return unless keys
        scoped.set("keys", keys)
        scoped.save
      end

      private

      attr_reader :identity_name, :keys

      def ensure_present
        return if keys && !keys.empty?
        fail Errors::SshNotConfigured, identity_name
      end

      def fetch_keys(keys)
        return keys if keys && !keys.empty?
        scoped.fetch("keys") { nil }
      end

      def store
        @_store ||= Store.build
      end

      def identity
        @_identity ||= _identity
      end

      def _identity
        store.get_or_set("identities", {})
        store.get_or_set("identities", identity_name, {})
        store.scoped("identities", identity_name)
      end

      def scoped
        @_scoped ||= _scoped
      end

      def _scoped
        identity.get_or_set("ssh", {})
        identity.scoped("ssh")
      end
    end
  end
end
