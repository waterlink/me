require "me/cli/switch"
require "me/store"
require "me/registry"

module Me
  module Cli
    RSpec.describe Switch do
      subject(:command) { described_class.new(identity) }

      let(:identity) { double("Identity") }
      let(:store_factory) { class_double(Store, new: store) }
      let(:store) { instance_double(Store, active_identity: active_identity) }

      let(:active_identity) { double("Identity", to_s: "new_identity") }

      before do
        Registry.register_store_factory(store_factory)
        allow(store).to receive(:activate).with(identity)
      end

      describe "#call" do
        it "activates new identity" do
          expect(store).to receive(:activate).with(identity).once
          command.call
        end

        it "responds with new active identity" do
          expect(command.call).to eq("New active identity: new_identity")
        end
      end
    end
  end
end
