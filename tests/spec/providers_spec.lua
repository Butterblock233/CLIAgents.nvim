-- Tests for provider functionality
local assert = require('luassert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

local providers = require('claude-code.providers')
local config = require('claude-code.config')

describe('provider functionality', function()
  describe('provider validation', function()
    it('should validate provider configuration structure', function()
      -- Valid provider config
      local valid_config = {
        command = 'test-cli',
        default_variants = { test = '--test' },
      }

      local valid, err = providers.validate_provider_config(valid_config)
      assert.is_true(valid)
      assert.is_nil(err)

      -- Invalid: not a table
      local invalid1 = 'not a table'
      valid, err = providers.validate_provider_config(invalid1)
      assert.is_false(valid)
      assert.are.equal('Provider config must be a table', err)

      -- Invalid: empty command
      local invalid2 = { command = '' }
      valid, err = providers.validate_provider_config(invalid2)
      assert.is_false(valid)
      assert.are.equal('Provider command must be a non-empty string', err)

      -- Invalid: command not a string
      local invalid3 = { command = 123 }
      valid, err = providers.validate_provider_config(invalid3)
      assert.is_false(valid)
      assert.are.equal('Provider command must be a non-empty string', err)

      -- Invalid: default_variants not a table
      local invalid4 = { command = 'test', default_variants = 'invalid' }
      valid, err = providers.validate_provider_config(invalid4)
      assert.is_false(valid)
      assert.are.equal('Provider default_variants must be a table', err)
    end)
  end)

  describe('provider configuration', function()
    it('should get default provider configuration', function()
      local default_config = providers.get_default_provider_config()
      assert.are.equal('claude', default_config.default_provider)
      assert.is.table(default_config.providers)
    end)

    it('should get available providers', function()
      local available = providers.get_available_providers()
      assert.is.table(available)
      assert.is_true(#available >= 3) -- claude, gemini, codex
      assert.is_true(vim.tbl_contains(available, 'claude'))
      assert.is_true(vim.tbl_contains(available, 'gemini'))
      assert.is_true(vim.tbl_contains(available, 'codex'))
    end)

    it('should get provider config with user overrides', function()
      local user_config = {
        claude = {
          command = 'custom-claude',
          default_variants = { custom = '--custom' },
        },
      }

      local config = providers.get_provider_config('claude', user_config)
      assert.are.equal('custom-claude', config.command)
      assert.are.equal('--custom', config.default_variants.custom)

      -- Should still have original variants
      assert.are.equal('--continue', config.default_variants.continue)
    end)

    it('should error for unknown provider', function()
      assert.has_error(function()
        providers.get_provider_config('unknown', {})
      end, 'Unknown provider: unknown')
    end)
  end)

  describe('command building', function()
    it('should build basic provider commands', function()
      local cmd = providers.build_command('claude', nil, nil, nil)
      assert.are.equal('claude', cmd)

      cmd = providers.build_command('gemini', nil, nil, nil)
      assert.are.equal('gemini-cli', cmd)
    end)

    it('should build commands with base arguments', function()
      local cmd = providers.build_command('claude', '--verbose', nil, nil)
      assert.are.equal('claude --verbose', cmd)
    end)

    it('should build commands with git integration', function()
      local git_config = {
        use_git_root = true,
        shell = {
          separator = '&&',
          pushd_cmd = 'pushd',
          popd_cmd = 'popd',
        },
      }

      -- Mock git root function
      local git = require('claude-code.git')
      local original_get_git_root = git.get_git_root
      git.get_git_root = function()
        return '/test/path'
      end

      local cmd = providers.build_command('claude', nil, git_config, nil)
      assert.are.equal("pushd '/test/path' && claude && popd", cmd)

      -- Restore original function
      git.get_git_root = original_get_git_root
    end)

    it('should build commands with user provider config', function()
      local user_config = {
        claude = {
          command = 'custom-claude',
        },
      }

      local cmd = providers.build_command('claude', '--test', nil, user_config)
      assert.are.equal('custom-claude --test', cmd)
    end)
  end)
end)
