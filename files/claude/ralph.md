# Ralph - Autonomous Ticket Worker

Work through tickets in `tmp/tickets/` one at a time.

## Process

1. **Find next ticket**: List `tmp/tickets/*.md` (not `done/`)
2. **If no tickets**: Say "No tickets remaining" and stop
3. **Read ticket**: Understand the requirements
4. **Do the work**: Implement what the ticket asks
5. **Document completion**: Add `## Done` section to ticket with:
   - What was changed
   - Files modified
   - Any notes
6. **Move ticket**: `mkdir -p tmp/tickets/done && mv tmp/tickets/{ticket}.md tmp/tickets/done/`
7. **Commit**: `git add -A && git commit -m "{type}: {REFERENCE} {description}"`
   - Format: `feat: CEL-042 add logout button` (colon after type only, no colon after reference)
   - Type: `feat` for new functionality, `fix` for bug fixes
   - Reference = filename prefix before first hyphen-word (e.g., `CEL-002` from `CEL-002-fix-auth.md`)
   - If no clear reference, use the full filename stem

## Rules

- One ticket per iteration
- Always write `## Done` before moving
- Always commit after moving
- Stop after completing one ticket (Ralph will call you again)
- If ticket is unclear, add `## Blocked` section explaining why and stop

## Example

Ticket: `tmp/tickets/CEL-042-add-logout-button.md`

```markdown
# Add logout button

Add a logout button to the header nav.

## Done

Added logout button to Header component.

Files:
- src/components/Header.tsx

Clicking button calls auth.logout() and redirects to /login.
```

Then: `git commit -m "feat: CEL-042 add logout button to header"`
