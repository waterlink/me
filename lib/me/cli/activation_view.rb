require "me/activation_view_model"

module Me
  module Cli
    class ActivationView < ActivationViewModel
      def to_s
        "Executed:\n#{command_list}"
      end

      private

      def command_list
        commands
          .map(&method(:command_representation))
          .join("\n")
      end

      def command_representation(command)
        "- " + command.join(" ")
      end
    end
  end
end
