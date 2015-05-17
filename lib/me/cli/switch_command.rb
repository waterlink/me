require "me/identity"
require "me/cli/new_active_identity_view"
require "me/cli/activate_command"

module Me
  module Cli
    class SwitchCommand < Struct.new(:name)
      def call
        identity.activate
        activate_configuration
        views
      end

      protected

      attr_reader :activation_views

      private

      def views
        active_identity_views + activation_views
      end

      def activate_command
        @_activate_command ||= ActivateCommand.new
      end

      def activate_configuration
        @activation_views ||= Array(activate_command.call)
      end

      def active_identity
        Identity.active
      end

      def active_identity_views
        [active_identity.build_view(NewActiveIdentityView)]
      end

      def identity
        Registry.identity_mapper_factory.new(name).find
      end
    end
  end
end
