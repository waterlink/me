require "me/executor"

module Me
  RSpec.describe Executor do
    subject(:executor) { described_class.new }

    let(:args) { double("args") }
    let(:kernel) { double("Kernel") }

    before do
      Registry.register_kernel(kernel)
    end

    describe "#call" do
      it "delegates to kernel" do
        expect(kernel)
          .to receive(:system)
          .with(args)
        executor.call(args)
      end
    end
  end
end
