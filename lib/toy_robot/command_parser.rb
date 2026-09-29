module ToyRobot
  # Turns a raw input line into [command_symbol, args] or nil for
  # blank/unknown/malformed input. Pure — no side effects, no state.
  module CommandParser
    NULLARY = %i[MOVE LEFT RIGHT REPORT].freeze
    PLACE_PATTERN = /\A\s*PLACE\s+(-?\d+)\s*,\s*(-?\d+)\s*,\s*([A-Z]+)\s*\z/i.freeze

    module_function

    def parse(line)
      return nil if line.nil?

      stripped = line.strip
      return nil if stripped.empty?

      if (match = stripped.match(PLACE_PATTERN))
        parse_place(match)
      else
        command = stripped.upcase.to_sym
        NULLARY.include?(command) ? [command, []] : nil
      end
    end

    def parse_place(match)
      x = Integer(match[1])
      y = Integer(match[2])
      facing = Direction.from_name(match[3].upcase)
      return nil if facing.nil?

      [:PLACE, [x, y, facing]]
    end
  end
end
