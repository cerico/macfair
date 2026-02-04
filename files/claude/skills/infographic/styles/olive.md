# Style: olive

Soft, approachable infographics with rounded cards, subtle shadows, and earth-tone palette. Designed for decision trees, comparisons, and flowcharts.

## Metadata

canvas-preference: light
default-palette: earth

## Typography

- **Headings:** system-ui, -apple-system, sans-serif — medium weight (500)
- **Body:** system-ui, -apple-system, sans-serif — regular weight (400), line-height 1.5
- **Labels:** system-ui, uppercase, letter-spacing: 1px, 12-14px, bold
- **Card titles:** 18-22px, bold

## Color Tokens

Uses palette tokens for all colors:
- Canvas: {canvas}
- Primary card: {cards.primary}
- Secondary card: {cards.secondary}
- Text dark: {text.primary}
- Text light: {text.onDark}
- Text muted: {text.muted}
- Accent: {accents[1]}
- Icon background: {text.onDark}
- Connector lines: {text.primary}

## Visual Elements

- **Rounded corners:** rx="16" for cards, rx="50%" for icon circles
- **Shadows:** `<filter id="shadow"><feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.1"/></filter>`
- **Icons:** 40px diameter circles filled with {text.onDark}, centered icon paths using {accents[1]}
- **Curved arrows:** Quadratic bezier paths connecting elements
- **No border frames** — cards float on canvas
- **Branch labels:** Bold colored text (YES/NO) using {accents[0]}

## Layout Variants

### Decision Tree (800x600)

- Question bubble: centered top, pill-shaped (rx="40"), fill {text.onDark} with thin stroke {text.primary}
- Two branch cards below: left ({cards.primary}), right ({cards.secondary})
- Curved arrows from question to cards
- Branch labels on arrows
- Cards contain: icon circle, title, description, optional bullets

### Comparison (800x500 for 2 items, wider for more)

- Optional title at top
- Cards side-by-side with 24px gap
- Each card: icon circle at top, heading, description, optional bullets
- Alternating {cards.primary}/{cards.secondary} colors

## Card Structure

```
+----------------------------------+
|  [icon circle]                   |  <- 40px from top
|                                  |
|  CARD TITLE                      |  <- Bold, 18-22px
|  Description text that can       |  <- Regular, 14-16px
|  wrap to multiple lines.         |
|                                  |
|  * Bullet point one              |  <- Optional bullets
|  * Bullet point two              |
+----------------------------------+
```

## Shadow Filter Definition

```svg
<defs>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
    <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.1"/>
  </filter>
</defs>
```

## Notes

- Icons are simple, single-color SVG paths
- Text on primary cards uses {text.onDark}
- Text on secondary cards uses {text.onLight}
- Bullets use bullet character (*) not dashes
- Keep descriptions concise (2-3 lines max per card)
