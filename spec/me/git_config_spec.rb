require "me/git_config"
require "me/store"
require "me/registry"

module Me
  RSpec.describe GitConfig do
    subject(:git_config) { GitConfig.new(name, email, identity_name).with_mapper(mapper) }

    let(:name) { "sarah" }
    let(:email) { "sarah.o@example.org" }

    let(:identity_name) { "sarah_personal" }

    let(:mapper_factory) { class_double(GitConfig::Mapper) }
    let(:mapper) { instance_double(GitConfig::Mapper) }

    let(:git_config_hash) { { "name" => name, "email" => email } }

    before do
      Registry.register_git_config_mapper_factory(mapper_factory)
      allow(mapper_factory)
        .to receive(:find_by_identity)
        .with(identity_name)
        .and_return(git_config)
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
      subject(:git_config_from_identity) { GitConfig.for_identity(identity_name) }
      let(:a_git_config) { instance_double(GitConfig) }

      before do
        allow(mapper_factory)
          .to receive(:find_by_identity)
          .with(identity_name)
          .and_return(a_git_config)
      end

      it "finds git config for specified identity" do
        expect(git_config_from_identity).to eq(a_git_config)
      end
    end

    describe "#configure" do
      context "when name and email are present" do
        it "delegates to store to configure git" do
          expect(mapper)
            .to receive(:update)
            .with(name: name, email: email)
            .once

          git_config.configure
        end
      end

      context "when name or email is not present" do
        let(:name) { nil }
        let(:email) { nil }

        it "does nothing" do
          expect(mapper).not_to receive(:update)
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
