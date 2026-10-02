# frozen_string_literal: true

RSpec.describe ToyRobot::CommandParser do
  describe '.parse' do
    it 'parses PLACE with coords and facing' do
      name, args = described_class.parse('PLACE 1,2,NORTH')
      expect(name).to eq(:PLACE)
      expect(args).to eq([1, 2, ToyRobot::Direction::NORTH])
    end

    it 'is case-insensitive and whitespace-tolerant' do
      expect(described_class.parse('  place  3 , 4 , east  ')).to eq(
        [:PLACE, [3, 4, ToyRobot::Direction::EAST]]
      )
    end

    it 'returns nil for PLACE with an unknown facing' do
      expect(described_class.parse('PLACE 0,0,UP')).to be_nil
    end

    it 'returns nil for PLACE with non-integer coords' do
      expect(described_class.parse('PLACE a,b,NORTH')).to be_nil
    end

    it 'returns nil for PLACE missing arguments' do
      expect(described_class.parse('PLACE 0,0')).to be_nil
    end

    %w[MOVE LEFT RIGHT REPORT QUIT].each do |cmd|
      it "parses the nullary command #{cmd}" do
        expect(described_class.parse(cmd)).to eq([cmd.to_sym, []])
      end
    end

    it 'treats EXIT as an alias for QUIT' do
      expect(described_class.parse('EXIT')).to eq([:QUIT, []])
    end

    it 'parses nullary commands regardless of case and surrounding whitespace' do
      expect(described_class.parse('  move  ')).to eq([:MOVE, []])
    end

    it 'returns nil for unknown commands' do
      expect(described_class.parse('JUMP')).to be_nil
    end

    it 'returns nil for blank input' do
      expect(described_class.parse('')).to be_nil
      expect(described_class.parse("   \n")).to be_nil
    end

    it 'returns nil for nil input' do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
