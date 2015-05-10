require "me/cli/switch_command"
require "me/registry"

module Me
  module Cli
    RSpec.describe SwitchCommand do
      subject(:command) { described_class.new(name) }

      let(:name) { double("Name") }

      let(:identity) { double("Identity") }
      let(:mapper_factory) { class_double(Identity::Mapper) }
      let(:mapper) { instance_double(Identity::Mapper, find: identity) }

      let(:active_identity) { double("Active Identity") }

      before do
        Registry.register_identity_mapper_factory(mapper_factory)

        allow(Identity).to receive(:active).and_return(active_identity)
        allow(identity).to receive(:activate)
        allow(active_identity)
          .to receive(:build_view)
          .with(NewActiveIdentityView)
          .and_return(NewActiveIdentityView.new(name: "new_identity"))

        allow(mapper_factory)
          .to receive(:new)
          .with(name)
          .and_return(mapper)
      end

      describe "#call" do
        it "activates new identity" do
          expect(identity).to receive(:activate).once
          command.call
        end

        it "responds with new active identity" do
          expect(command.call.to_s).to eq("New active identity: new_identity")
        end
      end
    end
  end
end
