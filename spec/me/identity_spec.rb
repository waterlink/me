require "me/identity"
require "me/registry"

module Me
  RSpec.describe Identity do
    subject(:identity) { Identity.new(name).with_mapper(mapper) }

    let(:name) { "john" }

    let(:mapper_factory) { class_double(Identity::Mapper, new: active_mapper) }
    let(:active_mapper) { instance_double(Identity::Mapper) }
    let(:mapper) { instance_double(Identity::Mapper) }

    before do
      Registry.register_identity_mapper_factory(mapper_factory)
      allow(mapper_factory)
        .to receive(:new)
        .with(name)
        .and_return(mapper)
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
        expected = instance_double(Identity)
        allow(active_mapper).to receive(:find).and_return(expected)
        expect(Identity.active).to eq(expected)
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
      it "calls update on mapper with active_identity = name" do
        expect(mapper).to receive(:update).with(active_identity: name).once
        identity.activate
      end
    end
  end
end
