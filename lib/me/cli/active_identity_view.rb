require "me/view"

module Me
  module Cli
    class ActiveIdentityView < View.new(:name)
      def to_s
        "Active identity: #{name}"
      end
    end
  end
end
