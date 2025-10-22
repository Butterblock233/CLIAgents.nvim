---@mod claude-code.providers Provider management for cli-agents.nvim
---@brief [[
--- This module provides provider abstraction for multiple AI CLI tools.
--- It handles provider configuration, command building, and instance management.
---@brief ]]

local M = {}

--- Provider configuration templates
--- @class ProviderConfig
--- @field command string Base command for the provider
--- @field args table<string> Default command arguments
--- @field args_resume string
--- @field env table|nil Environment variables for the provider
--- @field working_directory string|nil Working directory override
M.providers = {
  -- default providers
  claude = {
    command = 'claude',
    args = {},
    args_resume = '--resume',
  },
  gemini = {
    command = 'gemini',
    args = {},
  },
  codex = {
    command = 'codex',
    args = {},
  },
}

--- Get provider configuration with user overrides
--- @param provider_name string Provider name
--- @param user_config table|nil User configuration for the provider
--- @return table provider_config Provider configuration
function M.get_provider_config(provider_name, user_config)
  -- Basic validation of input
  if not provider_name or provider_name == '' then
    error('Provider name must be a non-empty string')
  end

  local provider = M.providers[provider_name]
  local user_provider = (user_config and user_config[provider_name]) or nil

  -- If provider isn't built-in, allow user-defined providers via setup config
  if not provider and user_provider then
    local cfg = vim.deepcopy(user_provider)
    local ok, msg = M.validate_provider_config(cfg)
    if not ok then
      error('Invalid provider config for ' .. provider_name .. ': ' .. tostring(msg))
    end
    return cfg
  end

  -- If provider still not found, construct a helpful error message
  if not provider then
    local available = {}
    for name, _ in pairs(M.providers) do
      table.insert(available, name)
    end
    if user_config and type(user_config) == 'table' then
      for name, _ in pairs(user_config) do
        if not M.providers[name] then
          table.insert(available, name)
        end
      end
    end
    table.sort(available)
    error(
      ('Unknown provider: %s. Available providers: %s'):format(
        tostring(provider_name),
        table.concat(available, ', ')
      )
    )
  end

  local config = vim.deepcopy(provider)

  -- Merge user configuration if provided
  if user_provider then
    config = vim.tbl_deep_extend('force', config, user_provider)
  end

  -- Validate final configuration
  local ok, msg = M.validate_provider_config(config)
  if not ok then
    error('Invalid provider config for ' .. provider_name .. ': ' .. tostring(msg))
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

  if provider_config.args and type(provider_config.args) ~= 'table' then
    return false, 'Provider args must be a table'
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
