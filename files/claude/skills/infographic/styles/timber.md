# Style: timber

Vertical timeline with spine, event markers, and alternating cards. Inspired by transit's warm earth-tone aesthetic.

## Typography
- **Title:** Sans-serif, uppercase with underline, letter-spacing: 3px
- **Subtitle:** Serif italic, smaller
- **Date labels:** Sans-serif, bold, 14-16px
- **Event titles:** Serif, 18-20px, bold
- **Event descriptions:** Serif, 13-14px

## Color Palette

Warm earth tones (transit-derived):
- Canvas: #E8DFD0 (warm tan/cream)
- Spine: #2C2C2C (dark charcoal)
- Text primary: #2C2C2C
- Text secondary: #6B5E50
- Marker colors (rotate through):
  - #D4A574 (tan/peach)
  - #8B9E7C (sage green)
  - #9E7B6B (terracotta)
  - #7B8FA1 (muted blue)
  - #A67C5B (brown)
  - #6B8E8E (teal)
- Card background: #F5F0E6 (warm cream, subtle)

## Layout: timeline

Vertical spine with alternating event cards on left and right.

### Extraction Schema

```typescript
{
  layout: "timeline"
  title: string              // Main title (uppercase)
  subtitle?: string          // Byline or source
  events: [{
    date: string             // "1995", "March 2020", etc.
    label: string            // Event name/title
    description?: string     // Optional detail (1-2 sentences)
    side?: "left" | "right"  // Alternate automatically if not specified
  }]
  direction?: "down" | "up"  // Default: "down" (oldest at top)
}
```

### SVG Template

```svg
<svg width="800" height="1200" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="800" height="1200" fill="#E8DFD0"/>

  <!-- Title block (top left) -->
  <text x="60" y="60" fill="#2C2C2C" font-size="14" font-family="Helvetica, sans-serif" letter-spacing="3">
    <tspan text-decoration="underline">TIMELINE</tspan>
    <tspan dx="10" font-style="italic" font-family="Georgia, serif" font-size="11">a history</tspan>
  </text>

  <text x="60" y="100" fill="#2C2C2C" font-size="36" font-weight="bold" font-family="Georgia, serif">Main Title</text>

  <!-- Vertical spine (centered) -->
  <line x1="400" y1="150" x2="400" y2="1100" stroke="#2C2C2C" stroke-width="4"/>

  <!-- Event 1 (left side) -->
  <!-- Marker on spine -->
  <circle cx="400" cy="200" r="8" fill="#D4A574" stroke="#2C2C2C" stroke-width="2"/>

  <!-- Tick line connecting to card -->
  <line x1="392" y1="200" x2="320" y2="200" stroke="#2C2C2C" stroke-width="0.5"/>

  <!-- Date label (right of spine, opposite to card) -->
  <text x="420" y="205" fill="#2C2C2C" font-size="14" font-weight="bold" font-family="Helvetica, sans-serif">1995</text>

  <!-- Event card (left side) -->
  <rect x="60" y="170" width="250" height="80" rx="4" fill="#F5F0E6" fill-opacity="0.6"/>
  <text x="75" y="195" fill="#2C2C2C" font-size="16" font-weight="bold" font-family="Georgia, serif">Event Title</text>
  <text x="75" y="218" fill="#6B5E50" font-size="13" font-family="Georgia, serif">
    <tspan x="75" dy="0">Description line one that</tspan>
    <tspan x="75" dy="17">wraps to second line.</tspan>
  </text>

  <!-- Event 2 (right side) -->
  <!-- Marker on spine -->
  <circle cx="400" cy="320" r="8" fill="#8B9E7C" stroke="#2C2C2C" stroke-width="2"/>

  <!-- Tick line connecting to card -->
  <line x1="408" y1="320" x2="480" y2="320" stroke="#2C2C2C" stroke-width="0.5"/>

  <!-- Date label (left of spine, opposite to card) -->
  <text x="380" y="325" text-anchor="end" fill="#2C2C2C" font-size="14" font-weight="bold" font-family="Helvetica, sans-serif">2000</text>

  <!-- Event card (right side) -->
  <rect x="490" y="290" width="250" height="80" rx="4" fill="#F5F0E6" fill-opacity="0.6"/>
  <text x="505" y="315" fill="#2C2C2C" font-size="16" font-weight="bold" font-family="Georgia, serif">Event Title</text>
  <text x="505" y="338" fill="#6B5E50" font-size="13" font-family="Georgia, serif">
    <tspan x="505" dy="0">Description text here.</tspan>
  </text>

  <!-- More events... alternate left/right -->
</svg>
```

## Layout Notes
- Canvas: 800x1200+ (tall format, height scales with event count)
- Spine: 4px wide, centered at x=400 or offset
- Markers: 12-16px diameter circles on spine, 2px stroke
- Event spacing: 100-120px vertical between markers
- Card width: 250-280px
- Card padding: 15-20px
- Tick lines: 0.5px connecting marker to card edge
- Date labels: positioned opposite to card (if card left, date right of spine)
- Alternate colors through marker palette

## Height Calculation
- Base height: 200px (title area)
- Per event: 120px
- Bottom margin: 100px
- Total: `200 + (eventCount × 120) + 100`

## Detection
Content that matches timeline layout:
- "history of", "evolution of", "timeline of"
- Dates or years mentioned (1995, 2020, March 2020)
- "over time", "through the years"
- Chronological sequences
- "milestones", "key moments"
