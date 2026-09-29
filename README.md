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

Given more time:

- **First-class `Command` objects** instead of `[symbol, args]` tuples — one class per command with a `#apply(robot)` method. Enables the open/closed principle for new commands and makes command-level middleware (logging, undo, dry-run) trivial.
- **Obstacles on the table** — pass a set of blocked cells to `Table` and consult it in `#in_bounds?` (or introduce a distinct `#passable?`).
- **REPL mode** with a prompt and readline history when STDIN is a TTY.
- **Property-based tests** via `rantly` — e.g. "for any random command stream, the robot never reports coordinates outside the table."
- **Rubocop + CI** — check the styleguide on every push (`rubocop` with `rubocop-rspec`), run `rspec` in GitHub Actions.
- **Multi-robot support** with collision detection — a `Board` composing `Table` + a collection of `Robot`s, and a routing layer for identifying which robot each command targets.
- **Pluggable reporters** — a `Reporter` interface with plain-text (current), JSON, and structured-log implementations selected via CLI flag.
- **Structured errors on `--strict`** — today unknown lines are silently skipped (the spec allows it). A `--strict` flag could raise/exit on parse errors, useful for scripted pipelines.
