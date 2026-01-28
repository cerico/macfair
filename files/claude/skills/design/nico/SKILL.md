---
name: design:nico
description: Dark forest aesthetic with elegant restraint. Desaturated palettes, serif typography, circular motifs. For data visualizations, editorial sites, refined presentations.
---

# Nico Design System

A framework-agnostic design system emphasizing elegant restraint, dark muted backgrounds, and data treated as visual art.

## When to Use

- Data visualizations
- Editorial/magazine layouts
- Portfolio presentations
- Sites where content should feel luminous against darkness
- Anything benefiting from quiet sophistication

## Core Philosophy

1. **Elegant restraint** - Complexity emerges from simplicity, not decoration
2. **Luminous content** - Dark backgrounds make content glow
3. **Desaturation** - Muted colors feel refined; rainbows feel cheap
4. **Information as art** - Data is intrinsically beautiful when presented with care

## Color Palette

Use these semantic tokens. Translate to the framework's convention (CSS variables, Tailwind config, SCSS variables, etc.).

| Token | Purpose | Reference Value |
|-------|---------|-----------------|
| `bg` | Primary background | Deep forest green-black (#1a2e1a) |
| `bg-muted` | Secondary surfaces | Lighter forest (#2a3d2a) |
| `bg-lighter` | Tertiary/borders | (#3a4d3a) |
| `text` | Primary text | Warm off-white (#f5f2eb) |
| `text-muted` | Secondary text | Muted tan (#a8a090) |
| `accent-warm` | Warm accent | Desaturated gold (#c4a35a) |
| `accent-cool` | Cool accent | Desaturated teal (#5a8a9a) |

**Palette principles:**
- Maximum 2-3 colors beyond the neutrals
- Accents should be desaturated (30-45% saturation)
- Warm and cool accents create natural contrast without clashing
- Background darkness should be 85-95% (very dark but not pure black)

## Typography

**Primary font**: Literata or similar refined serif with:
- Optical sizing if available
- Light to regular weights (300-400) for elegance
- Slightly expanded letter-spacing on small text

**Secondary font**: System sans-serif for UI elements, navigation labels

**Type scale principles:**
- Large display text: light weight, tight tracking
- Body text: regular weight, comfortable line height (1.6-1.8)
- Labels/navigation: small caps or uppercase with wide letter-spacing (0.1-0.2em)

## Visual Motifs

**Circular/radial organization:**
- Concentric circles for layered information
- Arc diagrams for relationships
- Radial layouts for cyclical data (time, seasons)
- Central focal points with radiating elements

**Grid patterns:**
- Sparse layouts with generous negative space
- 4-5 column compound grids
- Asymmetric balance over rigid symmetry

## Spatial Composition

- **Generous padding** - Let content breathe
- **Vertical rhythm** - Consistent spacing scale
- **Full-bleed moments** - Occasional edge-to-edge elements for drama
- **Layered depth** - Subtle shadows, overlapping elements

## Interaction Patterns

- **Hover glow** - Subtle luminosity increase on interactive elements
- **Opacity transitions** - 0.85 → 1.0 on hover
- **Progressive disclosure** - Reveal details on interaction, not all at once
- **Tooltips** - Contextual information near cursor
- **Transitions** - Smooth, 150-200ms duration, ease-out timing

## Implementation Notes

When applying this system:

1. **Start with background** - Set the dark foundation first
2. **Establish type hierarchy** - Load fonts, set base styles
3. **Add content** - Let it glow against the darkness
4. **Layer accents sparingly** - One accent color is often enough
5. **Test contrast** - Ensure WCAG AA compliance (4.5:1 for text)

## Anti-Patterns

Avoid:
- Bright saturated colors
- Pure black backgrounds (#000)
- Sans-serif as primary font
- Busy patterns or textures
- Multiple accent colors competing
- Harsh borders (prefer subtle shadows or opacity)
