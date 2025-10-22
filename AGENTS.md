# Repository Guidelines

Project: CLIAgents.nvim (forked from Claude-code.nvim)

This Neovim plugin integrates Claude/CLI agents in a terminal buffer with smart reloads and window controls. Use this guide to contribute consistently and confidently.

## Project Structure & Module Organization
- `lua/claude-code/`: Core Lua modules (terminal, window, config, utils).
- `tests/`: Plenary specs and runner; primary suite.
- `test/`: Legacy Vimscript tests (`basic_test.vim`, `config_test.vim`).
- `scripts/`: Dev utilities (`test.sh`, `setup-hooks.sh`, version tools).
- `doc/`, `assets/`: Help docs and images. Root: `.luacheckrc`, `stylua.toml`, `Makefile`.

## Build, Test, and Development Commands
Prefer using `just` recipes; fall back to `make` if needed.
- `just -l`: List available tasks.
- `just test` (or `make test`): Run Plenary tests via `scripts/test.sh`.
- `just test-debug` (or `make test-debug`): Verbose diagnostics.
- `just test-legacy` / `test-basic` / `test-config` (or `make ...`): Vimscript suites.
- `just lint` / `just format` (or `make lint` / `make format`): Luacheck + StyLua.
- `just docs` (or `make docs`): Generate LDoc into `doc/luadoc/`.
- `just hooks` or run `scripts/setup-hooks.sh`: Install pre-commit hooks.

## Coding Style & Naming Conventions
- Indent 2 spaces; max width 100; LF endings.
- Format with StyLua; lint with Luacheck.
- Names: `snake_case` for functions/locals; `PascalCase` for constructors; modules mirror paths (e.g., `require('claude-code.window')`).

## Testing Guidelines
- Frameworks: Plenary Lua tests (`tests/`) plus legacy Vimscript (`test/`).
- Keep tests green; add specs for new behavior under `tests/spec/` (e.g., `terminal_spec.lua`).
- Run fast path with `make test`; use `make test-debug` for diagnosis.

## Commit & Pull Request Guidelines
- Conventional Commits (see `git log`): `feat(terminal): ...`, `fix(window): ...`, `test: ...`, `docs(...): ...`.
- PRs: clear description, linked issues, before/after behavior, updated/added tests, and docs/examples. Include screenshots/gifs for UI changes (e.g., floating window behavior).

## Security & Configuration Tips
- Neovim 0.7+ required (dev tooling targets 0.10+).
- Ensure the external CLI (`command`/`command_variants` in `setup`) is in `PATH`.
- Prefer enabling `git.use_git_root` to ensure correct working directory behavior.
- Quick usage tip: `:CLIAgents` re-opens the last-used provider; example map: `vim.keymap.set('n', '<leader>cc', '<cmd>CLIAgents<CR>')`.
