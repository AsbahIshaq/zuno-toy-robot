RSpec.describe ToyRobot::Table do
  subject(:table) { described_class.new }

  describe "default size" do
    it "is 5x5" do
      expect([table.width, table.height]).to eq([5, 5])
    end
  end

  describe "#in_bounds?" do
    it "accepts the SW corner" do
      expect(table.in_bounds?(0, 0)).to be(true)
    end

    it "accepts the NE corner" do
      expect(table.in_bounds?(4, 4)).to be(true)
    end

    it "rejects x just past the east edge" do
      expect(table.in_bounds?(5, 4)).to be(false)
    end

    it "rejects y just past the north edge" do
      expect(table.in_bounds?(4, 5)).to be(false)
    end

    it "rejects negative coordinates" do
      expect(table.in_bounds?(-1, 0)).to be(false)
      expect(table.in_bounds?(0, -1)).to be(false)
    end
  end

  it "supports custom dimensions" do
    small = described_class.new(width: 2, height: 3)
    expect(small.in_bounds?(1, 2)).to be(true)
    expect(small.in_bounds?(2, 0)).to be(false)
  end

  it "rejects non-positive dimensions" do
    expect { described_class.new(width: 0, height: 5) }.to raise_error(ArgumentError)
  end
end
