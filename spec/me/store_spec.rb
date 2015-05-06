require "me/store"

module Me
  RSpec.describe Store do
    def stateless_store
      described_class.new
    end
    alias_method :store, :stateless_store

    shared_examples_for "configuration" do
      it "raises error when there is no active identity" do
        expect { fetch_it }.to raise_error(NoActiveIdentity)
      end

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
      subject(:identity_store) { described_class.with_identity(identity) }
      let(:identity) { "other_identity" }

      it "creates store operating on specific identity" do
        expect(identity_store.active_identity).to eq(identity)
      end

      it "does not activate this identity" do
        expect(identity_store.active_identity).not_to eq(store.active_identity)
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

    describe "#with_identity" do
      it "allows to temporary (for block) switch an identity" do
        store.activate("personal")
        expect(store.active_identity).to eq("personal")

        store.with_identity("work") do
          expect(store.active_identity).to eq("work")
        end

        expect(store.active_identity).to eq("personal")
      end
    end

    describe "git configuration" do
      let(:configure_it) { store.configure_git("john smith", "john@example.org") }
      let(:no_config_error) { GitNotConfigured }

      describe "#git_name" do
        include_examples "configuration"
        let(:fetch_it) { store.git_name }
        let(:expected) { "john smith" }
      end

      describe "#git_email" do
        include_examples "configuration"
        let(:fetch_it) { store.git_email }
        let(:expected) { "john@example.org" }
      end
    end

    describe "ssh configuration" do
      let(:configure_it) { store.configure_ssh(["id_rsa", "id_github", "id_bitbucket"]) }
      let(:no_config_error) { SshNotConfigured }

      describe "#ssh_keys" do
        include_examples "configuration"
        let(:fetch_it) { store.ssh_keys }
        let(:expected) { ["id_rsa", "id_github", "id_bitbucket"] }
      end
    end
  end
end
