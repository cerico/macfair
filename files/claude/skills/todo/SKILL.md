---
name: todo
description: Work through tasks in the project's TODO.md file
---

# TODO

Read the project's TODO.md file and work through uncompleted tasks.

## Instructions

1. Read `TODO.md` from the project root
2. Find the first unchecked task (`- [ ]`)
3. Work through the task completely
4. Remove the task from TODO.md when complete
5. If more tasks exist, ask user if they want to continue to the next one

## Task Execution

For each task:
1. Understand what's being asked
2. Find the relevant files
3. Implement the solution
4. Verify it works (run tests if applicable)
5. Remove the completed task from TODO.md

## If No TODO.md Exists

Create one with a basic structure:

```markdown
# Project TODO

Tasks for improving this codebase.

## Tasks

- [ ] Review codebase and identify improvements
```

Then ask the user what tasks they'd like to add.

## If All Tasks Complete

Report: "All tasks in TODO.md are complete!"

## Output Format

```markdown
## Working on TODO

**Task:** [task description]

**Status:** [In Progress / Complete]

**Changes:**
- file.ts: [what was done]

**Next:** [X tasks remaining] - Continue? (y/n)
```
