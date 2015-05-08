require "me/cli/git_config_command"
require "me/registry"

module Me
  module Cli
    RSpec.describe GitConfigCommand do
      subject(:command) { described_class.new(identity_name, name, email) }

      let(:identity_name) { double("Identity Name") }

      let(:git_config) { instance_double(GitConfig, configure: nil) }
      let(:actual_git_config) { instance_double(GitConfig) }

      let(:mapper_factory) { class_double(GitConfig::Mapper) }
      let(:mapper) { instance_double(GitConfig::Mapper, find: git_config) }

      before do
        Registry.register_git_config_mapper_factory(mapper_factory)

        allow(mapper_factory)
          .to receive(:new)
          .with(name, email, identity_name)
          .and_return(mapper)

        allow(mapper_factory)
          .to receive(:find_by_identity)
          .with(identity_name)
          .and_return(actual_git_config)

        allow(actual_git_config)
          .to receive(:build_view)
          .with(GitConfigView)
          .and_return(GitConfigView.new(name: name, email: email))
      end

      describe "#call" do
        context "when name and email specified" do
          let(:name) { "john" }
          let(:email) { "john@example.org" }

          it "configures git" do
            expect(git_config).to receive(:configure).once
            command.call
          end

          it "renders new configuration" do
            expect(command.call.to_s).to eq("name:  john\nemail: john@example.org")
          end
        end
      end
    end
  end
end
