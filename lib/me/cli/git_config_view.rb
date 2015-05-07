require "me/git_config_view_model"

module Me
  module Cli
    class GitConfigView < GitConfigViewModel
      def to_s
        "name:  #{name}\nemail: #{email}"
      end
    end
  end
end
