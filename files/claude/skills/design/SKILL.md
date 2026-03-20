---
name: design
description: Apply a named design system to the current project. Themes define color, typography, layout, and interaction patterns.
user-invocable: true
argument: theme name (e.g. nico)
---

# Design System

Apply a design theme to the current project. Each theme is a complete visual language covering color, typography, layout, and interaction.

## Usage

- `/design nico` - Dark forest aesthetic, elegant restraint

## How It Works

1. Read the theme file from `~/.claude/skills/design/themes/<name>.md`
2. Apply its design tokens, typography, and patterns to the current task
3. Follow the theme's anti-patterns list to avoid visual mistakes

## Available Themes

| Theme | Aesthetic |
|-------|-----------|
| `nico` | Dark forest, desaturated palettes, serif typography, circular motifs |

## Adding Themes

Add a new `.md` file to `themes/` with sections: Color Palette, Typography, Visual Motifs, Spatial Composition, Interaction Patterns, Implementation Notes, Anti-Patterns.
