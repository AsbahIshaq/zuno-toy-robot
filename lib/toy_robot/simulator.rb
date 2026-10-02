# frozen_string_literal: true

module ToyRobot
  # Reads commands from `input`, dispatches them to a Robot, and writes
  # REPORT results to `output`. Input/output are injected so tests can
  # substitute StringIO — no shelling out required.
  #
  # When `prompt:` is set (interactive mode), a prompt is written before
  # each read. Any command the parser or robot rejects is echoed back
  # as `*ignored*` so users can see which commands had no effect.
  class Simulator
    def initialize(input:, output:, table: Table.new, prompt: nil)
      @input = input
      @output = output
      @robot = Robot.new(table)
      @prompt = prompt
    end

    def run
      loop do
        write_prompt
        line = @input.gets
        break if line.nil?
        next if line.strip.empty?

        command = CommandParser.parse(line)
        if command.nil?
          notify_ignored
          next
        end

        break if command.first == :QUIT

        notify_ignored unless dispatch(*command)
      end
    end

    private

    def write_prompt
      return if @prompt.nil?

      @output.print(@prompt)
      @output.flush
    end

    def notify_ignored
      @output.puts('*ignored*')
    end

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
      return false if report.nil?

      @output.puts(report)
      true
    end
  end
end
