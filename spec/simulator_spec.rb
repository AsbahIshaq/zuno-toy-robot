# frozen_string_literal: true

require 'stringio'
require 'shellwords'
require 'rbconfig'

RSpec.describe ToyRobot::Simulator do
  def run(commands, **opts)
    output = StringIO.new
    described_class.new(input: StringIO.new(commands), output: output, **opts).run
    output.string
  end

  describe 'PDF scenarios' do
    it 'Scenario A — basic movement' do
      expect(run(<<~CMDS)).to eq("0,1,NORTH\n")
        PLACE 0,0,NORTH
        MOVE
        REPORT
      CMDS
    end

    it 'Scenario B — rotation' do
      expect(run(<<~CMDS)).to eq("0,0,WEST\n")
        PLACE 0,0,NORTH
        LEFT
        REPORT
      CMDS
    end

    it 'Scenario C — complex sequence' do
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

  describe 'invariants' do
    it 'discards all commands before the first valid PLACE' do
      output = run(<<~CMDS)
        MOVE
        LEFT
        REPORT
        PLACE 1,1,SOUTH
        REPORT
      CMDS
      expect(output).to eq("*ignored*\n*ignored*\n*ignored*\n1,1,SOUTH\n")
    end

    it 'discards a PLACE that would put the robot off the table' do
      output = run(<<~CMDS)
        PLACE 9,9,NORTH
        REPORT
        PLACE 2,2,EAST
        REPORT
      CMDS
      expect(output).to eq("*ignored*\n*ignored*\n2,2,EAST\n")
    end

    it 'ignores unknown lines but stays silent on blank lines' do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH

        HOP
        MOVE
        REPORT
      CMDS
      expect(output).to eq("*ignored*\n0,1,NORTH\n")
    end

    it 'supports re-placement mid-sequence' do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH
        MOVE
        PLACE 4,4,SOUTH
        MOVE
        REPORT
      CMDS
      expect(output).to eq("4,3,SOUTH\n")
    end

    it 'emits one line per REPORT' do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH
        REPORT
        MOVE
        REPORT
      CMDS
      expect(output).to eq("0,0,NORTH\n0,1,NORTH\n")
    end

    it 'stops processing on QUIT' do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH
        REPORT
        QUIT
        MOVE
        REPORT
      CMDS
      expect(output).to eq("0,0,NORTH\n")
    end

    it 'treats EXIT as QUIT' do
      output = run(<<~CMDS)
        PLACE 0,0,NORTH
        REPORT
        EXIT
        MOVE
        REPORT
      CMDS
      expect(output).to eq("0,0,NORTH\n")
    end
  end

  describe 'interactive mode' do
    it 'writes the prompt before each read' do
      output = run("PLACE 0,0,NORTH\nREPORT\nQUIT\n", prompt: '> ')
      expect(output).to eq("> > 0,0,NORTH\n> ")
    end

    it 'does not write a prompt when prompt is nil' do
      output = run("PLACE 0,0,NORTH\nREPORT\n")
      expect(output).to eq("0,0,NORTH\n")
    end

    it "writes '*ignored*' when the parser rejects a line" do
      output = run("PLACE 2,3,RIGHT\nJUMP\nQUIT\n", prompt: '> ')
      expect(output).to eq("> *ignored*\n> *ignored*\n> ")
    end

    it "writes '*ignored*' when the robot rejects a command" do
      output = run("MOVE\nPLACE 9,9,NORTH\nQUIT\n", prompt: '> ')
      expect(output).to eq("> *ignored*\n> *ignored*\n> ")
    end

    it "writes '*ignored*' when REPORT runs before PLACE" do
      output = run("REPORT\nQUIT\n", prompt: '> ')
      expect(output).to eq("> *ignored*\n> ")
    end

    it 'is silent on blank lines' do
      output = run("\n   \nPLACE 0,0,NORTH\nREPORT\nQUIT\n", prompt: '> ')
      expect(output).to eq("> > > > 0,0,NORTH\n> ")
    end

    it "writes '*ignored*' in non-interactive mode too" do
      output = run("MOVE\nJUMP\nPLACE 0,0,NORTH\nREPORT\n")
      expect(output).to eq("*ignored*\n*ignored*\n0,0,NORTH\n")
    end
  end

  describe 'CLI smoke test' do
    let(:root) { File.expand_path('..', __dir__) }
    let(:bin) { File.join(root, 'bin', 'toy_robot') }

    it 'runs scenario C from a file argument' do
      fixture = File.join(root, 'spec', 'fixtures', 'scenario_c.txt')
      output = `#{RbConfig.ruby} #{bin.shellescape} #{fixture.shellescape}`
      expect(output).to eq("3,3,NORTH\n")
    end

    it 'runs scenario A from STDIN' do
      output = IO.popen([RbConfig.ruby, bin], 'r+') do |io|
        io.write("PLACE 0,0,NORTH\nMOVE\nREPORT\n")
        io.close_write
        io.read
      end
      expect(output).to eq("0,1,NORTH\n")
    end
  end
end
