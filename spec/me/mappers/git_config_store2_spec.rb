require "me/mappers/git_config_store2"

module Me
  module Mappers
    RSpec.describe GitConfigStore2 do
      let(:email) { "john@example.org" }
      let(:name) { "John Smith" }
      let(:identity) { "john_personal" }

      before do
        described_class.new(name, email, identity).update(name: name, email: email)
      end

      describe ".find_by_identity" do
        it "finds an identity if it is present" do
          expect(described_class.find_by_identity(identity))
            .to eq(GitConfig.new(name, email, identity))
        end

        it "fails with GitNotConfigured error if git configuration is not present" do
          expect {
            described_class.find_by_identity("other")
          }.to raise_error(Errors::GitNotConfigured)
        end
      end

      describe "#find" do
        it "returns GitConfig with same attributes" do
          expect(described_class.new("a name", "a email", "a identity").find)
            .to eq(GitConfig.new("a name", "a email", "a identity"))
        end

        it "fails with GitNotConfigured when name or email is not provided" do
          expect {
            described_class.new(nil, "a email", "a identity").find
          }.to raise_error(Errors::GitNotConfigured)

          expect {
            described_class.new("a name", nil, "a identity").find
          }.to raise_error(Errors::GitNotConfigured)
        end

        it "populates GitConfig with missing attributes if it is able to find it" do
          expect(described_class.new(nil, "a email", identity).find)
            .to eq(GitConfig.new(name, "a email", identity))
        end
      end

      describe "#update" do
        it "allows to update name" do
          described_class.new("a name", "a email", identity).update(name: "John")
          expect(described_class.find_by_identity(identity))
            .to eq(GitConfig.new("John", email, identity))
        end

        it "allows to update email" do
          described_class.new("a name", "a email", identity).update(email: "john@corporation.com")
          expect(described_class.find_by_identity(identity))
            .to eq(GitConfig.new(name, "john@corporation.com", identity))
        end

        it "allows to create new configuration" do
          described_class.new("a name", "a email", "an identity")
            .update(name: "James", email: "james@corporation.com")
          expect(described_class.find_by_identity("an identity"))
            .to eq(GitConfig.new("James", "james@corporation.com", "an identity"))
        end
      end
    end
  end
end
