require "me/store2"
require "me/git_config"

module Me
  module Mappers
    class GitConfigStore2 < GitConfig::Mapper
      def self.find_by_identity(identity_name)
        new(nil, nil, identity_name).find
      end

      def initialize(name, email, identity_name)
        @identity_name = identity_name
        @name = name || fetch_name
        @email = email || fetch_email
      end

      def find
        GitConfig
          .new(name, email, identity_name)
          .with_mapper(self)
      end

      def update(name: nil, email: nil)
        return unless name || email
        scoped.set("name", name) if name
        scoped.set("email", email) if email
        scoped.save
      end

      private

      attr_reader :name, :email, :identity_name

      def fetch_name
        scoped.get("name")
      end

      def fetch_email
        scoped.get("email")
      end

      def store
        @_store ||= Store2.build
      end

      def scoped
        @_scoped ||= store.scoped("identities", identity_name, "git")
      end
    end
  end
end
