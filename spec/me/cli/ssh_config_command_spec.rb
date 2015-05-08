require "me/cli/ssh_config_command"
require "me/registry"

module Me
  module Cli
    RSpec.describe SshConfigCommand do
      subject(:command) { described_class.new(identity_name, keys) }

      let(:identity_name) { double("Identity Name") }

      let(:ssh_config) { instance_double(SshConfig, configure: nil) }
      let(:actual_ssh_config) { instance_double(SshConfig) }

      let(:expected_keys) { ["id_rsa", "id_dsa", "github.rsa"] }

      let(:mapper_factory) { class_double(SshConfig::Mapper) }
      let(:mapper) { instance_double(SshConfig::Mapper, find: ssh_config) }

      before do
        Registry.register_ssh_config_mapper_factory(mapper_factory)

        allow(mapper_factory)
          .to receive(:new)
          .with(keys, identity_name)
          .and_return(mapper)

        allow(mapper_factory)
          .to receive(:find_by_identity)
          .with(identity_name)
          .and_return(actual_ssh_config)

        allow(actual_ssh_config)
          .to receive(:build_view)
          .with(SshConfigView)
          .and_return(SshConfigView.new(keys: expected_keys))
      end

      describe "#call" do
        context "when there are some keys" do
          let(:keys) { instance_double(Array, empty?: false) }

          it "configures ssh with this keys" do
            expect(ssh_config).to receive(:configure).once
            command.call
          end

          it "responds with new key list" do
            expect(command.call.to_s).to eq("keys:\n- id_rsa\n- id_dsa\n- github.rsa")
          end
        end
      end
    end
  end
end
