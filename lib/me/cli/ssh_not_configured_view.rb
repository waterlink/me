module Me
  module Cli
    class SshNotConfiguredView < Struct.new(:cause, :identity)
      def to_s
        "Error '#{cause}' occurred. Details: Looks like ssh is not configured for '#{identity}' identity."
      end
    end
  end
end
