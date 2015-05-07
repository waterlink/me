module Me
  module Cli
    class GitNotConfiguredView < Struct.new(:cause, :identity)
      def to_s
        "Error '#{cause}' occurred. Details: Looks like git is not configured for '#{identity}' identity."
      end
    end
  end
end
