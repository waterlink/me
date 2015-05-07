require "me/identity"
require "me/store"
require "me/registry"

module Me
  RSpec.describe Identity do
    subject(:identity) { Identity.new(name) }

    let(:name) { "john" }

    let(:store_factory) { class_double(Store, new: store) }
    let(:store) { instance_double(Store) }
    let(:identity_store) { instance_double(Store) }

    before do
      Registry.register_store_factory(store_factory)
      allow(store_factory)
        .to receive(:with_identity)
        .with(name)
        .and_return(identity_store)
    end

    describe "#initialize" do
      it "can be created with name" do
        expect(Identity.new("john")).to eq(Identity.new("john"))
      end
    end

    describe "#==" do
      it "is equal to the identity with the same name" do
        expect(Identity.new("james")).to eq(Identity.new("james"))
      end

      it "is not equal to the identity with different name" do
        expect(Identity.new("james")).not_to eq(Identity.new("john"))
      end

      it "handles edge cases properly" do
        expect(Identity.new("james")).not_to eq(nil)
        expect(Identity.new("sarah")).not_to eq(Object.new)
      end
    end

    describe ".active" do
      it "returns active identity" do
        allow(store).to receive(:active_identity).and_return("sarah")
        expect(Identity.active).to eq(Identity.new("sarah"))
      end
    end

    describe "#build_view" do
      let(:view_factory) { double("ViewFactory") }
      let(:view) { double("View") }

      before do
        allow(view_factory)
          .to receive(:new)
          .with(name: name)
          .and_return(view)
      end

      it "gives the view its name" do
        expect(identity.build_view(view_factory)).to eq(view)
      end
    end

    describe "#activate" do
      it "delegates to store to activate identity with corresponding name" do
        expect(identity_store).to receive(:activate!).once
        identity.activate
      end
    end
  end
end
