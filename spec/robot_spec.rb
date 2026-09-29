RSpec.describe ToyRobot::Robot do
  let(:table) { ToyRobot::Table.new }
  subject(:robot) { described_class.new(table) }

  N = ToyRobot::Direction::NORTH
  E = ToyRobot::Direction::EAST
  S = ToyRobot::Direction::SOUTH
  W = ToyRobot::Direction::WEST

  describe "before being placed" do
    it "is not placed" do
      expect(robot).not_to be_placed
    end

    it "ignores MOVE" do
      robot.move
      expect(robot).not_to be_placed
    end

    it "ignores LEFT and RIGHT" do
      robot.left
      robot.right
      expect(robot).not_to be_placed
    end

    it "reports nil" do
      expect(robot.report).to be_nil
    end
  end

  describe "#place" do
    it "sets position and facing when the target is in bounds" do
      robot.place(1, 2, E)
      expect(robot.report).to eq("1,2,EAST")
    end

    it "ignores placement outside the table" do
      robot.place(5, 5, N)
      expect(robot).not_to be_placed
    end

    it "ignores placement with a non-Direction facing" do
      robot.place(0, 0, "NORTH")
      expect(robot).not_to be_placed
    end

    it "replaces prior state with a subsequent valid PLACE" do
      robot.place(0, 0, N)
      robot.place(3, 3, S)
      expect(robot.report).to eq("3,3,SOUTH")
    end

    it "leaves prior state intact if the new PLACE is invalid" do
      robot.place(2, 2, N)
      robot.place(9, 9, E)
      expect(robot.report).to eq("2,2,NORTH")
    end
  end

  describe "#move" do
    it "advances one step in the facing direction" do
      robot.place(1, 1, N)
      robot.move
      expect(robot.report).to eq("1,2,NORTH")
    end

    it "does not fall off the north edge" do
      robot.place(0, 4, N)
      robot.move
      expect(robot.report).to eq("0,4,NORTH")
    end

    it "does not fall off the south edge" do
      robot.place(0, 0, S)
      robot.move
      expect(robot.report).to eq("0,0,SOUTH")
    end

    it "does not fall off the east edge" do
      robot.place(4, 0, E)
      robot.move
      expect(robot.report).to eq("4,0,EAST")
    end

    it "does not fall off the west edge" do
      robot.place(0, 0, W)
      robot.move
      expect(robot.report).to eq("0,0,WEST")
    end
  end

  describe "rotation" do
    it "LEFT rotates counter-clockwise without moving" do
      robot.place(2, 2, N)
      robot.left
      expect(robot.report).to eq("2,2,WEST")
    end

    it "RIGHT rotates clockwise without moving" do
      robot.place(2, 2, N)
      robot.right
      expect(robot.report).to eq("2,2,EAST")
    end
  end
end
