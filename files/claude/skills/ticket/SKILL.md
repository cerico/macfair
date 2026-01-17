---
name: ticket
description: Create tickets for Ralph to work on later. Interactive ticket planning and creation.
---

# Ticket

Create tickets in `tmp/tickets/` for Ralph to work on autonomously.

## When to Use

- Planning work to delegate to Ralph
- Breaking down a feature into discrete tasks
- Creating a backlog of improvements
- Capturing bugs or issues to fix later

## Instructions

### 1. Ensure Directory Exists

```bash
mkdir -p tmp/tickets/done
```

### 2. Gather Requirements

Ask the user:
- What needs to be done?
- Any reference number? (e.g., CEL-042, PROJ-123, or just use sequential numbers)
- Any specific files or areas of the codebase?
- Acceptance criteria?

### 3. Create Ticket

Filename format: `{REFERENCE}-{short-description}.md`

Examples:
- `CEL-042-add-logout-button.md`
- `001-fix-header-alignment.md`
- `PROJ-99-refactor-auth-flow.md`

### 4. Ticket Template

```markdown
# {Title}

{Clear description of what needs to be done}

## Context

{Why this is needed, background info}

## Files

{Known files that need changes, if any}

## Acceptance Criteria

- [ ] {Specific requirement 1}
- [ ] {Specific requirement 2}
```

## Workflow

1. **Single ticket**: User describes one task, create it
2. **Batch planning**: User describes a feature, help break it into multiple tickets
3. **Review**: Show created tickets, let user refine before finishing

## Commands

After creating tickets, suggest:
- `ralph status` - see pending tickets
- `ralph run` - start working through them

## Example Session

**User:** I need to add user authentication

**Assistant:** Let me help break that down into tickets. A few questions:
1. What auth method? (OAuth, email/password, magic link?)
2. Do you have a reference prefix? (e.g., AUTH-001)
3. Any existing auth code to work with?

**User:** Email/password, use AUTH prefix, starting fresh

**Assistant:** I'll create these tickets:

1. `AUTH-001-user-model.md` - Create User model with email/password fields
2. `AUTH-002-signup-endpoint.md` - POST /api/auth/signup
3. `AUTH-003-login-endpoint.md` - POST /api/auth/login
4. `AUTH-004-session-middleware.md` - Session handling middleware
5. `AUTH-005-protected-routes.md` - Add auth checks to protected routes

Want me to create these, or adjust the breakdown first?

**User:** Create them

**Assistant:** Created 5 tickets:
- `tmp/tickets/AUTH-001-user-model.md`
- `tmp/tickets/AUTH-002-signup-endpoint.md`
- ...

Run `ralph status` to see them, or `ralph run` to start working.

## Notes

- Keep tickets focused and atomic
- One clear deliverable per ticket
- Ralph works one ticket at a time
- Tickets should be completable in a single session
