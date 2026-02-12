## Squash Branch Commits

**Goal:** Squash all commits unique to this branch into one commit with current timestamp.

## Steps

1. **Find merge base and count commits:**
   ```bash
   MERGE_BASE=$(git merge-base HEAD main)
   COMMIT_COUNT=$(git rev-list --count $MERGE_BASE..HEAD)
   ```
   If only 1 commit exists, tell the user there's nothing to squash and stop.

2. **Show what will be squashed:**
   ```bash
   git log --oneline $MERGE_BASE..HEAD
   ```
   Print these to the user so they can see what's being combined.

3. **Squash:**
   ```bash
   git reset --soft $MERGE_BASE
   ```

4. **Create new commit:**
   - Draft a single commit message summarizing the squashed commits
   - Use `git commit --reset-author` to set current timestamp
   - **Print the commit message to the user before running the commit command**
   - Use heredoc for the message

5. **Commit message format:**
   - **Prefix:** `feat:` or `fix:` (semantic versioning)
   - **Head:** Concise, picks most relevant change across all squashed commits
   - **Body:** Flat list of bullet points covering significant changes from all squashed commits
     - Deduplicate and consolidate — don't just concatenate old messages
     - Order by importance
     - Skip body if the squashed work is trivial enough for one line
   - **Never** attribute code to Claude
