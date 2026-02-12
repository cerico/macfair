## Commit Strategy

**Goal:** Clean commit with current timestamp.

## Steps

1. **Check recent commits** to understand message style:
   ```bash
   git log --oneline -5
   ```

2. **Stage all changes:**
   ```bash
   git add .
   ```

3. **Create commit:**
   - Use `git commit` with heredoc for multiline messages
   - **Print the commit message to the user before running the commit command** so they can see it in the Claude window

4. **Commit message format:**
   - **Prefix:** `feat:` or `fix:` (semantic versioning)
   - **Head:** Concise, picks most relevant change if multiple things
   - **Body:** Flat list of bullet points, one per change
     - Each line self-contained (no grouped sections with headers)
     - Order by importance (most significant changes first)
     - No parenthetical asides — either say it or don't
     - Skip body if only one trivial change
   - **Never** attribute code to Claude

5. **Example:**
   ```bash
   git commit -m "$(cat <<'EOF'
   feat: add user authentication and session management

   - Add JWT token validation middleware
   - Implement login/logout API endpoints
   - Add session expiry handling
   - Fix password hashing for special characters
   EOF
   )"
   ```

6. **After commit, run review:**
   Then invoke `/review 2` to get feedback before pushing.
