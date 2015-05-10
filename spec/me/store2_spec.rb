require "me/store2"

module Me
  RSpec.describe Store2 do
    subject(:store) { Store2.new }

    describe ".build" do
      it "creates scoped instance with empty scope" do
        expect(Store2.build).to eq(Store2::Scoped.new(Store2.new, []))
      end
    end

    describe "#scoped" do
      it "creates scoped instance with specified scope" do
        expect(store.scoped("hello", "world"))
          .to eq(Store2::Scoped.new(Store2.new, ["hello", "world"]))
      end
    end

    describe "#get and #set" do
      it "gets the value given list of keys" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})
        store.set(["hello", "world", "test"], "12345")

        expect(store.get(["hello", "world", "test"]))
          .to eq("12345")
      end
    end

    describe "#has?" do
      it "is true if key is present" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})
        store.set(["hello", "world", "test"], "12345")

        expect(store.has?(["hello", "world", "test"])).to eq(true)
      end

      it "is false if key is not present" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})

        expect(store.has?(["hello", "world", "test"])).to eq(false)
      end
    end

    describe "#get_or_set" do
      it "is current value if it is present" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})
        store.set(["hello", "world", "test"], "09876")

        expect(store.get_or_set(["hello", "world", "test"], "12345")).to eq("09876")
      end

      it "is default value if it is not present" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})

        expect(store.get_or_set(["hello", "world", "test"], "12345")).to eq("12345")
      end

      it "makes the value present if it wasn't" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})
        store.get_or_set(["hello", "world", "test"], "12345")

        expect(store.get(["hello", "world", "test"])).to eq("12345")
      end
    end

    describe "#fetch" do
      it "behaves like get if value is present" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})
        store.set(["hello", "world", "test"], "09876")

        expect(store.fetch(["hello", "world", "test"]) { fail }).to eq("09876")
      end

      it "calls block if value is not present" do
        store.set(["hello"], {})
        store.set(["hello", "world"], {})

        expect { store.fetch(["hello", "world", "test"]) { fail } }
          .to raise_error(RuntimeError)
      end
    end
  end

  RSpec.describe Store2::Scoped do
    subject(:scoped) { described_class.new(store, scope) }

    let(:store) { instance_double(Store2) }
    let(:scope) { ["hello", "world", "test"] }

    let(:a_value) { double("A value") }
    let(:another_value) { double("A value") }
    let(:a_proc) { Proc.new { a_value } }

    describe "#scoped" do
      it "creates instance of Scoped with additional scope" do
        expect(scoped.scoped("additional", "scope"))
          .to eq(described_class.new(store, scope + ["additional", "scope"]))
      end
    end

    describe "#get" do
      it "delegates to store#get" do
        allow(store).to receive(:get).with(scope + ["some", "keys"]).and_return(a_value)
        expect(scoped.get("some", "keys")).to eq(a_value)
      end
    end

    describe "#set" do
      it "delegates to store#set" do
        expect(store).to receive(:set).with(scope + ["some", "keys"], a_value)
        scoped.set("some", "keys", a_value)
      end
    end

    describe "#has?" do
      it "delegates to store#has?" do
        allow(store).to receive(:has?).with(scope + ["some", "keys"]).and_return(a_value)
        expect(scoped.has?("some", "keys")).to eq(a_value)
      end
    end

    describe "#get_or_set" do
      it "delegates to store#get_or_set" do
        allow(store).to receive(:get_or_set).with(scope + ["some", "keys"], a_value).and_return(another_value)
        expect(scoped.get_or_set("some", "keys", a_value)).to eq(another_value)
      end
    end

    describe "#fetch" do
      it "delegates to store#fetch" do
        allow(store).to receive(:fetch).with(scope + ["some", "keys"]).and_yield
        expect(scoped.fetch("some", "keys", &a_proc)).to eq(a_value)
      end
    end

    describe "#save" do
      it "delegates to store#save" do
        expect(store).to receive(:save)
        scoped.save
      end
    end
  end
end
