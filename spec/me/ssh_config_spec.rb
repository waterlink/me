require "me/ssh_config"
require "me/store"
require "me/registry"

module Me
  RSpec.describe SshConfig do
    subject(:ssh_config) { SshConfig.new(keys, identity_name) }

    let(:identity_name) { "sarah_work" }
    let(:keys) { ["id_rsa", "github.rsa"] }

    let(:store_factory) { class_double(Store) }
    let(:identity_store) { instance_double(IdentityStore) }

    before do
      Registry.register_store_factory(store_factory)
      allow(store_factory)
        .to receive(:with_identity)
        .with(identity_name)
        .and_return(identity_store)
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
          expect(identity_store)
            .to receive(:save_ssh_config)
            .with("keys" => keys)
            .once

          ssh_config.configure
        end
      end

      context "when keys are empty" do
        let(:keys) { instance_double(Array, empty?: true) }

        it "does nothing" do
          expect(identity_store).not_to receive(:save_ssh_config)
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
      let(:found_keys) { double("Keys") }

      before do
        allow(identity_store).to receive(:ssh_config).and_return("keys" => found_keys)
      end

      it "finds ssh config for specified identity" do
        expect(ssh_config).to eq(SshConfig.new(found_keys, identity_name))
      end
    end
  end
end
