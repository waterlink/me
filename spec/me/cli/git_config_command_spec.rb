require "me/cli/git_config_command"
require "me/registry"
require "me/store"

module Me
  module Cli
    RSpec.describe GitConfigCommand do
      subject(:command) { described_class.new(identity, name, email) }

      let(:identity) { double("Identity") }
      let(:store_factory) { class_double(Store) }
      let(:store) { instance_double(IdentityStore, git_config: git_config) }

      let(:git_config) { { "name" => "john", "email" => "john@example.org" } }

      before do
        Registry.register_store_factory(store_factory)
        allow(store_factory).to receive(:with_identity).with(identity).and_return(store)
        allow(store).to receive(:save_git_config).with("name" => name, "email" => email)
      end

      describe "#call" do
        context "when name and email specified" do
          let(:name) { double("name") }
          let(:email) { double("email") }

          it "configures git" do
            expect(store).to receive(:save_git_config).with("name" => name, "email" => email).once
            command.call
          end

          it "renders new configuration" do
            expect(command.call.to_s).to eq("name:  john\nemail: john@example.org")
          end
        end

        context "when name or email are not specified" do
          let(:name) { nil }
          let(:email) { nil }

          it "does not configure git" do
            expect(store).not_to receive(:save_git_config)
            command.call
          end

          it "renders current configuration" do
            expect(command.call.to_s).to eq("name:  john\nemail: john@example.org")
          end
        end
      end
    end
  end
end
