module Me
  module Cli
    class SshConfigView < Struct.new(:keys)
      def to_s
        "keys:\n#{key_list}"
      end

      private

      def key_list
        keys.map { |x| "- #{x}" }.join("\n")
      end
    end
  end
end
