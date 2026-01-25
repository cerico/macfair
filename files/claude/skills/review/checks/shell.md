# Shell Script Quality

Check for common shell scripting issues.

## Patterns to Find

- Unquoted variables causing word splitting or glob expansion
- Missing error handling (`set -e`, `set -u`, `set -o pipefail`)
- Using `[` instead of `[[` in bash scripts
- Backticks instead of `$()` for command substitution
- Bashisms in scripts with `#!/bin/sh` shebang
- Unchecked command exit codes
- Hardcoded paths that break cross-platform
- Using `echo` for user data (use `printf` instead)
- Missing `--` to separate options from arguments
- Fragile delimiters in structured data (e.g., `|` instead of `\t`)

## Examples

```bash
# BAD - unquoted variable
rm -rf $dir/tmp

# GOOD - quoted variable
rm -rf "$dir/tmp"
```

```bash
# BAD - no error handling
#!/bin/bash
cd /some/dir
rm -rf important_files

# GOOD - fail on errors
#!/bin/bash
set -euo pipefail
cd /some/dir
rm -rf important_files
```

```bash
# BAD - single brackets
if [ "$foo" = "bar" ]; then

# GOOD - double brackets in bash
if [[ "$foo" = "bar" ]]; then
```

```bash
# BAD - backticks (hard to nest, easy to confuse with quotes)
result=`command`

# GOOD - $() syntax
result=$(command)
```

```bash
# BAD - hardcoded Homebrew path
/opt/homebrew/bin/jq

# GOOD - use PATH or check both locations
if command -v jq &>/dev/null; then
  jq ...
fi
# or
JQ="${HOMEBREW_PREFIX:-/opt/homebrew}/bin/jq"
```

```bash
# BAD - echo with variable (can interpret flags)
echo $user_input  # if input is "-n", echo treats it as flag

# GOOD - printf is safer
printf '%s\n' "$user_input"
```

```bash
# BAD - no -- separator
grep "$pattern" $file  # if file starts with -, treated as flag

# GOOD - use -- to end options
grep -- "$pattern" "$file"
```

```bash
# BAD - unchecked exit code
result=$(some_command)
echo "Got: $result"

# GOOD - check exit code
if ! result=$(some_command); then
  echo "Command failed" >&2
  exit 1
fi
```

```bash
# BAD - fragile delimiter (breaks if fields contain |)
data=$(jq -r '.items[] | "\(.name)|\(.note)"' file.json)
while IFS='|' read -r name note; do
  echo "$name: $note"
done <<< "$data"

# GOOD - use tab separator (fields rarely contain tabs)
data=$(jq -r '.items[] | [.name, .note] | @tsv' file.json)
while IFS=$'\t' read -r name note; do
  echo "$name: $note"
done <<< "$data"
```
