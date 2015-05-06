module Me
  module Cli
    class ActiveIdentityView < Struct.new(:active_identity)
      def to_s
        "Active identity: #{active_identity}"
      end
    end
  end
end
