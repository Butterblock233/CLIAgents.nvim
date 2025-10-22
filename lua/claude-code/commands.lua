---@mod claude-code.commands Command registration for claude-code.nvim
---@brief [[
--- This module provides command registration and handling for claude-code.nvim.
--- It defines user commands and command handlers.
---@brief ]]

local M = {}

--- @type table<string, function> List of available commands and their handlers
M.commands = {}

--- Register commands for the claude-code plugin
--- @param claude_code table The main plugin module
function M.register_commands(claude_code)
  -- Create the user command for toggling CLI Agents
  vim.api.nvim_create_user_command('CLIAgents', function(opts)
    if opts.args and opts.args ~= '' then
      claude_code.toggle_with_provider(opts.args)
    else
      claude_code.toggle()
    end
  end, { desc = 'Toggle CLI Agents terminal', nargs = '?' })

  -- Create commands for each command variant
  for variant_name, variant_args in pairs(claude_code.config.command_variants) do
    if variant_args ~= false then
      -- Convert variant name to PascalCase for command name (e.g., "continue" -> "Continue")
      local capitalized_name = variant_name:gsub('^%l', string.upper)
      local cmd_name = 'CLIAgents' .. capitalized_name

      vim.api.nvim_create_user_command(cmd_name, function()
        claude_code.toggle_with_variant(variant_name)
      end, { desc = 'Toggle CLI Agents terminal with ' .. variant_name .. ' option' })
    end
  end

  -- -- Add version command
  -- vim.api.nvim_create_user_command('CLIAgentsVersion', function()
  --   vim.notify('CLI Agents version: ' .. claude_code.version(), vim.log.levels.INFO)
  -- end, { desc = 'Display CLI Agents version' })

  vim.api.nvim_create_user_command('CLIAgentsVersion', function()
    local version = require('claude-code.version')
    vim.notify('CLIAgents version: ' .. version.string(), vim.log.levels.INFO)
  end, { desc = 'Display CLI Agents version' })

  -- Resume command
  vim.api.nvim_create_user_command('CLIAgentsResume', function(opts)
    local providers = require('claude-code.providers')

    local provider_name
    if opts.args and opts.args ~= '' then
      provider_name = opts.args
      -- Set the last used provider so that toggle_with_variant uses it
      claude_code.last_used_provider = provider_name
    else
      provider_name = claude_code.last_used_provider
        or claude_code.config.providers.default_provider
    end

    local provider_config =
      providers.get_provider_config(provider_name, claude_code.config.providers.providers)

    -- Use provider-specific resume arg if it exists, otherwise fall back to the generic one.
    local resume_arg = provider_config.args_resume or claude_code.config.command_variants.resume

    if resume_arg and resume_arg ~= '' then
      -- Temporarily override the resume variant to pass the correct argument
      local original_resume_arg = claude_code.config.command_variants.resume
      claude_code.config.command_variants.resume = resume_arg
      claude_code.toggle_with_variant('resume')
      claude_code.config.command_variants.resume = original_resume_arg -- Restore variant
    else
      vim.notify('Resume is not supported for provider: ' .. provider_name, vim.log.levels.WARN)
    end
  end, { desc = 'Resume conversation with a provider', force = true, nargs = '?' })
end

return M
