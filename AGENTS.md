# Repository Guidelines

This Neovim plugin integrates Claude/CLI Agents in a terminal buffer with smart file reloads and window controls. Use this guide to contribute changes confidently and consistently.

## Project Structure & Module Organization
- `lua/claude-code/`: Core Lua modules (terminal, window, config, utils).
- `tests/`: Lua specs and runner; primary suite.
- `test/`: Legacy Vimscript tests (`basic_test.vim`, `config_test.vim`).
- `scripts/`: Dev utilities (`test.sh`, `setup-hooks.sh`, version tools).
- `doc/`, `assets/`: Help docs and images. Root configs: `.luacheckrc`, `stylua.toml`, `Makefile`.

## Build, Test, and Development Commands
- `make help`: List common tasks.
- `make test`: Run Plenary tests via `scripts/test.sh` (default).
- `make test-debug`: Verbose diagnostics (env + nvim info).
- `make test-legacy`, `make test-basic`, `make test-config`: Vimscript suites.
- `make lint`: Run Luacheck over `lua/`.
- `make format`: Format with StyLua.
- `make docs`: Generate LDoc into `doc/luadoc/`.
- `scripts/setup-hooks.sh`: Install pre-commit (formats, lints, runs tests).

## Quick Local Usage
- `:CLIAgents`: If no session exists, opens the default provider (`config.providers.default_provider`, e.g., `claude`). If a session exists, re-opens the last-used provider. Example: after `:CLIAgents codex`, subsequent `:CLIAgents` opens `codex`.
- Variants respect the same rule: `:CLIAgentsContinue`, `:CLIAgentsVerbose` use the last-used provider when sessions exist.
- Keymap example: `vim.keymap.set('n', '<leader>cc', '<cmd>CLIAgents<CR>')`.

## Coding Style & Naming Conventions
- Indentation: 2 spaces; max width 100; LF endings (`stylua.toml`).
- Formatting: StyLua; Linting: Luacheck (`.luacheckrc`).
- Naming: `snake_case` for functions/locals; `PascalCase` for classes/constructors; module names mirror paths (e.g., `require('claude-code.window')`).

## Testing Guidelines
- Frameworks: Plenary-based Lua tests (`tests/`) plus legacy Vimscript (`test/`).
- Keep all existing tests green; add tests for new behavior. Place specs under `tests/spec/` with descriptive names.
- Run: `make test` (fast path) or `make test-debug` when diagnosing.

## Commit & Pull Request Guidelines
- Commit style: Conventional Commits (e.g., `feat(terminal): ...`, `fix(window): ...`, `test: ...`, `docs(...): ...`). Check `git log` for examples.
- PRs: clear description, linked issues, behavior before/after, tests updated/added, and docs/examples adjusted (README, `doc/`). Include screenshots/gifs for UI changes (e.g., floating window behavior).

## Security & Configuration Tips
- Neovim: 0.7+ required (dev tooling targets 0.10+; see `DEVELOPMENT.md`).
- Ensure the external CLI command (`command`/`command_variants` in `setup`) is available in `PATH`.
- Prefer enabling `git.use_git_root` to ensure correct working directory behavior.
