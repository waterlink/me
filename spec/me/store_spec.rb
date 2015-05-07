require "me/store"

module Me
  RSpec.describe Store do
    def stateless_store
      described_class.new
    end
    alias_method :store, :stateless_store

    shared_examples_for "configuration" do
      it "raises error when it is not configured" do
        store.activate("personal")
        expect { fetch_it }.to raise_error(no_config_error)
      end

      it "is equal to configured value otherwise" do
        store.activate("personal")
        configure_it
        expect(fetch_it).to eq(expected)
      end
    end

    describe ".with_identity" do
      it "creates IdentityStore" do
        identity = "an identity"
        expect(described_class.with_identity(identity))
          .to eq(IdentityStore.new(Store.new, identity))
      end
    end

    describe "#active_identity" do
      it "is none identity when there is no active identity" do
        expect(store.active_identity).to eq("<none>")
      end

      it "is equal to active identity when it is set" do
        store.activate("personal")
        expect(store.active_identity).to eq("personal")
      end
    end

    describe "git configuration" do
      let(:configure_it) { store.save_git_config(
        "personal","name" => "john smith", "email" => "john@example.org"
      ) }
      let(:no_config_error) { Errors::GitNotConfigured }

      describe "#git_name" do
        include_examples "configuration"
        let(:fetch_it) { store.git_config("personal")["name"] }
        let(:expected) { "john smith" }
      end

      describe "#git_email" do
        include_examples "configuration"
        let(:fetch_it) { store.git_config("personal")["email"] }
        let(:expected) { "john@example.org" }
      end
    end

    describe "ssh configuration" do
      let(:configure_it) { store.save_ssh_config(
        "work", "keys" => ["id_rsa", "id_github", "id_bitbucket"]
      ) }
      let(:no_config_error) { Errors::SshNotConfigured }

      describe "#ssh_keys" do
        include_examples "configuration"
        let(:fetch_it) { store.ssh_config("work")["keys"] }
        let(:expected) { ["id_rsa", "id_github", "id_bitbucket"] }
      end
    end
  end
end
