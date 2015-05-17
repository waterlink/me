require "me/activation"

module Me
  RSpec.describe Activation do
    subject(:activation) { Activation.new._with_commands(commands) }

    let(:commands) { double("commands") }

    let(:view_factory) { double("ViewFactory") }
    let(:view) { double("View") }

    describe "#build_view" do
      it "gives commands to a view" do
        allow(view_factory)
          .to receive(:new)
          .with(commands: commands)
          .and_return(view)
        expect(activation.build_view(view_factory)).to eq(view)
      end
    end
  end
end
