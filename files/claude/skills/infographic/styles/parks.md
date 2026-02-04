# Style: parks

Dark dashboard with colored tile grid. Each tile contains an icon and value. Inspired by National Parks infographic.

## Typography
- **Values:** Sans-serif, bold, 18-24px
- **Labels:** Sans-serif, uppercase, 14-16px, letter-spacing: 2px
- **Sublabels:** Sans-serif, italic, 12-14px

## Color Palette

Dark background with earth-tone tiles:
- Canvas: #3D2E1F (dark brown)
- Text light: #F5F0E6 (cream, for dark tiles)
- Text dark: #3D2E1F (brown, for light tiles)
- Tile colors (rotate through):
  - #6B4423 (dark brown)
  - #8B5E34 (medium brown)
  - #A67C52 (tan)
  - #7D8B6E (olive green)
  - #9CAF88 (light green)
  - #B8860B (golden)
  - #A0522D (sienna)
  - #8DB6CD (light blue)
  - #B4A582 (khaki)

## Layout: tiles

Grid of colored tiles, each containing an icon and a stat value.

### Extraction Schema

```typescript
{
  layout: "tiles"
  items: [{
    title: string            // Item name (shown below grid)
    subtitle?: string        // Location or category
    stats: [{
      icon: string           // Icon name: elevation-up, elevation-down, area, calendar, people, rainfall, temperature, latitude, longitude
      value: string          // Display value
      color?: string         // Tile color override
    }]
  }]
  columns?: number           // Tiles per row (default: 4)
  rows?: number              // Rows per item (default: 3)
}
```

### Icon Set for Parks Style

```svg
<!-- elevation-up: upward chevron -->
<path d="M-8,4 L0,-4 L8,4" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>

<!-- elevation-down: downward chevron -->
<path d="M-8,-4 L0,4 L8,-4" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>

<!-- area: dotted circle -->
<circle cx="0" cy="0" r="8" fill="none" stroke="currentColor" stroke-width="2" stroke-dasharray="3,3"/>

<!-- calendar: grid -->
<rect x="-8" y="-6" width="16" height="14" fill="none" stroke="currentColor" stroke-width="1.5"/>
<line x1="-8" y1="-2" x2="8" y2="-2" stroke="currentColor" stroke-width="1.5"/>
<line x1="-4" y1="-2" x2="-4" y2="8" stroke="currentColor" stroke-width="1"/>
<line x1="0" y1="-2" x2="0" y2="8" stroke="currentColor" stroke-width="1"/>
<line x1="4" y1="-2" x2="4" y2="8" stroke="currentColor" stroke-width="1"/>
<line x1="-8" y1="2" x2="8" y2="2" stroke="currentColor" stroke-width="1"/>

<!-- people: person silhouette -->
<circle cx="0" cy="-5" r="4" fill="currentColor"/>
<path d="M-6,8 Q-6,0 0,0 Q6,0 6,8" fill="currentColor"/>

<!-- rainfall: water drop -->
<path d="M0,-8 Q-6,2 0,8 Q6,2 0,-8" fill="currentColor"/>

<!-- temperature: palette/thermometer -->
<circle cx="-4" cy="4" r="3" fill="currentColor"/>
<circle cx="4" cy="-2" r="2" fill="currentColor"/>
<circle cx="0" cy="0" r="2.5" fill="currentColor"/>
<circle cx="-2" cy="-5" r="1.5" fill="currentColor"/>

<!-- latitude: horizontal arrow -->
<path d="M-10,0 L10,0 M-6,-4 L-10,0 L-6,4 M6,-4 L10,0 L6,4" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>

<!-- longitude: vertical arrow -->
<path d="M0,-10 L0,10 M-4,-6 L0,-10 L4,-6 M-4,6 L0,10 L4,6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
```

### SVG Template

```svg
<svg width="1200" height="500" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="1200" height="500" fill="#3D2E1F"/>

  <!-- Item 1 grid (4x3 tiles) -->
  <!-- Row 1 -->
  <rect x="40" y="40" width="85" height="85" rx="8" fill="#6B4423"/>
  <g transform="translate(82,65)">
    <!-- elevation-up icon -->
    <path d="M-8,4 L0,-4 L8,4" fill="none" stroke="#F5F0E6" stroke-width="3" stroke-linecap="round"/>
  </g>
  <text x="82" y="110" text-anchor="middle" fill="#F5F0E6" font-size="16" font-family="Helvetica, sans-serif">10,197 ft</text>

  <rect x="135" y="40" width="85" height="85" rx="8" fill="#7D8B6E"/>
  <!-- ... more tiles -->

  <!-- Item title below grid -->
  <text x="200" y="430" text-anchor="middle" fill="#F5F0E6" font-size="18" font-weight="bold" font-family="Helvetica, sans-serif">LAKE CLARK</text>
  <text x="200" y="455" text-anchor="middle" fill="#F5F0E6" font-size="14" font-style="italic" font-family="Helvetica, sans-serif">Alaska</text>

  <!-- Item 2 grid... -->
</svg>
```

## Layout Notes
- Tile size: 80-100px square
- Tile gap: 8-12px
- Tile corner radius: rx="8"
- Icon centered in upper portion of tile
- Value centered in lower portion
- Light text on dark tiles, dark text on light tiles
- Items separated by ~40px gap
- Title/subtitle centered below each item's tile grid
