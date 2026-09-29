require "stringio"
require "shellwords"
require "rbconfig"

RSpec.describe ToyRobot::Simulator do
  def run(commands)
    output = StringIO.new
    described_class.new(input: StringIO.new(commands), output: output).run
    output.string
  end

  describe "PDF scenarios" do
    it "Scenario A — basic movement" do
      expect(run(<<~CMDS)).to eq("0,1,NORTH\n")
        PLACE 0,0,NORTH
        MOVE
        REPORT
      CMDS
    end

    it "Scenario B — rotation" do
      expect(run(<<~CMDS)).to eq("0,0,WEST\n")
        PLACE 0,0,NORTH
        LEFT
        REPORT
      CMDS
    end

    it "Scenario C — complex sequence" do
      expect(run(<<~CMDS)).to eq("3,3,NORTH\n")
        PLACE 1,2,EAST
        MOVE
        MOVE
        LEFT
        MOVE
        REPORT
      CMDS
    end
  end

  describe "invariants" do
    it "discards all commands before the first valid PLACE" do
      output = run(<<~CMDS)
        MOVE
        LEFT
        REPORT
        PLACE 1,1,SOUTH
        REPORT
      CMDS
      expect(output).to eq("1,1,SOUTH\n")
    end

    it "discards a PLACE that would put the robot off the table" do
      output = run(<<~CMDS)
        PLACE 9,9,NORTH
        REPORT
        PLACE 2,2,EAST
        REPORT
      CMDS
      expect(output).to eq("2,2,EAST\n")
    end

    it "ignores unknown and blank lines interspersed with valid commands" do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH

        HOP
        MOVE
        REPORT
      CMDS
      expect(output).to eq("0,1,NORTH\n")
    end

    it "supports re-placement mid-sequence" do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH
        MOVE
        PLACE 4,4,SOUTH
        MOVE
        REPORT
      CMDS
      expect(output).to eq("4,3,SOUTH\n")
    end

    it "emits one line per REPORT" do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH
        REPORT
        MOVE
        REPORT
      CMDS
      expect(output).to eq("0,0,NORTH\n0,1,NORTH\n")
    end
  end

  describe "CLI smoke test" do
    let(:root) { File.expand_path("..", __dir__) }
    let(:bin) { File.join(root, "bin", "toy_robot") }

    it "runs scenario C from a file argument" do
      fixture = File.join(root, "spec", "fixtures", "scenario_c.txt")
      output = `#{RbConfig.ruby} #{bin.shellescape} #{fixture.shellescape}`
      expect(output).to eq("3,3,NORTH\n")
    end

    it "runs scenario A from STDIN" do
      output = IO.popen([RbConfig.ruby, bin], "r+") do |io|
        io.write("PLACE 0,0,NORTH\nMOVE\nREPORT\n")
        io.close_write
        io.read
      end
      expect(output).to eq("0,1,NORTH\n")
    end
  end
end
