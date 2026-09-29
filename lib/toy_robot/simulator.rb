module ToyRobot
  # Reads commands from `input`, dispatches them to a Robot, and writes
  # REPORT results to `output`. Input/output are injected so tests can
  # substitute StringIO — no shelling out required.
  class Simulator
    def initialize(input:, output:, table: Table.new)
      @input = input
      @output = output
      @robot = Robot.new(table)
    end

    def run
      @input.each_line do |line|
        command = CommandParser.parse(line)
        next if command.nil?

        dispatch(*command)
      end
    end

    private

    def dispatch(name, args)
      case name
      when :PLACE  then @robot.place(*args)
      when :MOVE   then @robot.move
      when :LEFT   then @robot.left
      when :RIGHT  then @robot.right
      when :REPORT then emit_report
      end
    end

    def emit_report
      report = @robot.report
      @output.puts(report) unless report.nil?
    end
  end
end
