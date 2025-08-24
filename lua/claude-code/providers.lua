---@mod claude-code.providers Provider management for cli-agents.nvim
---@brief [[
--- This module provides provider abstraction for multiple AI CLI tools.
--- It handles provider configuration, command building, and instance management.
---@brief ]]

local M = {}

--- Provider configuration templates
--- @table ProviderConfig
--- @field command string Base command for the provider
--- @field default_variants table<string, string|boolean> Default command variants
--- @field env table|nil Environment variables for the provider
--- @field working_directory string|nil Working directory override

M.providers = {
  claude = {
    command = 'claude',
    default_variants = {
      continue = '--continue',
      resume = '--resume',
      verbose = '--verbose',
    },
  },
  gemini = {
    command = 'gemini-cli',
    default_variants = {
      context = '--context',
      stream = '--stream',
      model = '--model=gemini-pro',
    },
  },
  codex = {
    command = 'codex',
    default_variants = {
      complete = '--complete',
      chat = '--chat',
      engine = '--engine=davinci',
    },
  },
}

--- Get provider configuration with user overrides
--- @param provider_name string Provider name
--- @param user_config table|nil User configuration for the provider
--- @return table provider_config Provider configuration
function M.get_provider_config(provider_name, user_config)
  local provider = M.providers[provider_name]
  if not provider then
    error('Unknown provider: ' .. tostring(provider_name))
  end

  local config = vim.deepcopy(provider)

  -- Merge user configuration if provided
  if user_config and user_config[provider_name] then
    config = vim.tbl_deep_extend('force', config, user_config[provider_name])
  end

  return config
end

--- Build command for a specific provider
--- @param provider_name string Provider name
--- @param base_args string|nil Base arguments for the command
--- @param git_config table Git configuration
--- @param user_config table|nil User provider configuration
--- @return string full_command Built command string
function M.build_command(provider_name, base_args, git_config, user_config)
  local provider_config = M.get_provider_config(provider_name, user_config)

  local command = provider_config.command

  -- Add base arguments if provided
  if base_args and base_args ~= '' then
    command = command .. ' ' .. base_args
  end

  -- Handle git root directory if configured
  if git_config and git_config.use_git_root then
    local git_root = require('claude-code.git').get_git_root()
    if git_root then
      local quoted_root = vim.fn.shellescape(git_root)
      local separator = git_config.shell and git_config.shell.separator or '&&'
      local pushd_cmd = git_config.shell and git_config.shell.pushd_cmd or 'pushd'
      local popd_cmd = git_config.shell and git_config.shell.popd_cmd or 'popd'

      command = pushd_cmd
        .. ' '
        .. quoted_root
        .. ' '
        .. separator
        .. ' '
        .. command
        .. ' '
        .. separator
        .. ' '
        .. popd_cmd
    end
  end

  return command
end

--- Get all available provider names
--- @return table<string> provider_names List of provider names
function M.get_available_providers()
  local providers = {}
  for name, _ in pairs(M.providers) do
    table.insert(providers, name)
  end
  return providers
end

--- Validate provider configuration
--- @param provider_config table Provider configuration to validate
--- @return boolean valid True if configuration is valid
--- @return string|nil error_message Error message if invalid
function M.validate_provider_config(provider_config)
  if type(provider_config) ~= 'table' then
    return false, 'Provider config must be a table'
  end

  if type(provider_config.command) ~= 'string' or provider_config.command == '' then
    return false, 'Provider command must be a non-empty string'
  end

  if provider_config.default_variants and type(provider_config.default_variants) ~= 'table' then
    return false, 'Provider default_variants must be a table'
  end

  return true, nil
end

--- Get default provider configuration
--- @return table default_config Default provider configuration
function M.get_default_provider_config()
  return {
    default_provider = 'claude',
    providers = {},
  }
end

return M
