require "forwardable"

require "me/cli/activation_view"

module Me
  module Cli
    class ActivateCommand
      extend Forwardable

      def call
        build_views([
          git_config.activate,
          ssh_config.activate,
        ])
      end

      private

      delegate [:ssh_config, :git_config] => :identity

      def identity
        @_identity ||= Identity.active
      end

      def build_views(activations)
        activations.map { |a| a.build_view(ActivationView) }
      end
    end
  end
end
