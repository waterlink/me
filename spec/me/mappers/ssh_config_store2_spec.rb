require "me/mappers/ssh_config_store2"

module Me
  module Mappers
    RSpec.describe SshConfigStore2 do
      let(:keys) { ["id_rsa", "id_dsa", "github.rsa"] }
      let(:identity) { "work" }

      before do
        described_class.new(keys, identity).update(keys: keys)
      end

      describe ".find_by_identity" do
        it "returns SshConfig instance with provided identity given it is present" do
          expect(described_class.find_by_identity(identity))
            .to eq(SshConfig.new(keys, identity))
        end

        it "fails with SshNotConfigured error if provided identity is not present" do
          expect {
            described_class.find_by_identity("another identity")
          }.to raise_error(Errors::SshNotConfigured)
        end
      end

      describe "#find" do
        it "returns SshConfig with same attributes" do
          expect(described_class.new(["a key", "another key"], "an identity").find)
            .to eq(SshConfig.new(["a key", "another key"], "an identity"))
        end

        it "fails with SshNotConfigured error if keys are not present" do
          expect {
            described_class.new(nil, "an identity").find
          }.to raise_error(Errors::SshNotConfigured)

          expect {
            described_class.new([], "an identity").find
          }.to raise_error(Errors::SshNotConfigured)
        end

        it "populates SshConfig if it is able to find it" do
          expect(described_class.new(nil, identity).find)
            .to eq(SshConfig.new(keys, identity))
        end
      end

      describe "#update" do
        it "allows to update keys" do
          keys = ["rsa key", "another key", "new key"]
          described_class.new(["a key", "another key"], identity).update(keys: keys)
          expect(described_class.find_by_identity(identity))
            .to eq(SshConfig.new(keys, identity))
        end

        it "is able to create new configuration" do
          keys = ["rsa key", "another key", "new key"]
          described_class.new(keys, "another identity").update(keys: keys)
          expect(described_class.find_by_identity("another identity"))
            .to eq(SshConfig.new(keys, "another identity"))
        end
      end
    end
  end
end
