# frozen_string_literal: true

module ToyRobot
  class Direction
    attr_reader :name, :dx, :dy

    def initialize(name, dx, dy)
      @name = name
      @dx = dx
      @dy = dy
      freeze
    end

    # Clockwise cycle. RIGHT advances one step; LEFT retreats one step.
    ORDER = %i[NORTH EAST SOUTH WEST].freeze

    NORTH = new(:NORTH,  0,  1)
    EAST  = new(:EAST,   1,  0)
    SOUTH = new(:SOUTH,  0, -1)
    WEST  = new(:WEST,  -1, 0)

    ALL = [NORTH, EAST, SOUTH, WEST].freeze
    BY_NAME = ALL.to_h { |d| [d.name, d] }.freeze

    def self.from_name(name)
      BY_NAME[name.to_sym]
    end

    def right
      ALL[(ORDER.index(name) + 1) % ALL.size]
    end

    def left
      ALL[(ORDER.index(name) - 1) % ALL.size]
    end

    def to_s
      name.to_s
    end
  end
end
