# frozen_string_literal: true

module ToyRobot
  class Table
    attr_reader :width, :height

    def initialize(width: 5, height: 5)
      raise ArgumentError, 'dimensions must be positive' if width <= 0 || height <= 0

      @width = width
      @height = height
      freeze
    end

    def in_bounds?(x, y)
      x.between?(0, width - 1) && y.between?(0, height - 1)
    end
  end
end
