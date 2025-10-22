# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Project: CLIAgents.nvim

## Overview

CLIAgents.nvim is a Neovim plugin that integrates multiple AI CLI tools (Claude Code, Gemini CLI, Codex) into Neovim. It provides terminal-based interfaces with smart file reloading, window management, and git-aware working directory handling.

## Essential Commands

### Development Tasks (using Just)
- Run all tests: `just test` or `make test`
- Run tests with debug output: `just test-debug`
- Run legacy Vimscript tests: `just test-legacy`
- Run specific test suites: `just test-basic` or `just test-config`
- Lint Lua files: `just lint` or `make lint`
- Format Lua files: `just format` or `make format`
- Generate documentation: `just docs` or `make docs`
- Install pre-commit hooks: `just hooks` or `./scripts/setup-hooks.sh`

### Testing Framework
- Primary test suite uses Plenary.nvim (`tests/spec/`)
- Legacy Vimscript tests in `test/` directory
- Tests run via `scripts/test.sh` with 60-second timeout
- Test runner automatically handles NVIM environment variable detection

## Project Structure

### Core Modules
- `lua/claude-code/init.lua`: Main plugin entry point and public API
- `lua/claude-code/config.lua`: Configuration parsing and validation
- `lua/claude-code/terminal.lua`: Terminal buffer and window management
- `lua/claude-code/providers.lua`: Multi-provider abstraction (Claude, Gemini, Codex)
- `lua/claude-code/commands.lua`: Vim command registration
- `lua/claude-code/keymaps.lua`: Keymap management
- `lua/claude-code/file_refresh.lua`: File change detection and auto-reload
- `lua/claude-code/git.lua`: Git repository detection and operations
- `lua/claude-code/version.lua`: Version management

### Testing
- `tests/spec/`: Plenary-based Lua test specifications
- `test/`: Legacy Vimscript test files
- `tests/run_tests.lua`: Main test runner
- `scripts/test.sh`: Test execution script

### Development
- `Justfile`: Task runner configuration (preferred over Makefile)
- `scripts/`: Development utilities and hooks
- `doc/`: Generated documentation

## Architecture Overview

### Multi-Provider System
- **Provider Abstraction**: Supports multiple AI CLI tools (Claude, Gemini, Codex) through `providers.lua`
- **Command Building**: Dynamic command construction with git-aware working directories
- **Session Management**: Tracks last-used provider and maintains session state
- **Configuration**: Provider-specific settings with validation

### Core Architecture
- **Terminal Management**: Creates and manages terminal buffers with customizable window positioning
- **File Refresh**: Automatic detection and reloading of files modified by CLI agents
- **Git Integration**: Automatic working directory setting to git root
- **Command Variants**: Support for different command modes (continue, resume, verbose)

### Key Design Patterns
- **Modular Design**: Each component is isolated and testable
- **Configuration Validation**: Strong typing and validation for user configuration
- **Session Persistence**: Remembers last-used provider across Neovim sessions
- **Error Handling**: Comprehensive error handling with user-friendly messages

## Development Guidelines

### Coding Standards
- Use 2-space indentation, 100-character line width
- Follow LuaCATS annotations for type documentation
- Use snake_case for functions/locals, PascalCase for constructors
- Format with StyLua, lint with Luacheck

### Testing Strategy
- Write tests for new functionality in `tests/spec/`
- Use Plenary test framework for Lua tests
- Maintain legacy Vimscript tests in `test/`
- Run `just test` before committing

### Configuration
- All user configuration goes through `config.lua`
- Validate all user input with helpful error messages
- Support both default and custom provider configurations
