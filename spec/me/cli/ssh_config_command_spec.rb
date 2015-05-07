require "me/cli/ssh_config_command"
require "me/registry"
require "me/store"

module Me
  module Cli
    RSpec.describe SshConfigCommand do
      subject(:command) { described_class.new(identity, keys) }

      let(:identity) { double("Identity") }
      let(:store_factory) { class_double(Store) }
      let(:store) { instance_double(IdentityStore, ssh_config: ssh_config) }

      let(:ssh_config) { { "keys" => expected_keys } }

      let(:expected_keys) { ["id_rsa", "id_dsa", "github.rsa"] }

      before do
        Registry.register_store_factory(store_factory)
        allow(store_factory).to receive(:with_identity).with(identity).and_return(store)
        allow(store).to receive(:save_ssh_config).with("keys" => keys)
      end

      describe "#call" do
        context "when there are some keys" do
          let(:keys) { instance_double(Array, empty?: false) }

          it "configures ssh with this keys" do
            expect(store).to receive(:save_ssh_config).with("keys" => keys).once
            command.call
          end

          it "responds with new key list" do
            expect(command.call.to_s).to eq("keys:\n- id_rsa\n- id_dsa\n- github.rsa")
          end
        end

        context "when there are no keys" do
          let(:keys) { instance_double(Array, empty?: true) }

          it "does not configure ssh" do
            expect(store).not_to receive(:save_ssh_config)
            command.call
          end

          it "responds with current key list" do
            expect(command.call.to_s).to eq("keys:\n- id_rsa\n- id_dsa\n- github.rsa")
          end
        end
      end
    end
  end
end
