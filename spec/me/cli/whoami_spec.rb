require "me/cli/whoami"
require "me/registry"
require "me/store"

module Me
  module Cli
    RSpec.describe Whoami do
      subject(:command) { described_class.new }

      let(:store_factory) { class_double(Store, new: store) }
      let(:store) { instance_double(Store, active_identity: "personal") }

      before do
        Registry.register_store_factory(store_factory)
      end

      describe "#call" do
        it "has expected response" do
          expect(command.call.to_s).to eq("Active identity: personal")
        end
      end
    end
  end
end
