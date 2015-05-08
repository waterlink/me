require "me/cli/whoami_command"
require "me/registry"
require "me/store"

module Me
  module Cli
    RSpec.describe WhoamiCommand do
      subject(:command) { described_class.new }

      let(:identity) { instance_double(Identity) }

      before do
        allow(Identity).to receive(:active).and_return(identity)
        allow(identity)
          .to receive(:build_view)
          .with(ActiveIdentityView)
          .and_return(ActiveIdentityView.new(name: "personal"))
      end

      describe "#call" do
        it "has expected response" do
          expect(command.call.to_s).to eq("Active identity: personal")
        end
      end
    end
  end
end
