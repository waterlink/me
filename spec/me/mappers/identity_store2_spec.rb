require "me/mappers/identity_store2"

module Me
  module Mappers
    RSpec.describe IdentityStore2 do
      subject(:mapper) { described_class.new(name) }
      subject(:active_mapper) { described_class.new }

      let(:name) { "sarah" }
      let(:active_identity) { "james" }

      before do
        store = Store2.build
        store.set("active_identity", active_identity)
        store.save
      end

      describe "#find" do
        it "returns identity with specified name" do
          expect(mapper.find)
            .to eq(Identity.new(name))

          expect(active_mapper.find)
            .to eq(Identity.new(active_identity))
        end
      end

      describe "#update" do
        it "allows to change active identity" do
          mapper.update(active_identity: "john")
          expect(active_mapper.find)
            .to eq(Identity.new("john"))
        end
      end
    end
  end
end
