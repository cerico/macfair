# Dotfiles & Config Management

Check for dotfiles and configuration management issues.

## Patterns to Find

- Hardcoded absolute paths that assume specific machine/user
- Symlinks that overwrite without backup
- Secrets, tokens, or credentials in tracked files
- Missing existence checks before operations
- Platform-specific code without guards
- Assuming specific shell (bash vs zsh)
- Overwriting system files without confirmation
- Missing directory creation before file operations

## Examples

```bash
# BAD - hardcoded user path
ln -sf /Users/john/.config/app ~/.config/app

# GOOD - use variables
ln -sf "$HOME/.config/app" ~/.config/app
```

```bash
# BAD - overwrite without backup
ln -sf "$source" "$target"

# GOOD - backup existing file
[[ -e "$target" && ! -L "$target" ]] && mv "$target" "$target.backup"
ln -sf "$source" "$target"
```

```bash
# BAD - secrets in tracked file
export API_KEY="sk-1234567890abcdef"

# GOOD - source from untracked file
[[ -f ~/.secrets ]] && source ~/.secrets
```

```bash
# BAD - no existence check
source ~/.custom_config

# GOOD - check before sourcing
[[ -f ~/.custom_config ]] && source ~/.custom_config
```

```bash
# BAD - platform-specific without guard
# Uses macOS-only command
pbcopy < file.txt

# GOOD - platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
  pbcopy < file.txt
elif command -v xclip &>/dev/null; then
  xclip -selection clipboard < file.txt
fi
```

```bash
# BAD - assumes bash
# In .zshrc
shopt -s globstar  # bash-only

# GOOD - shell-specific or portable
if [[ -n "$BASH_VERSION" ]]; then
  shopt -s globstar
elif [[ -n "$ZSH_VERSION" ]]; then
  setopt extended_glob
fi
```

```bash
# BAD - create file without ensuring directory exists
echo "config" > ~/.config/myapp/settings.conf

# GOOD - ensure directory exists first
mkdir -p ~/.config/myapp
echo "config" > ~/.config/myapp/settings.conf
```

```yaml
# BAD - Ansible overwrites without checking
- name: Copy bashrc
  copy:
    src: bashrc
    dest: ~/.bashrc

# GOOD - backup original
- name: Copy bashrc
  copy:
    src: bashrc
    dest: ~/.bashrc
    backup: yes
```

```bash
# BAD - hardcoded tool paths
/opt/homebrew/bin/brew install foo

# GOOD - rely on PATH or detect
if command -v brew &>/dev/null; then
  brew install foo
fi
```
