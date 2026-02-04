# Style: werner

Classical catalog/table layout inspired by Werner's Nomenclature of Colours. Clean rows with swatches, multiple data columns, and serif typography.

## Typography
- **Headers:** Georgia, serif — regular weight, underlined, uppercase or title case
- **Names/Numbers:** Georgia, serif — regular, with numbering prefix (e.g., "24. Scotch Blue")
- **Descriptions:** Georgia, serif — italic, for natural references (Animal, Vegetable, Mineral)
- **Labels:** Georgia, serif — 11-12px, letter-spacing: 2px

## Color Palette

Classical naturalist reference:
- Canvas: #F5F0E6 (warm cream)
- Text primary: #2C2C2C (near-black)
- Text secondary: #6B5E50 (warm brown-gray)
- Row alternate: #EDE7DA (lighter cream, optional zebra striping)
- Rule lines: #C4B8A8 (subtle, warm gray)
- Header underline: #2C2C2C

## Layout

### Table/Catalog (default for werner)
- Canvas: 900x variable height (depends on row count)
- Margins: 60px sides, 50px top/bottom
- Content width: 780px
- Row height: 80-100px (to accommodate swatches)
- Column structure flexible based on content

### Column Widths (example for color catalog)
- Color swatch: 60px
- Name: 140px
- Description columns: ~180px each
- Parts/palette: 100px

## Visual Elements

### Header Row
- Underlined text (1px rule below each header)
- No background color
- Letter-spacing: 1px

### Data Rows
- Left-aligned text
- Optional subtle rule between rows (0.5px, #C4B8A8)
- Or use whitespace separation (24px between rows)

### Color Swatches
- Square or rounded rect (60x60px or 50x70px)
- Slight border if color is close to canvas: `stroke="#C4B8A8" stroke-width="0.5"`

### Parts/Palette Dots
- 3-4 circles (20-24px diameter)
- Slight overlap or 4px gap
- Represent color components or variations

## Extraction Schema

```typescript
{
  layout: "catalog"
  title?: string           // Optional title above table
  columns: string[]        // Column headers ["Color", "Name", "Animal", "Vegetable", "Mineral", "Parts"]
  rows: [{
    swatch?: string        // Hex color for swatch column
    values: string[]       // Data for each column
    parts?: string[]       // Hex colors for palette dots (if applicable)
  }]
}
```

## SVG Template

```svg
<svg width="900" height="{dynamicHeight}" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="900" height="{height}" fill="#F5F0E6"/>

  <!-- Optional title -->
  <text x="450" y="45" text-anchor="middle" fill="#2C2C2C" font-size="18" font-family="Georgia, serif" letter-spacing="4">{TITLE}</text>

  <!-- Header row -->
  <text x="60" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Color</text>
  <text x="130" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Name</text>
  <text x="280" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Animal</text>
  <!-- ... more headers -->

  <!-- Data row -->
  <rect x="60" y="110" width="50" height="60" fill="{swatchColor}" stroke="#C4B8A8" stroke-width="0.5"/>
  <text x="130" y="145" fill="#2C2C2C" font-size="14" font-family="Georgia, serif">24. Scotch Blue</text>
  <text x="280" y="145" fill="#2C2C2C" font-size="13" font-style="italic" font-family="Georgia, serif">Throat of Blue Titmouse.</text>
  <!-- ... more columns -->

  <!-- Parts dots -->
  <circle cx="780" cy="140" r="12" fill="#1a1a1a"/>
  <circle cx="808" cy="140" r="12" fill="#4a7089"/>
  <circle cx="836" cy="140" r="12" fill="#c4a5a0"/>

  <!-- Row divider (optional) -->
  <line x1="60" y1="180" x2="840" y2="180" stroke="#C4B8A8" stroke-width="0.5"/>

  <!-- Next row... -->
</svg>
```

## Row Height Calculation
- Base row height: 80px
- Add 20px for each additional line of wrapped text
- Minimum 24px vertical padding around content

## Notes
- Swatches should be visually prominent
- Italic text for natural/descriptive references
- Numbers prefix names when showing ordered items
- Parts dots can overlap slightly for compact palettes
- Keep descriptions concise (aim for single line)
- This style works best for 4-8 rows; beyond that consider pagination
