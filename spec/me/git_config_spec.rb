require "me/git_config"
require "me/identity"
require "me/store"
require "me/registry"

module Me
  RSpec.describe GitConfig do
    subject(:git_config) { GitConfig.new(name, email, identity_name) }

    let(:name) { "sarah" }
    let(:email) { "sarah.o@example.org" }

    let(:identity_name) { "sarah_personal" }

    let(:store_factory) { class_double(Store) }
    let(:identity_store) { instance_double(Store, git_name: name, git_email: email) }

    before do
      Registry.register_store_factory(store_factory)
      allow(store_factory)
        .to receive(:with_identity)
        .with(identity_name)
        .and_return(identity_store)
    end

    describe "#initialize" do
      it "creates and object out of name and email" do
        expect(GitConfig.new("john", "john@example.org", identity_name))
          .to eq(GitConfig.new("john", "john@example.org", identity_name))
      end

      it "can be created with identity" do
        expect(GitConfig.new("john", "john@example.org", identity_name))
          .to eq(GitConfig.new("john", "john@example.org", identity_name))
      end
    end

    describe "#==" do
      it "is equal to git config with the same name and email" do
        expect(GitConfig.new("james", "james.black@example.org", identity_name))
          .to eq(GitConfig.new("james", "james.black@example.org", identity_name))
      end

      it "is not equal to git config with different name or email" do
        expect(GitConfig.new("james", "james.black@example.org", identity_name))
          .not_to eq(GitConfig.new("john", "james.black@example.org", identity_name))

        expect(GitConfig.new("james", "james.black@example.org", identity_name))
          .not_to eq(GitConfig.new("james", "john.smith@example.org", identity_name))

        expect(GitConfig.new("james", "james.black@example.org", identity_name))
          .not_to eq(GitConfig.new("john", "john.smith@example.org", identity_name))
      end

      it "handles edge cases properly" do
        expect(GitConfig.new("james", "james.black@example.org", identity_name)).not_to eq(nil)
        expect(GitConfig.new("james", "james.black@example.org", identity_name)).not_to eq(Object.new)
      end

      it "doesn't care about identity" do
        expect(GitConfig.new("james", "james.black@example.org", identity_name))
          .to eq(GitConfig.new("james", "james.black@example.org", "different name"))
      end
    end

    describe ".for_identity" do
      subject(:git_config) { GitConfig.for_identity(identity_name) }
      let(:found_name) { double("Name") }
      let(:found_email) { double("Email") }

      before do
        allow(identity_store).to receive(:git_name).and_return(found_name)
        allow(identity_store).to receive(:git_email).and_return(found_email)
      end

      it "finds git config for specified identity" do
        expect(git_config).to eq(GitConfig.new(found_name, found_email, identity_name))
      end
    end

    describe "#configure" do
      context "when name and email are present" do
        it "delegates to store to configure git" do
          expect(identity_store)
            .to receive(:configure_git)
            .with(name, email)
            .once

          git_config.configure
        end
      end

      context "when name or email is not present" do
        let(:name) { nil }
        let(:email) { nil }

        it "does nothing" do
          expect(identity_store).not_to receive(:configure_git)
          git_config.configure
        end
      end
    end

    describe "#build_view" do
      let(:view_factory) { double("ViewFactory") }
      let(:view) { double("View") }

      it "gives name and email to view factory" do
        allow(view_factory)
          .to receive(:new)
          .with(name: name, email: email)
          .and_return(view)
        expect(git_config.build_view(view_factory)).to eq(view)
      end
    end
  end
end
