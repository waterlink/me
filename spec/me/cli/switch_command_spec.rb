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

      let(:activate_command) { instance_double(ActivateCommand, call: activation_views) }
      let(:activation_views) { [activation_view_a, activation_view_b] }

      let(:activation_view_a) { double("View") }
      let(:activation_view_b) { double("View") }

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

        allow(ActivateCommand)
          .to receive(:new)
          .and_return(activate_command)
      end

      describe "#call" do
        it "activates new identity" do
          expect(identity).to receive(:activate).once
          command.call
        end

        it "activates configuration" do
          expect(activate_command).to receive(:call).and_return(activation_views)
          command.call
        end

        it "responds with new active identity" do
          expect(command.call[0].to_s).to eq("New active identity: new_identity")
        end

        it "responds with activation views too" do
          expect(command.call[1..-1]).to eq(activation_views)
        end
      end
    end
  end
end
