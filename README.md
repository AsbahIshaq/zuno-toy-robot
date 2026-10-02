# Toy Robot Simulator

A Ruby implementation of the [Zuno Tech](https://zuno.tech) toy-robot take-home exercise: a robot roams a 5×5 tabletop under a small command language, and is prevented from falling off the edge.

## Requirements

- Ruby **3.2.2** (see `.ruby-version` — works with any 3.2.x)
- Bundler

## Setup

```sh
bundle install
```

## Usage

The CLI accepts commands from either a file path or standard input.

**From a file:**

```sh
bundle exec bin/toy_robot spec/fixtures/scenario_c.txt
# => 3,3,NORTH
```

**From STDIN:**

```sh
printf "PLACE 0,0,NORTH\nMOVE\nREPORT\n" | bundle exec bin/toy_robot
# => 0,1,NORTH
```

### Command language

| Command | Behaviour |
| --- | --- |
| `PLACE X,Y,F` | Position the robot at `(X, Y)` facing `NORTH`, `SOUTH`, `EAST`, or `WEST`. Origin `(0,0)` is the south-west corner. |
| `MOVE` | Advance one unit in the current facing. |
| `LEFT` | Rotate 90° counter-clockwise. |
| `RIGHT` | Rotate 90° clockwise. |
| `REPORT` | Print `X,Y,FACING`. |

Any command issued before the first successful `PLACE` is silently discarded. Any `MOVE` (or initial `PLACE`) that would put the robot off the table is ignored, and subsequent commands continue as normal.

## Tests

```sh
bundle exec rspec
```

The suite covers each class in isolation plus integration tests that re-run the three example scenarios from the assessment PDF end-to-end, and CLI smoke tests that invoke `bin/toy_robot` via file and STDIN.

## Approach

The problem breaks cleanly into five small collaborators, each with a single responsibility:

- **`Direction`** — a frozen value object per compass point, holding its name and unit-vector `(dx, dy)`. Rotation is expressed as modular index arithmetic over a fixed clockwise cycle `[N, E, S, W]`, so `#right` and `#left` are one line each with no case statements.
- **`Table`** — an explicit boundary object with an `#in_bounds?(x, y)` predicate. The 5×5 dimension is a parameter rather than a magic number, so `Robot` can be exercised against smaller tables in tests and future features (e.g. custom board sizes) don't require rewrites.
- **`Robot`** — owns position, facing, and a reference to the `Table`. It is the single place that enforces "ignore invalid moves": both `#place` and `#move` consult the table and no-op on rejection; `#left`, `#right`, `#move`, and `#report` all no-op before the first successful `PLACE`.
- **`CommandParser`** — a pure module that converts a raw input line into `[name_symbol, args]` or `nil`. Malformed input, unknown commands, blank lines, and invalid facings all collapse to `nil` and are silently skipped by the simulator. Parsing is separated from execution so both are trivially unit-testable.
- **`Simulator`** — the small orchestrator: it iterates over input lines, parses each, and dispatches to the robot. Input and output are injected (`input:`, `output:`) so tests substitute `StringIO` and never shell out.

Two design choices worth calling out:

1. **The "ignore invalid" invariant lives in `Robot`, not in the parser.** A syntactically valid `PLACE 9,9,NORTH` produces a well-formed command; the robot then rejects the placement because the table says so. This keeps parsing concerned only with lexical validity and keeps game rules in one place.
2. **Immutable `Direction` value objects.** Rotation returns *another* direction rather than mutating; the four instances are frozen singletons. This makes the direction algebra safe to share and cheap to reason about.

## Future Improvements

With more time, the following enhancements would be worth considering.

**Command history in interactive mode.** The prompt currently reads raw input one line at a time, so pressing the up arrow does nothing useful. Integrating Ruby's standard `readline` library would allow users to recall and edit previous commands, and optionally persist history between sessions.

**Friendlier error messages.** Passing a non-existent file as an argument currently produces a raw Ruby stacktrace. A clear message such as `Error: file not found: <path>` written to stderr, followed by a non-zero exit code, would be more appropriate for a command-line tool.

**One class per command.** The parser currently returns a tuple of the form `[name, args]`, which the simulator unpacks with a case statement. Promoting each command to its own small class with an `apply(robot)` method would remove the case statement and allow new commands to be added without touching the simulator. It would also make it straightforward to layer in cross-cutting features such as logging, dry-run mode, or an undo stack.

**Obstacles on the table.** The specification states that the table has no obstructions, but the design is prepared for them. The `Table` object already owns all bounds-related questions, so a set of blocked cells could be passed in and consulted alongside the edge check without any changes elsewhere.

**Multi-robot support.** A `Board` object holding a `Table` and a collection of robots, with each command targeting a specific robot by identifier, would support simulations with more than one actor. Collision detection would then live on the board, keeping each individual robot unaware of its peers.

**Alternative output formats.** The current `REPORT` output is a comma-separated string written to standard output. A pluggable reporter abstraction would allow the same simulation to emit JSON for machine consumption, structured logs for observability platforms, or a visual grid for debugging — selectable at the command line.

**Property-based testing.** The current RSpec suite exercises specific cases exhaustively. A property-based testing library such as `rantly` would allow invariants to be asserted over randomly generated command streams — for example, that the robot's reported position is always within the table, regardless of the input.

**Continuous integration.** A GitHub Actions workflow running `rspec` and `rubocop` on every push would catch regressions before they land. Running the suite across a small matrix of Ruby versions (3.2, 3.3, 3.4) would also catch version-specific issues early.

**Strict mode.** Malformed commands are currently tolerated — they produce `*ignored*` output and the simulator continues. A `--strict` flag that exits with a non-zero status on the first invalid line would be more appropriate when the simulator is being driven programmatically by another script or test harness.
