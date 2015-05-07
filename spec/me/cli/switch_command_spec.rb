require "me/cli/switch_command"
require "me/store"
require "me/registry"

module Me
  module Cli
    RSpec.describe SwitchCommand do
      subject(:command) { described_class.new(identity) }

      let(:identity) { double("Identity") }
      let(:store_factory) { class_double(Store, new: store) }
      let(:store) { instance_double(Store, active_identity: active_identity) }
      let(:identity_store) { instance_double(IdentityStore) }

      let(:active_identity) { double("Identity", to_s: "new_identity") }

      before do
        Registry.register_store_factory(store_factory)

        allow(store_factory)
          .to receive(:with_identity)
          .with(identity)
          .and_return(identity_store)

        allow(identity_store).to receive(:activate)
      end

      describe "#call" do
        it "activates new identity" do
          expect(identity_store).to receive(:activate).once
          command.call
        end

        it "responds with new active identity" do
          expect(command.call.to_s).to eq("New active identity: new_identity")
        end
      end
    end
  end
end
