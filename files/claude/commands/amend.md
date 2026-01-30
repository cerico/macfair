## Amend Commit

**Goal:** Amend the last commit, updating the timestamp and message body.

**Arguments:** `$ARGUMENTS`
- No arguments: amend with only already-staged changes
- `add`: run `git add .` first, then amend (brings in all changes)

## Steps

1. **If `$ARGUMENTS` contains `add`:**
   ```bash
   git add .
   ```
   Otherwise, skip — only already-staged files will be included.

2. **Amend the commit** with `--reset-author` to update the timestamp:
   - Keep the existing subject line
   - Add or update the body to describe what changed in this amend
   - Use heredoc for the message

3. **Format:**
   ```bash
   git commit --amend --reset-author -m "$(cat <<'EOF'
   <existing subject>

   <new or updated body describing the amendment>
   EOF
   )"
   ```

4. **After amend, run review:**
   Then invoke `/review 2` to get feedback before pushing.
