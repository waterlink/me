require "me/identity_view_model"

module Me
  module Cli
    class NewActiveIdentityView < IdentityViewModel
      def to_s
        "New active identity: #{name}"
      end
    end
  end
end
