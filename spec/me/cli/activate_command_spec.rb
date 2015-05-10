require "me/cli/activate_command"
require "me/registry"
require "me/git_config"
require "me/ssh_config"
require "me/activation"

module Me
  module Cli
    RSpec.describe ActivateCommand do
      subject(:command) { described_class.new }

      let(:identity) { instance_double(Identity) }
      let(:git_config) { instance_double(GitConfig, activate: git_activation) }
      let(:ssh_config) { instance_double(SshConfig, activate: ssh_activation) }

      let(:git_activation) { instance_double(Activation) }
      let(:ssh_activation) { instance_double(Activation) }

      let(:git_view) { instance_double(ActivationView) }
      let(:ssh_view) { instance_double(ActivationView) }

      before do
        allow(Identity).to receive(:active).and_return(identity)

        allow(identity).to receive(:git_config).and_return(git_config)
        allow(identity).to receive(:ssh_config).and_return(ssh_config)

        allow(git_activation)
          .to receive(:build_view)
          .with(ActivationView)
          .and_return(git_view)

        allow(ssh_activation)
          .to receive(:build_view)
          .with(ActivationView)
          .and_return(ssh_view)
      end

      describe "#call" do
        it "activates active identity's git configuration" do
          expect(git_config).to receive(:activate)
          command.call
        end

        it "activates active identity's ssh configuration" do
          expect(ssh_config).to receive(:activate)
          command.call
        end

        it "renders proper response" do
          expect(command.call).to eq([git_view, ssh_view])
        end
      end
    end
  end
end
