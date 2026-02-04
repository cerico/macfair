# Style: transit

Vertical bar chart inspired by Nick Rougeux's Chicago 'L' transit visualization. Bars ranked by height with horizontal tick marks for data points.

## Typography
- **Title:** Sans-serif, uppercase with underline, letter-spacing: 3px
- **Subtitle:** Serif italic, smaller
- **Description:** Serif, 13-14px, text block
- **Bar labels:** Sans-serif, 9-10px, positioned along bars
- **Axis labels:** Sans-serif, 11px, at bottom of each bar

## Color Palette

Muted earth tones (transit line inspired):
- Canvas: #E8DFD0 (warm tan/cream)
- Text primary: #2C2C2C
- Text secondary: #6B5E50
- Bar colors (rotate through):
  - #D4A574 (tan/peach)
  - #C4956A (orange-tan)
  - #8B9E7C (sage green)
  - #A89B8B (warm gray)
  - #9E7B6B (terracotta)
  - #7B8FA1 (muted blue)
  - #A67C5B (brown)
  - #6B8E8E (teal)

## Layout: bars

Vertical bars arranged horizontally, ranked by value (shortest to tallest or vice versa).

### Extraction Schema

```typescript
{
  layout: "bars"
  title: string              // Main title (uppercase)
  subtitle?: string          // Byline or source
  description?: string       // Explanatory text block
  bars: [{
    label: string            // Bar name (shown at bottom)
    value: number            // Determines bar height
    color?: string           // Override bar color
    ticks?: [{               // Horizontal tick marks
      position: number       // 0-100 percentage up the bar
      label: string          // Tick label
    }]
  }]
  sortOrder?: "asc" | "desc" // Default: "asc" (shortest to tallest left-to-right)
}
```

### SVG Template

```svg
<svg width="800" height="1200" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="800" height="1200" fill="#E8DFD0"/>

  <!-- Title block (top left) -->
  <text x="60" y="80" fill="#2C2C2C" font-size="14" font-family="Helvetica, sans-serif" letter-spacing="3">
    <tspan text-decoration="underline">TRANSIT CHARTS</tspan>
    <tspan dx="10" font-style="italic" font-family="Georgia, serif" font-size="11">by Author</tspan>
  </text>

  <text x="60" y="120" fill="#2C2C2C" font-size="42" font-weight="bold" font-family="Georgia, serif">TITLE</text>

  <!-- Description text block -->
  <text x="60" y="170" fill="#2C2C2C" font-size="13" font-family="Georgia, serif">
    <tspan x="60" dy="0">Description line 1</tspan>
    <tspan x="60" dy="18">Description line 2</tspan>
  </text>

  <!-- Bars (positioned from bottom) -->
  <!-- Bar 1 (shortest, leftmost) -->
  <rect x="60" y="800" width="80" height="300" fill="#D4A574"/>

  <!-- Tick marks on bar -->
  <line x1="60" y1="750" x2="140" y2="750" stroke="#2C2C2C" stroke-width="0.5"/>
  <text x="145" y="753" fill="#2C2C2C" font-size="9" font-family="Helvetica, sans-serif">Station Name</text>

  <!-- Bar label at bottom -->
  <text x="100" y="1120" text-anchor="middle" fill="#2C2C2C" font-size="11" font-family="Helvetica, sans-serif">LINE NAME</text>

  <!-- More bars... -->
</svg>
```

## Layout Notes
- Bars start from same baseline (bottom)
- Bar width: 60-100px depending on count
- Gap between bars: 10-20px
- Tick marks extend slightly beyond bar edge
- Tick labels right-aligned on left side of bar, or left-aligned on right
- Title block positioned top-left with description below
- Sort bars by value (typically ascending left-to-right)
- Height scale: normalize to available vertical space

## Height Calculation
- Canvas height: 1000-1400px (tall format)
- Title area: ~200px
- Bar area: remaining space minus 100px bottom margin
- Max bar height: barArea height
- Other bars scaled proportionally
