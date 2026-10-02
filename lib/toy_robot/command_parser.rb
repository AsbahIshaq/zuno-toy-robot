# frozen_string_literal: true

module ToyRobot
  # Turns a raw input line into [command_symbol, args] or nil for
  # blank/unknown/malformed input. Pure — no side effects, no state.
  module CommandParser
    NULLARY = %i[MOVE LEFT RIGHT REPORT QUIT].freeze
    ALIASES = { EXIT: :QUIT }.freeze

    module_function

    def parse(line)
      return nil if line.nil?

      stripped = line.strip
      return nil if stripped.empty?

      command, rest = stripped.split(/\s+/, 2)
      command = command.upcase.to_sym
      command = ALIASES.fetch(command, command)

      return [command, []] if NULLARY.include?(command)
      return parse_place(rest) if command == :PLACE

      nil
    end

    def parse_place(rest)
      return nil if rest.nil?

      parts = rest.split(',').map(&:strip)
      return nil unless parts.size == 3

      x = Integer(parts[0], exception: false)
      y = Integer(parts[1], exception: false)
      facing = Direction.from_name(parts[2].upcase)

      return nil if x.nil? || y.nil? || facing.nil?

      [:PLACE, [x, y, facing]]
    end
  end
end
