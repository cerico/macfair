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

## Post-commit waypoints

Run these silently after review. Skip any that have nothing to report.

### 7. File undecided permissions
Check if any tool calls during this session required user permission (the user was prompted to allow/deny). Compare tools used against the allow patterns in `~/.claude/settings.json`. For any tool call that doesn't match an allow pattern and isn't already listed in `~/.claude/permissions.md`:
- Read `~/.claude/permissions.md`
- Append new entries under the `## Undecided` section with format: `- \`ToolName(pattern)\` — context of what it was used for (YYYY-MM-DD)`
- Write the updated file

### 8. Memory capture
Reflect on the session: did we discover a repeatable pattern, a gotcha, a convention, or a debugging insight worth preserving? If yes:
- Read the relevant memory file in the project's `.claude/` memory directory (or `~/.claude/` for cross-project learnings)
- Append or update with the new insight
- Keep entries concise and actionable
- If nothing worth capturing, skip silently

### 9. CLAUDE.md drift check
**Only if the project has a CLAUDE.md.** Many projects don't — skip silently if absent. Do not create one.
Compare what we actually did in this session against the project's CLAUDE.md instructions. If we introduced patterns that contradict or extend what's documented (e.g. switched libraries, changed conventions, added new patterns):
- Flag the specific drift to the user
- Suggest the update to CLAUDE.md
- Do not auto-update — let the user decide

### 10. TODO harvest
**Only if the project already has a TODO.md.** Skip silently if absent. Do not create one.
Scan the session for loose ends: things we said we'd do later, tests we skipped, known issues we deferred. If any exist:
- Read the project's `TODO.md`
- Append new items that aren't already listed
- Format: `- [ ] Description (from session YYYY-MM-DD)`

### 11. Insight and failure capture
Scan the session for two things:

**Failure patterns** — prioritise these. Look for:
- Commands or tests that failed repeatedly before succeeding
- Debug loops where the same error was hit 3+ times
- Unexpected API/tool behaviour (e.g. "returns 200 on error", "silently drops field")
- Environment gotchas (e.g. "migration fails when X", "works locally but not in CI")

If any failure patterns exist, write each as a fleeting note to `~/second-brain/Inbox/`:
- Filename: `YYYYMMDD-HHMMSS-failure-slug.md`
- Tag with `tags: [failure-pattern, auto-captured]`
- Structure: what failed, why it failed, what the fix was, and the **general pattern** to watch for next time
- Capture the pattern, not the code fix (the fix is in git)

**Novel insights** — also capture:
- A pattern that solved a hard problem
- A decision with non-obvious reasoning
- A workflow worth repeating

For insights, use standard format (`YYYYMMDD-HHMMSS-slug.md` with `tags: [auto-captured]`).
If the insight is a reusable workflow, tag `skill-candidate`.

If nothing worth capturing happened in this session, skip silently.
