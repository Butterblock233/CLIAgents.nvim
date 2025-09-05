# Claude Code dev tasks (Makefile -> Justfile)

# Ensure POSIX shell semantics for recipes
set shell := ["bash", "-c"]

# Defaults (adjust if needed)
LUA_PATH := 'lua/'
TEST_PATH := 'test/'
DOC_PATH := 'doc/'

# Default invocation (`just`) runs tests, matching Makefile's first target.
test:
  @echo "Running Plenary tests (Nushell)..."
  nu scripts/test.nu

test-debug:
  @echo "Running tests in debug mode (Nushell)..."
  nu scripts/test.nu --debug

test-legacy:
  @echo "Running legacy tests..."
  nvim --headless --noplugin -u {{TEST_PATH}}minimal.vim -c "lua print('Running basic tests')" -c "source {{TEST_PATH}}basic_test.vim" -c "qa!"
  nvim --headless --noplugin -u {{TEST_PATH}}minimal.vim -c "lua print('Running config tests')" -c "source {{TEST_PATH}}config_test.vim" -c "qa!"

test-basic:
  @echo "Running basic tests..."
  nvim --headless --noplugin -u {{TEST_PATH}}minimal.vim -c "source {{TEST_PATH}}basic_test.vim" -c "qa!"

test-config:
  @echo "Running config tests..."
  nvim --headless --noplugin -u {{TEST_PATH}}minimal.vim -c "source {{TEST_PATH}}config_test.vim" -c "qa!"

lint:
  @echo "Linting Lua files..."
  luacheck {{LUA_PATH}}

format:
  @echo "Formatting Lua files..."
  stylua {{LUA_PATH}}

docs:
  @echo "Generating documentation..."
  @if command -v ldoc > /dev/null 2>&1; then ldoc {{LUA_PATH}} -d {{DOC_PATH}}luadoc -c .ldoc.cfg || true; else echo "ldoc not installed. Skipping documentation generation."; fi

clean:
  @echo "Cleaning generated files..."
  rm -rf {{DOC_PATH}}luadoc

# Aggregate similar to `make all`
all: lint format test docs
  @# Run lint, format, tests, then docs

help:
  @echo "Claude Code development commands:"
  @echo "  just test         - Run all tests (using Plenary test framework)"
  @echo "  just test-debug   - Run all tests with debug output"
  @echo "  just test-legacy  - Run legacy tests (VimL-based)"
  @echo "  just test-basic   - Run only basic functionality tests (legacy)"
  @echo "  just test-config  - Run only configuration tests (legacy)"
  @echo "  just lint         - Lint Lua files"
  @echo "  just format       - Format Lua files with stylua"
  @echo "  just docs         - Generate documentation"
  @echo "  just clean        - Remove generated files"
  @echo "  just all          - Run lint, format, test, and docs"
