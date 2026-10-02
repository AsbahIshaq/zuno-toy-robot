# frozen_string_literal: true

RSpec.describe ToyRobot::Robot do
  subject(:robot) { described_class.new(table) }

  let(:table) { ToyRobot::Table.new }
  let(:north) { ToyRobot::Direction::NORTH }
  let(:east)  { ToyRobot::Direction::EAST }
  let(:south) { ToyRobot::Direction::SOUTH }
  let(:west)  { ToyRobot::Direction::WEST }

  describe 'before being placed' do
    it 'is not placed' do
      expect(robot).not_to be_placed
    end

    it 'ignores MOVE' do
      robot.move
      expect(robot).not_to be_placed
    end

    it 'ignores LEFT and RIGHT' do
      robot.left
      robot.right
      expect(robot).not_to be_placed
    end

    it 'reports nil' do
      expect(robot.report).to be_nil
    end
  end

  describe '#place' do
    it 'sets position and facing when the target is in bounds' do
      robot.place(1, 2, east)
      expect(robot.report).to eq('1,2,EAST')
    end

    it 'ignores placement outside the table' do
      robot.place(5, 5, north)
      expect(robot).not_to be_placed
    end

    it 'ignores placement with a non-Direction facing' do
      robot.place(0, 0, 'NORTH')
      expect(robot).not_to be_placed
    end

    it 'replaces prior state with a subsequent valid PLACE' do
      robot.place(0, 0, north)
      robot.place(3, 3, south)
      expect(robot.report).to eq('3,3,SOUTH')
    end

    it 'leaves prior state intact if the new PLACE is invalid' do
      robot.place(2, 2, north)
      robot.place(9, 9, east)
      expect(robot.report).to eq('2,2,NORTH')
    end
  end

  describe '#move' do
    it 'advances one step in the facing direction' do
      robot.place(1, 1, north)
      robot.move
      expect(robot.report).to eq('1,2,NORTH')
    end

    it 'does not fall off the north edge' do
      robot.place(0, 4, north)
      robot.move
      expect(robot.report).to eq('0,4,NORTH')
    end

    it 'does not fall off the south edge' do
      robot.place(0, 0, south)
      robot.move
      expect(robot.report).to eq('0,0,SOUTH')
    end

    it 'does not fall off the east edge' do
      robot.place(4, 0, east)
      robot.move
      expect(robot.report).to eq('4,0,EAST')
    end

    it 'does not fall off the west edge' do
      robot.place(0, 0, west)
      robot.move
      expect(robot.report).to eq('0,0,WEST')
    end
  end

  describe 'rotation' do
    it 'LEFT rotates counter-clockwise without moving' do
      robot.place(2, 2, north)
      robot.left
      expect(robot.report).to eq('2,2,WEST')
    end

    it 'RIGHT rotates clockwise without moving' do
      robot.place(2, 2, north)
      robot.right
      expect(robot.report).to eq('2,2,EAST')
    end
  end

  describe 'return values signal success or ignore' do
    it 'returns true from a valid #place and false from an invalid one' do
      expect(robot.place(1, 1, north)).to be(true)
      expect(robot.place(9, 9, north)).to be(false)
      expect(robot.place(0, 0, 'NORTH')).to be(false)
    end

    it 'returns true from an in-bounds #move and false from one off the edge' do
      robot.place(0, 4, north)
      expect(robot.move).to be(false)
      robot.place(0, 0, east)
      expect(robot.move).to be(true)
    end

    it 'returns false for any state-changer called before PLACE' do
      expect(robot.move).to be(false)
      expect(robot.left).to be(false)
      expect(robot.right).to be(false)
    end

    it 'returns true for #left and #right once placed' do
      robot.place(0, 0, north)
      expect(robot.left).to be(true)
      expect(robot.right).to be(true)
    end
  end
end
