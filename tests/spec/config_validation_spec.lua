-- Tests for the config validation
local assert = require('luassert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

local config = require('claude-code.config')

describe('config validation', function()
  -- Tests for each config section
  describe('window validation', function()
    it('should validate window.position must be a string', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.window.position = 123 -- Not a string

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.window.position, result.window.position)
    end)

    it('should validate window.enter_insert must be a boolean', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.window.enter_insert = 'true' -- String instead of boolean

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.window.enter_insert, result.window.enter_insert)
    end)

    it('should validate window.hide_numbers must be a boolean', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.window.hide_numbers = 1 -- Number instead of boolean

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.window.hide_numbers, result.window.hide_numbers)
    end)

    it('should validate float configuration when position is float', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.window.position = 'float'
      invalid_config.window.float = 'invalid' -- Should be a table

      local result = config.parse_config(invalid_config, true) -- silent mode
      -- When validation fails, should return default config
      assert.are.equal(config.default_config.window.position, result.window.position)
      -- Ensure invalid float config doesn't bleed through
      assert.is.table(result.window.float)
      assert.are.equal(config.default_config.window.float.border, result.window.float.border)
    end)

    it('should validate float.width can be a number or percentage string', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.window.position = 'float'
      invalid_config.window.float = {
        width = true, -- Invalid - boolean
        height = 20,
        relative = 'editor',
      }

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.window.position, result.window.position)
    end)

    it('should validate float.relative must be "editor" or "cursor"', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.window.position = 'float'
      invalid_config.window.float = {
        width = 80,
        height = 20,
        relative = 'window', -- Invalid option
      }

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.window.position, result.window.position)
    end)

    it('should validate float.border must be a valid border style', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.window.position = 'float'
      invalid_config.window.float = {
        width = 80,
        height = 20,
        relative = 'editor',
        border = 'invalid', -- Invalid border style
      }

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.window.position, result.window.position)
      -- Ensure invalid border doesn't bleed through
      assert.are.not_equal('invalid', result.window.float.border)
      assert.are.equal(config.default_config.window.float.border, result.window.float.border)
    end)
  end)

  describe('refresh validation', function()
    it('should validate refresh.enable must be a boolean', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.refresh.enable = 'yes' -- String instead of boolean

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.refresh.enable, result.refresh.enable)
    end)

    it('should validate refresh.updatetime must be a positive number', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.refresh.updatetime = -100 -- Negative number

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.refresh.updatetime, result.refresh.updatetime)
    end)

    it('should validate refresh.timer_interval must be a positive number', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.refresh.timer_interval = 0 -- Zero is not positive

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.refresh.timer_interval, result.refresh.timer_interval)
    end)
  end)

  describe('git validation', function()
    it('should validate git.use_git_root must be a boolean', function()
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.git.use_git_root = 'yes' -- String instead of boolean

      local result = config.parse_config(invalid_config, true) -- silent mode
      assert.are.equal(config.default_config.git.use_git_root, result.git.use_git_root)
    end)
  end)

  describe('keymaps validation', function()
    it('should validate keymaps.toggle.normal can be a string or false', function()
      -- Valid cases
      local valid_config1 = vim.deepcopy(config.default_config)
      valid_config1.keymaps.toggle.normal = '<leader>cc'

      local valid_config2 = vim.deepcopy(config.default_config)
      valid_config2.keymaps.toggle.normal = false

      -- Invalid case
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.keymaps.toggle.normal = 123

      local result1 = config.parse_config(valid_config1, true) -- silent mode
      local result2 = config.parse_config(valid_config2, true) -- silent mode
      local result3 = config.parse_config(invalid_config, true) -- silent mode

      assert.are.equal('<leader>cc', result1.keymaps.toggle.normal)
      assert.are.equal(false, result2.keymaps.toggle.normal)
      assert.are.equal(config.default_config.keymaps.toggle.normal, result3.keymaps.toggle.normal)
    end)

    it('should validate keymaps.window_navigation must be a boolean', function()
      -- Simplify this test to match others
      local invalid_config = vim.deepcopy(config.default_config)
      invalid_config.keymaps.window_navigation = 'enabled' -- String instead of boolean

      -- Use silent mode to avoid pollution
      local result = config.parse_config(invalid_config, true)

      assert.are.equal(
        config.default_config.keymaps.window_navigation,
        result.keymaps.window_navigation
      )
    end)
  end)

  describe('provider validation', function()
    it('should validate provider configuration', function()
      -- Valid provider config
      local valid_config = vim.deepcopy(config.default_config)
      valid_config.providers = {
        default_provider = 'claude',
        providers = {
          claude = {
            command = 'custom-claude',
            default_variants = { test = '--test' },
          },
        },
      }

      local result = config.parse_config(valid_config, true)
      assert.are.equal('custom-claude', result.providers.providers.claude.command)

      -- Invalid: default_provider not a string
      local invalid1 = vim.deepcopy(config.default_config)
      invalid1.providers.default_provider = 123

      local result1 = config.parse_config(invalid1, true)
      assert.are.equal(
        config.default_config.providers.default_provider,
        result1.providers.default_provider
      )

      -- Invalid: providers not a table
      local invalid2 = vim.deepcopy(config.default_config)
      invalid2.providers.providers = 'invalid'

      local result2 = config.parse_config(invalid2, true)
      assert.is.table(result2.providers.providers)
    end)

    it('should maintain backward compatibility with command field', function()
      -- Config with only old command field (should work)
      local old_config = vim.deepcopy(config.default_config)
      old_config.command = 'old-claude'
      old_config.command_variants = { test = '--test' }
      -- Remove providers to test fallback
      old_config.providers = nil

      local result = config.parse_config(old_config, true)
      assert.are.equal('old-claude', result.command)
      assert.are.equal('--test', result.command_variants.test)
      -- Should also have default providers config
      assert.is.table(result.providers)
      assert.are.equal('claude', result.providers.default_provider)
    end)

    it('should prefer providers over deprecated command fields', function()
      -- Config with both old and new fields (should prefer providers)
      local mixed_config = vim.deepcopy(config.default_config)
      mixed_config.command = 'old-claude'
      mixed_config.providers.default_provider = 'gemini'
      mixed_config.providers.providers = {
        gemini = { command = 'new-gemini' },
      }

      local result = config.parse_config(mixed_config, true)
      -- Should use providers config
      assert.are.equal('gemini', result.providers.default_provider)
      assert.are.equal('new-gemini', result.providers.providers.gemini.command)
      -- Old command should still be preserved for compatibility
      assert.are.equal('old-claude', result.command)
    end)
  end)
end)
