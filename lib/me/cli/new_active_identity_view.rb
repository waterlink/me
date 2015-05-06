module Me
  module Cli
    class NewActiveIdentityView < Struct.new(:active_identity)
      def to_s
        "New active identity: #{active_identity}"
      end
    end
  end
end
