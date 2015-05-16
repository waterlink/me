require "me/ssh_config"
require "me/executor"
require "me/registry"

module Me
  RSpec.describe SshConfig do
    subject(:ssh_config) { SshConfig.new(keys, identity_name).with_mapper(mapper) }

    let(:identity_name) { "sarah_work" }
    let(:keys) { ["id_rsa", "github.rsa"] }

    let(:found_ssh_config) { instance_double(SshConfig) }

    let(:mapper_factory) { class_double(SshConfig::Mapper) }
    let(:mapper) { instance_double(SshConfig::Mapper) }

    let(:executor_factory) { class_double(Executor, new: executor) }
    let(:executor) { instance_double(Executor) }

    before do
      Registry.register_ssh_config_mapper_factory(mapper_factory)
      allow(mapper_factory)
        .to receive(:find_by_identity)
        .with(identity_name)
        .and_return(found_ssh_config)

      Registry.register_executor_factory(executor_factory)
    end

    describe "#initialize" do
      it "can be created with keys and identity_name" do
        expect(SshConfig.new(["key_a", "key_b"], identity_name))
          .to eq(SshConfig.new(["key_a", "key_b"], identity_name))
      end
    end

    describe "#==" do
      it "is equal to other config with the same keys" do
        expect(SshConfig.new(["key_c", "key_b"], identity_name))
          .to eq(SshConfig.new(["key_c", "key_b"], identity_name))
      end

      it "is not equal to other config with different keys" do
        expect(SshConfig.new(["key_c", "key_b"], identity_name))
          .not_to eq(SshConfig.new(["key_c", "github"], identity_name))
      end

      it "handles edge cases properly" do
        expect(SshConfig.new(["key_c", "key_b"], identity_name)).not_to eq(nil)
        expect(SshConfig.new(["key_c", "key_b"], identity_name)).not_to eq(Object.new)
      end

      it "doesn't care about identity_name" do
        expect(SshConfig.new(["key_c", "key_b"], identity_name))
          .to eq(SshConfig.new(["key_c", "key_b"], "different name"))
      end
    end

    describe "#configure" do
      context "when keys are not empty" do
        let(:keys) { instance_double(Array, empty?: false) }

        it "delegates to store to configure ssh" do
          expect(mapper)
            .to receive(:update)
            .with(keys: keys)
            .once

          ssh_config.configure
        end
      end

      context "when keys are empty" do
        let(:keys) { instance_double(Array, empty?: true) }

        it "does nothing" do
          expect(mapper).not_to receive(:update)
          ssh_config.configure
        end
      end
    end

    describe "#build_view" do
      let(:view_factory) { double("ViewFactory") }
      let(:view) { double("View") }

      it "gives keys to view factory" do
        allow(view_factory)
          .to receive(:new)
          .with(keys: keys)
          .and_return(view)
        expect(ssh_config.build_view(view_factory)).to eq(view)
      end
    end

    describe ".for_identity" do
      subject(:ssh_config) { SshConfig.for_identity(identity_name) }

      it "finds ssh config for specified identity" do
        expect(ssh_config).to eq(found_ssh_config)
      end
    end

    describe "#activate" do
      it "sets up proper ssh keys" do
        [
          ["ssh-add", "-D"],
          ["ssh-add", "id_rsa"],
          ["ssh-add", "github.rsa"],
        ].each do |command|
          expect(executor).to receive(:call).with(command).ordered.once
        end

        ssh_config.activate
      end
    end
  end
end
