# Style: euclid

Visual gallery grid with geometric illustrations and captions. Bauhaus-inspired color palette. Based on Euclid's Elements visualization by Nicholas Rougeux.

## Typography
- **Title:** Serif italic, centered, with period (e.g., "BOOKS.")
- **Item label:** Serif, uppercase with Roman numerals (e.g., "BOOK I.")
- **Item description:** Serif, regular, centered below label

## Color Palette

Bauhaus primary + black:
- Canvas: #F5EFE0 (warm cream)
- Red: #D64045 (vermillion)
- Blue: #1B4B8A (deep blue)
- Yellow: #F5B800 (golden yellow)
- Black: #1A1A1A
- Text: #2C2C2C

## Layout: gallery

Grid of visual items, each with an illustration area and caption below.

### Extraction Schema

```typescript
{
  layout: "gallery"
  title?: string             // Section title (italic, with period)
  items: [{
    label: string            // Item label (e.g., "BOOK I.")
    description: string      // Brief description
    illustration?: string    // Hint for illustration type: triangle, square, circle, polygon, grid, etc.
    colors?: string[]        // Override colors for this illustration
  }]
  columns?: number           // Items per row (default: 3)
}
```

### SVG Template

```svg
<svg width="900" height="700" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="900" height="700" fill="#F5EFE0"/>

  <!-- Title -->
  <text x="450" y="60" text-anchor="middle" fill="#2C2C2C" font-size="24" font-style="italic" font-family="Georgia, serif">BOOKS.</text>

  <!-- Item 1 (row 1, col 1) -->
  <!-- Illustration area: 200x200 centered in column -->
  <g transform="translate(150,140)">
    <!-- Geometric illustration using Bauhaus colors -->
    <!-- Example: triangle with shapes -->
    <polygon points="0,-80 80,60 -80,60" fill="none" stroke="#1A1A1A" stroke-width="2"/>
    <rect x="-30" y="-20" width="40" height="40" fill="#D64045"/>
    <circle cx="20" cy="30" r="25" fill="#1B4B8A"/>
    <circle cx="-10" cy="-40" r="15" fill="#F5B800"/>
  </g>

  <!-- Item 1 caption -->
  <text x="150" y="360" text-anchor="middle" fill="#2C2C2C" font-size="16" font-family="Georgia, serif">BOOK I.</text>
  <text x="150" y="385" text-anchor="middle" fill="#2C2C2C" font-size="14" font-family="Georgia, serif">Basic plane geometry</text>

  <!-- Item 2 (row 1, col 2) -->
  <g transform="translate(450,140)">
    <!-- Square-based illustration -->
    <rect x="-70" y="-70" width="140" height="140" fill="none" stroke="#1A1A1A" stroke-width="2"/>
    <rect x="-70" y="-70" width="70" height="70" fill="#F5B800"/>
    <rect x="0" y="-70" width="70" height="70" fill="#1B4B8A"/>
    <rect x="-70" y="0" width="70" height="70" fill="#D64045"/>
    <rect x="0" y="0" width="70" height="70" fill="#1A1A1A"/>
    <line x1="-70" y1="-70" x2="70" y2="70" stroke="#1A1A1A" stroke-width="2"/>
  </g>

  <text x="450" y="360" text-anchor="middle" fill="#2C2C2C" font-size="16" font-family="Georgia, serif">BOOK II.</text>
  <text x="450" y="385" text-anchor="middle" fill="#2C2C2C" font-size="14" font-family="Georgia, serif">Geometric algebra</text>

  <!-- Item 3 (row 1, col 3) -->
  <g transform="translate(750,140)">
    <!-- Circle-based illustration -->
    <circle cx="0" cy="0" r="70" fill="none" stroke="#1B4B8A" stroke-width="2"/>
    <polygon points="0,-60 52,30 -52,30" fill="none" stroke="#1A1A1A" stroke-width="2"/>
    <circle cx="-30" cy="10" r="20" fill="#D64045"/>
    <circle cx="30" cy="10" r="15" fill="#F5B800"/>
  </g>

  <text x="750" y="360" text-anchor="middle" fill="#2C2C2C" font-size="16" font-family="Georgia, serif">BOOK III.</text>
  <text x="750" y="385" text-anchor="middle" fill="#2C2C2C" font-size="14" font-family="Georgia, serif">Circles and angles</text>

  <!-- Row 2... -->
</svg>
```

## Illustration Guidelines

The illustrations are abstract geometric compositions using the Bauhaus palette. Base shapes on the content theme:

- **Triangle-based:** For foundational/basic concepts
- **Square/rectangle:** For algebraic/structured concepts
- **Circle:** For cyclical/continuous concepts
- **Polygon:** For complex/multi-part concepts
- **Grid/pattern:** For ratios/proportions

Each illustration should:
- Use 2-4 colors from the palette
- Include black outlines or shapes
- Have some overlapping/intersecting elements
- Feel balanced but dynamic

## Layout Notes
- Grid: typically 3 columns, 2 rows
- Item width: ~250-300px
- Illustration area: 180-220px square
- Gap between items: 40-60px
- Caption positioned 20px below illustration
- Label in caps with Roman numerals or numbers
- Description in sentence case
