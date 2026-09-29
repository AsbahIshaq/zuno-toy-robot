RSpec.describe ToyRobot::Direction do
  describe "compass deltas" do
    it "moves +y for NORTH" do
      expect([described_class::NORTH.dx, described_class::NORTH.dy]).to eq([0, 1])
    end

    it "moves -y for SOUTH" do
      expect([described_class::SOUTH.dx, described_class::SOUTH.dy]).to eq([0, -1])
    end

    it "moves +x for EAST" do
      expect([described_class::EAST.dx, described_class::EAST.dy]).to eq([1, 0])
    end

    it "moves -x for WEST" do
      expect([described_class::WEST.dx, described_class::WEST.dy]).to eq([-1, 0])
    end
  end

  describe "#right" do
    it "cycles N -> E -> S -> W -> N" do
      d = described_class::NORTH
      names = 4.times.map { d = d.right; d.name }
      expect(names).to eq([:EAST, :SOUTH, :WEST, :NORTH])
    end
  end

  describe "#left" do
    it "cycles N -> W -> S -> E -> N" do
      d = described_class::NORTH
      names = 4.times.map { d = d.left; d.name }
      expect(names).to eq([:WEST, :SOUTH, :EAST, :NORTH])
    end
  end

  it "left and right are inverses" do
    described_class::ALL.each do |d|
      expect(d.right.left).to eq(d)
      expect(d.left.right).to eq(d)
    end
  end

  describe ".from_name" do
    it "resolves valid names" do
      expect(described_class.from_name("NORTH")).to eq(described_class::NORTH)
      expect(described_class.from_name(:SOUTH)).to eq(described_class::SOUTH)
    end

    it "returns nil for unknown names" do
      expect(described_class.from_name("UP")).to be_nil
    end
  end

  it "instances are frozen" do
    expect(described_class::NORTH).to be_frozen
  end
end
