require "me/identity_view_model"

module Me
  module Cli
    class ActiveIdentityView < IdentityViewModel
      def to_s
        "Active identity: #{name}"
      end
    end
  end
end
