module Me
  module Cli
    class GitConfigView < Struct.new(:name, :email)
      def to_s
        "name:  #{name}\nemail: #{email}"
      end
    end
  end
end
