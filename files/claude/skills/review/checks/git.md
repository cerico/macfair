# Git Hygiene

Check for git-related issues in the diff and repository.

## Patterns to Find

### Commit Message Format
- Missing semantic prefix (feat, fix, docs, etc.)
- Messages that don't explain "why"
- Overly long subject lines (>72 chars)
- Missing blank line between subject and body
- References to issues/tickets missing

### Large Files
- Binary files that shouldn't be tracked
- Large generated files committed
- node_modules or vendor directories
- Build artifacts (.next, dist, build)
- Large media files without LFS

### Merge Conflict Markers
- Leftover `<<<<<<<`, `=======`, `>>>>>>>` markers
- Unresolved conflicts committed

### Sensitive Data
- API keys or secrets committed
- Private keys or certificates
- Database credentials
- .env files tracked

### Branch Hygiene
- Very long-lived feature branches
- Merge commits instead of rebases (when rebase is preferred)
- Force push to shared branches

## Examples

```
# BAD - unclear commit message
fixed stuff

# BAD - no semantic prefix
update user validation

# GOOD - semantic prefix with context
feat: add email validation to user registration

Validates email format and checks for duplicates before
allowing registration. Closes #123.
```

```
# BAD - too long
feat: add comprehensive email validation including format checking and duplicate prevention to the user registration flow

# GOOD - concise subject, details in body
feat: add email validation to registration

- Check email format with regex
- Query database for duplicates
- Return specific error messages
```

```gitignore
# Files that should be in .gitignore

# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
.next/
out/

# Environment
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Large files (use LFS instead)
*.psd
*.ai
*.mov
*.mp4
```

```bash
# Check for large files in history
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  awk '/^blob/ {print $3, $4}' | \
  sort -rn | \
  head -20

# Check for secrets (basic patterns)
git diff main...HEAD | grep -E "(password|secret|api.?key|token|credential)" -i
```

## Merge Conflict Markers

These should never appear in committed code:

```
<<<<<<< HEAD
current changes
=======
incoming changes
>>>>>>> feature-branch
```

If found in diff, the conflict was not properly resolved.
