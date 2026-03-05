---
name: curate
description: Review and promote second brain inbox notes to permanent knowledge. Run from ~/second-brain/.
user-invocable: true
---

# Curate Second Brain

Review fleeting notes in `Inbox/` and decide what becomes permanent knowledge.

## Process

1. List all files in `Inbox/`
2. If empty, say so and suggest the user capture some notes first
3. For each note, read it and then:
   - Search `Zettelkasten/` and `MOCs/` for related existing notes
   - Present the note with a recommendation: **Promote**, **Merge**, **File**, or **Discard**
   - Wait for user decision before proceeding
4. When promoting:
   - Rewrite with a clean title and proper context
   - Add `[[wikilinks]]` to related Zettelkasten notes
   - Update or create relevant MOCs
   - Move from `Inbox/` to `Zettelkasten/`
   - Change frontmatter `type: fleeting` to `type: permanent`
5. When merging: append content to the existing note, delete the inbox file
6. When filing: move to `Resources/`, `Literature/`, or `Projects/` as appropriate
7. When discarding: delete the file

## After Processing

- Show a summary: X promoted, X merged, X filed, X discarded
- If any new MOCs were created, mention them
- If any existing MOCs were updated, mention them
