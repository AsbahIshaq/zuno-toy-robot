# frozen_string_literal: true

module ToyRobot
  # Holds robot state on a Table. Any command issued before a successful
  # PLACE is a silent no-op. Any MOVE that would leave the table is ignored.
  # State-changing methods return true when applied, false when ignored —
  # the simulator uses this to surface feedback in interactive mode.
  class Robot
    attr_reader :x, :y, :facing

    def initialize(table)
      @table = table
      @x = nil
      @y = nil
      @facing = nil
    end

    def placed?
      !@facing.nil?
    end

    def place(x, y, facing)
      return false unless facing.is_a?(Direction)
      return false unless @table.in_bounds?(x, y)

      @x = x
      @y = y
      @facing = facing
      true
    end

    def move
      return false unless placed?

      nx = @x + @facing.dx
      ny = @y + @facing.dy
      return false unless @table.in_bounds?(nx, ny)

      @x = nx
      @y = ny
      true
    end

    def left
      return false unless placed?

      @facing = @facing.left
      true
    end

    def right
      return false unless placed?

      @facing = @facing.right
      true
    end

    def report
      return nil unless placed?

      "#{@x},#{@y},#{@facing.name}"
    end
  end
end
