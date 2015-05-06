require "me/store"

module Me
  RSpec.describe Store do
    def stateless_store
      described_class.new
    end
    alias_method :store, :stateless_store

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

    describe "#git_name, #git_email" do
      it "raises error when there is no active identity" do
        expect { store.git_name }.to raise_error(NoActiveIdentity)
        expect { store.git_email }.to raise_error(NoActiveIdentity)
      end

      it "raises error when it is not configured" do
        store.activate("personal")
        expect { store.git_name }.to raise_error(GitNotConfigured)
        expect { store.git_email }.to raise_error(GitNotConfigured)
      end

      it "is equal to configured value otherwise" do
        store.activate("personal")
        store.configure_git("john smith", "john@example.org")
        expect(store.git_name).to eq("john smith")
        expect(store.git_email).to eq("john@example.org")
      end
    end
  end
end
