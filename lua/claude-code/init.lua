---@mod claude-code Claude Code Neovim Integration
---@brief [[
--- A plugin for seamless integration between Claude Code AI assistant and Neovim.
--- This plugin provides a terminal-based interface to Claude Code within Neovim.
---
--- Requirements:
--- - Neovim 0.7.0 or later
--- - Claude Code CLI tool installed and available in PATH
--- - plenary.nvim (dependency for git operations)
---
--- Usage:
--- ```lua
--- require('claude-code').setup({
---   -- Configuration options (optional)
--- })
--- ```
---@brief ]]

-- Import modules
local config = require('claude-code.config')
local commands = require('claude-code.commands')
local keymaps = require('claude-code.keymaps')
local file_refresh = require('claude-code.file_refresh')
local terminal = require('claude-code.terminal')
local git = require('claude-code.git')
local version = require('claude-code.version')

local M = {}

-- Make imported modules available
M.commands = commands

-- Store the current configuration
--- @type table
M.config = {}

-- Track the last used provider in this Neovim session
--- @type string|nil
M.last_used_provider = nil

-- Determine whether any session (terminal buffer) exists
-- @return boolean has_session
local function has_any_session()
  if not M.claude_code or not M.claude_code.instances then
    return false
  end
  for _, bufnr in pairs(M.claude_code.instances) do
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      return true
    end
  end
  return false
end

-- Terminal buffer and window management
--- @type table
M.claude_code = terminal.terminal

--- Force insert mode when entering the Claude Code window
--- This is a public function used in keymaps
function M.force_insert_mode()
  terminal.force_insert_mode(M, M.config)
end

--- Get the current active buffer number
--- @return number|nil bufnr Current Claude instance buffer number or nil
local function get_current_buffer_number()
  -- Get current instance from the instances table
  local current_instance = M.claude_code.current_instance
  if current_instance and type(M.claude_code.instances) == 'table' then
    return M.claude_code.instances[current_instance]
  end
  return nil
end

--- Toggle the Claude Code terminal window
--- This is a public function used by commands
function M.toggle()
  -- If a session exists, prefer the last-used provider; otherwise use default
  local provider = has_any_session() and M.last_used_provider or nil
  terminal.toggle(M, M.config, git, provider)

  -- Set up terminal navigation keymaps after toggling
  local bufnr = get_current_buffer_number()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    keymaps.setup_terminal_navigation(M, M.config)
  end
end

--- Toggle the Claude Code terminal window with a specific command variant
--- @param variant_name string The name of the command variant to use
function M.toggle_with_variant(variant_name)
  if not variant_name or not M.config.command_variants[variant_name] then
    -- If variant doesn't exist, fall back to regular toggle
    return M.toggle()
  end

  -- Store the original command
  local original_command = M.config.command

  -- Set the command with the variant args
  M.config.command = original_command .. ' ' .. M.config.command_variants[variant_name]

  -- Call the toggle function with the modified command
  -- Use last used provider if available when applying a variant
  terminal.toggle(M, M.config, git, M.last_used_provider, variant_name)

  -- Set up terminal navigation keymaps after toggling
  local bufnr = get_current_buffer_number()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    keymaps.setup_terminal_navigation(M, M.config)
  end

  -- Restore the original command
  M.config.command = original_command
end

--- Toggle the Claude Code terminal window with a specific provider
--- @param provider_name string The name of the provider to use
function M.toggle_with_provider(provider_name)
  -- Call the toggle function with the specified provider
  terminal.toggle(M, M.config, git, provider_name)

  -- Remember last used provider for future :CLIAgents calls
  M.last_used_provider = provider_name

  -- Set up terminal navigation keymaps after toggling
  local bufnr = get_current_buffer_number()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    keymaps.setup_terminal_navigation(M, M.config)
  end
end

--- Setup function for the plugin
--- @param user_config? table User configuration table (optional)
function M.setup(user_config)
  -- Parse and validate configuration
  -- Don't use silent mode for regular usage - users should see config errors
  M.config = config.parse_config(user_config, false)

  -- Set up autoread option
  vim.o.autoread = true

  -- Set up file refresh functionality
  file_refresh.setup(M, M.config)

  -- Register commands
  commands.register_commands(M)

  -- Register keymaps
  keymaps.register_keymaps(M, M.config)
end

function M.version()
  version.print_version()
end

return M
