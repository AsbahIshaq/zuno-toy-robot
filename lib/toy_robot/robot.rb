module ToyRobot
  # Holds robot state on a Table. Any command issued before a successful
  # PLACE is a silent no-op. Any MOVE that would leave the table is ignored.
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
      return unless facing.is_a?(Direction)
      return unless @table.in_bounds?(x, y)

      @x = x
      @y = y
      @facing = facing
    end

    def move
      return unless placed?

      nx = @x + @facing.dx
      ny = @y + @facing.dy
      return unless @table.in_bounds?(nx, ny)

      @x = nx
      @y = ny
    end

    def left
      return unless placed?

      @facing = @facing.left
    end

    def right
      return unless placed?

      @facing = @facing.right
    end

    def report
      return nil unless placed?

      "#{@x},#{@y},#{@facing.name}"
    end
  end
end
