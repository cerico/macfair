## Commit Strategy

**Goal:** One commit unique to this branch, with current timestamp.

## Steps

1. **Check recent commits** to understand message style:
   ```bash
   git log --oneline -5
   ```

2. **Ensure only one commit on branch:**
   ```bash
   # Find merge base with main
   MERGE_BASE=$(git merge-base HEAD main)

   # Check how many commits exist
   COMMIT_COUNT=$(git rev-list --count $MERGE_BASE..HEAD)

   # If more than 1, squash them
   if [ "$COMMIT_COUNT" -gt 1 ]; then
     git reset --soft $MERGE_BASE
   fi
   ```

3. **Stage all changes:**
   ```bash
   git add .
   ```

4. **Create/amend commit:**
   - If this is amending: use `git commit --amend --reset-author` (updates date to now)
   - If new commit: use `git commit`
   - Use heredoc for multiline messages
   - **Print the commit message to the user before running the commit command** so they can see it in the Claude window

5. **Commit message format:**
   - **Prefix:** `feat:` or `fix:` (semantic versioning)
   - **Head:** Concise, picks most relevant change if multiple things
   - **Body:** Flat list of bullet points, one per change
     - Each line self-contained (no grouped sections with headers)
     - Order by importance (most significant changes first)
     - No parenthetical asides — either say it or don't
     - Skip body if only one trivial change
   - **Never** attribute code to Claude

6. **Example (amending existing commit):**
   ```bash
   git commit --amend --reset-author -m "$(cat <<'EOF'
   feat: add user authentication and session management

   - Add JWT token validation middleware
   - Implement login/logout API endpoints
   - Add session expiry handling
   - Fix password hashing for special characters
   EOF
   )"
   ```

7. **After commit, run review:**
   Then invoke `/review 2` to get feedback before pushing.
