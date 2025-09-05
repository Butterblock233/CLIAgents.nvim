# Nushell port of scripts/test.sh
# - Runs Plenary tests with optional debug output
# - Installs plenary.nvim if missing
# - Uses GNU timeout when available (otherwise runs without a timeout)

# Discover repo root by walking up from the current directory
def find_repo_root [] {
  mut dir = (pwd)
  mut i = 0
  while $i < 15 {
    let has_lua = ([$dir, 'lua'] | path join | path exists)
    let has_tests = ([$dir, 'tests'] | path join | path exists)
    if $has_lua and $has_tests {
      return $dir
    }
    let parent = ($dir | path dirname)
    if $parent == $dir { break }
    $dir = $parent
    $i = $i + 1
  }
  # Fallback to one level up if invoked from scripts/
  let maybe_parent = ((pwd) | path dirname)
  if ([$maybe_parent, 'lua'] | path join | path exists) and ([$maybe_parent, 'tests'] | path join | path exists) {
    return $maybe_parent
  }
  # As a last resort, use current directory
  return (pwd)
}

def main [--debug] {
  let plugin_dir = (find_repo_root)

  print $"Changing to plugin directory: ($plugin_dir)"
  cd $plugin_dir
  print $"Running tests from: (pwd)"

  # Resolve nvim: find on PATH
  let nvim = (try { which nvim | get 0.path } catch { null })
  if $nvim == null {
    print "Error: nvim not found in PATH"
    exit 1
  }

  print $"Running tests with ($nvim)"

  # Ensure plenary.nvim is available
  let plenary_dir = ("~/.local/share/nvim/site/pack/vendor/start/plenary.nvim" | path expand)
  if not ($plenary_dir | path exists) {
    print $"Plenary.nvim not found at ($plenary_dir)"
    print "Installing plenary.nvim..."
    let parent = ($plenary_dir | path dirname)
    mkdir $parent
    ^git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $plenary_dir
  }

  # Debug info
  if $debug {
    let path_sep = (char path_sep)
    print $"Path: ( $env.PATH | default [] | str join $path_sep )"
    print $"LUA_PATH: ( $env.LUA_PATH? | default '' )"
    ^which nvim
    ^$nvim --version
    $env.PLENARY_DEBUG = "1"
    print "Running Plenary tests with debug output..."
  }

  # Prefer GNU coreutils timeout on non-Windows
  let has_timeout = (try { (which timeout | length) > 0 and ($nu.os-info.family != 'windows') } catch { false })

  if $has_timeout {
    print "Running tests with a 60 second timeout..."
    ^timeout --foreground 60 $nvim --headless --noplugin -u tests/minimal-init.lua -c 'luafile tests/run_tests.lua'
  } else {
    print "Running tests (no 'timeout' available)..."
    ^$nvim --headless --noplugin -u tests/minimal-init.lua -c 'luafile tests/run_tests.lua'
  }

  let exit_code = ($env.LAST_EXIT_CODE | default 0)
  if $has_timeout and ($exit_code == 124) {
    print "Error: Test execution timed out after 60 seconds"
    exit 1
  } else if $exit_code != 0 {
    print $"Error: Tests failed with exit code ($exit_code)"
    exit $exit_code
  } else {
    print "Test run completed successfully"
  }
}
