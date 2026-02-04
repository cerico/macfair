---
name: infographic
description: Generate infographics from text. Extracts key info, renders SVG, exports PNG. Uses Claude Code (no API costs).
---

# Infographic Generator

Transform any text into a print-quality infographic PNG.

## Usage

```
/infographic
/infographic nico
/infographic olive
/infographic werner
/infographic transit
/infographic parks
/infographic euclid
/infographic timber
/infographic preston
```

Then paste or describe your content when prompted.

Or provide text directly:
```
/infographic "Your article or content here..."
/infographic olive "When should I use X vs Y?"
/infographic werner "List the primary colors with examples"
/infographic transit "Rank the tallest buildings in NYC"
/infographic parks "Compare 3 national parks with stats"
/infographic euclid "Overview of geometry concepts"
/infographic timber "History of JavaScript frameworks"
/infographic preston "How to deploy a Next.js app"
```

## Palettes

Palettes control colors independently from styles. Mix and match any style with any palette.

### Usage

```bash
# Style with default palette
/infographic olive "..."

# Style with specific palette
/infographic olive:nordic "..."
/infographic olive --palette nordic "..."
```

### Available Palettes

| Palette | Canvas | Description |
|---------|--------|-------------|
| **earth** | light | Warm cream with sage accents (default) |
| **nordic** | dark | Cool blue-gray, frost accents |
| **desert** | light | Sandy tones, terracotta accents |
| **ocean** | light | Pale blue-gray, teal accents |
| **forest** | dark | Deep greens, moss accents |

### Default Palette Mapping

| Style | Default Palette |
|-------|-----------------|
| olive | earth |
| c82 | earth |
| nico | earth |
| werner | earth |
| transit | earth |
| parks | forest |
| euclid | earth |
| timber | earth |
| preston | earth |

### Compatibility

Styles declare a canvas preference (`light`, `dark`, or `any`). When a style's preference conflicts with a palette's canvas type:
- Warning is shown
- Text colors swap to `text.onDark`/`text.onLight` for readability

### Token Reference

Styles use these tokens (resolved from the active palette):

| Token | SVG Placeholder | Usage |
|-------|-----------------|-------|
| `{canvas}` | `{canvasColor}` | Background fill |
| `{text.primary}` | `{textColor}` | Main headings/body |
| `{text.secondary}` | `{secondaryColor}` | Supporting text |
| `{text.muted}` | `{mutedColor}` | Subtle labels |
| `{text.onDark}` | `{textOnDark}` | Text on dark cards |
| `{text.onLight}` | `{textOnLight}` | Text on light cards |
| `{accents[0-3]}` | `{accentColor}` | Accent color (rotate through array) |
| `{cards.primary}` | `{primaryCard}` | Main card fill |
| `{cards.secondary}` | `{secondaryCard}` | Secondary card fill |
| `{rules}` | `{ruleColor}` | Divider lines |

---

## Style Resolution

The first argument (if not quoted text) is treated as a style name. Default: `c82`.

Loading order:
1. Load `styles/<name>.md` from this skill directory
2. If the style declares `inherits: design:<name>`, also load `design/<name>/SKILL.md` from the skills directory
3. Design system = foundation, infographic style = overrides

Available styles:
- **c82** (default) — Classical typography, warm cream canvas, muted naturalist palette. Best for stat-blocks.
- **nico** — Dark forest aesthetic, luminous text, desaturated accents. Best for stat-blocks.
- **olive** — Soft earth tones, rounded cards, shadows. Best for decision trees and comparisons.
- **werner** — Classical catalog/table layout with swatches and multiple columns. Best for catalogs, reference charts.
- **transit** — Vertical bar chart with tick marks, ranked data. Best for comparisons by quantity.
- **parks** — Dark dashboard with colored tile grid, icons + values. Best for multi-stat comparisons.
- **euclid** — Bauhaus-colored gallery grid with geometric illustrations. Best for visual item galleries.
- **timber** — Vertical timeline with spine and alternating event cards. Best for chronological histories.
- **preston** — Process flowchart with numbered steps and connecting arrows. Best for how-to guides.

## Process

1. **Resolve Style** — Determine style from arguments, load style file(s)
2. **Detect Layout** — Analyze content to determine best layout type
3. **Extract Structure** — Extract structured data matching the detected layout
4. **Generate SVG** — Write SVG following the loaded style guide
5. **Export PNG** — Convert to high-res PNG (2000px wide)
6. **Open** — Display result for review

## Output Location

Files saved to: `~/Downloads/infographic-{timestamp}.png`

---

## Layout Detection

Analyze the input content and select the appropriate layout:

| Content Pattern | Layout | Best Styles |
|-----------------|--------|-------------|
| "If X then Y", "When to use", yes/no questions, binary choices | decision-tree | olive |
| "A vs B", comparing options, pros/cons, alternatives | comparison | olive |
| Statistics, key findings, sections, summaries | stat-block | c82, nico |
| Lists with multiple attributes, color palettes, specifications | catalog | werner |
| Ranked quantities, lengths, heights, counts to compare | bars | transit |
| Items with multiple numeric stats, dashboards | tiles | parks |
| Visual items with illustrations/icons and captions | gallery | euclid |
| Chronological events, history, evolution, milestones | timeline | timber |
| Sequential steps, how-to guides, workflows, processes | process | preston |

**Detection rules:**
1. If content asks a question with two distinct answer paths → `decision-tree`
2. If content compares 2-4 distinct options/approaches → `comparison`
3. If content lists items with multiple attributes per item (colors, specs) → `catalog`
4. If content ranks items by a single quantity (height, length, count) → `bars`
5. If content shows multiple numeric stats per item (dashboard style) → `tiles`
6. If content presents visual items with labels/descriptions → `gallery`
7. If content has chronological events with dates/years → `timeline`
8. If content describes sequential steps or a process → `process`
9. Otherwise → `stat-block` (default)

**Style-layout affinity:**
- `olive` style defaults to auto-detecting between decision-tree/comparison
- `werner` style defaults to catalog layout
- `transit` style defaults to bars layout
- `parks` style defaults to tiles layout
- `euclid` style defaults to gallery layout
- `timber` style defaults to timeline layout
- `preston` style defaults to process layout
- `c82` and `nico` styles default to stat-block layout

---

## Layout: stat-block (default)

Classical infographic with sections, stats, and key takeaway.

### Extraction Schema

```typescript
{
  layout: "stat-block"
  title: string          // Main title, 3-10 words
  subtitle?: string      // Optional tagline
  sections: [{           // 2-4 sections
    heading: string      // Section heading, 3-8 words
    content: string      // 1-2 sentences max
    stats?: [{           // Up to 3 stats per section
      value: string      // e.g. "85%", "1.2M"
      label: string      // What it represents
    }]
  }]
  keyTakeaway: string    // Single most important insight
}
```

### SVG Template Structure

```svg
<svg width="800" height="1100" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas background -->
  <rect width="800" height="1100" fill="{canvasColor}"/>

  <!-- Border frame -->
  <rect x="{inset}" y="{inset}" width="{w-2*inset}" height="{h-2*inset}" fill="none" stroke="{ruleColor}" stroke-width="1"/>

  <!-- Header area (centered) -->
  <text x="400" y="100" text-anchor="middle" fill="{textColor}" font-size="36" font-weight="bold" font-family="{headingFont}">{title}</text>
  <text x="400" y="132" text-anchor="middle" fill="{mutedColor}" font-size="16" font-style="italic" font-family="{headingFont}">{subtitle}</text>

  <!-- Divider under header -->
  <line x1="200" y1="160" x2="600" y2="160" stroke="{ruleColor}" stroke-width="0.5"/>

  <!-- Section (repeat for each) -->
  <text x="{margin}" y="210" fill="{accentColor}" font-size="13" font-family="{labelFont}" letter-spacing="2">{SECTION HEADING}</text>
  <text x="{margin}" y="236" fill="{textColor}" font-size="15" font-family="{bodyFont}" line-height="1.6">
    <tspan x="{margin}" dy="0">{contentLine1}</tspan>
    <tspan x="{margin}" dy="22">{contentLine2}</tspan>
  </text>

  <!-- Stats row -->
  <text x="{statX}" y="300" text-anchor="middle" fill="{textColor}" font-size="48" font-family="{headingFont}">{statValue}</text>
  <line x1="{ruleX1}" y1="308" x2="{ruleX2}" y2="308" stroke="{ruleColor}" stroke-width="0.5"/>
  <text x="{statX}" y="324" text-anchor="middle" fill="{mutedColor}" font-size="11" font-family="{labelFont}" letter-spacing="2">{STAT LABEL}</text>

  <!-- Section divider -->
  <line x1="{margin}" y1="360" x2="{margin+contentWidth}" y2="360" stroke="{ruleColor}" stroke-width="0.5"/>

  <!-- Key Takeaway (bottom) -->
  <line x1="200" y1="980" x2="600" y2="980" stroke="{ruleColor}" stroke-width="0.5"/>
  <line x1="200" y1="983" x2="600" y2="983" stroke="{ruleColor}" stroke-width="0.5"/>
  <text x="400" y="1020" text-anchor="middle" fill="{mutedColor}" font-size="14" font-style="italic" font-family="{headingFont}">{keyTakeaway}</text>
</svg>
```

---

## Layout: decision-tree

Binary choice flowchart with question bubble and two branch cards.

### Extraction Schema

```typescript
{
  layout: "decision-tree"
  question: string           // The decision point (displayed in bubble)
  branches: [{
    label: string            // "YES" / "NO" or custom labels
    title: string            // Branch heading (e.g., "Use Perplexity")
    description: string      // Supporting explanation (1-2 sentences)
    bullets?: string[]       // Optional 2-4 bullet points
    icon?: string            // Icon hint: search, document, data, draft, etc.
  }, {
    // Second branch (same structure)
  }]
}
```

### SVG Template (olive style)

```svg
<svg width="800" height="620" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.1"/>
    </filter>
  </defs>

  <!-- Canvas -->
  <rect width="800" height="620" fill="#F5F0E6"/>

  <!-- Question bubble (top center) -->
  <rect x="140" y="30" width="520" height="70" rx="35" fill="#FAFAF8" filter="url(#shadow)" stroke="#2C2C2C" stroke-width="1"/>
  <text x="400" y="72" text-anchor="middle" fill="#2C2C2C" font-size="18" font-weight="500" font-family="system-ui">{question}</text>

  <!-- Curved arrows from bubble to cards -->
  <path d="M280,100 Q280,140 200,180" fill="none" stroke="#2C2C2C" stroke-width="1.5"/>
  <path d="M520,100 Q520,140 600,180" fill="none" stroke="#2C2C2C" stroke-width="1.5"/>

  <!-- Arrow heads -->
  <polygon points="195,175 205,185 210,172" fill="#2C2C2C"/>
  <polygon points="605,175 595,185 590,172" fill="#2C2C2C"/>

  <!-- Branch labels -->
  <text x="220" y="145" text-anchor="middle" fill="#7D8B6E" font-size="14" font-weight="bold" font-family="system-ui">{branch1.label}</text>
  <text x="580" y="145" text-anchor="middle" fill="#7D8B6E" font-size="14" font-weight="bold" font-family="system-ui">{branch2.label}</text>

  <!-- Left card (primary color) -->
  <rect x="30" y="190" width="360" height="400" rx="16" fill="#7D8B6E" filter="url(#shadow)"/>

  <!-- Left icon circle -->
  <circle cx="80" cy="240" r="24" fill="#FAFAF8"/>
  <!-- Icon path goes here -->

  <!-- Left card content -->
  <text x="120" y="248" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">{branch1.title}</text>
  <text x="50" y="290" fill="#FAFAF8" font-size="14" font-family="system-ui">
    <tspan x="50" dy="0">{description line 1}</tspan>
    <tspan x="50" dy="22">{description line 2}</tspan>
  </text>
  <!-- Bullets -->
  <text x="50" y="360" fill="#FAFAF8" font-size="14" font-family="system-ui">
    <tspan x="50" dy="0">• {bullet1}</tspan>
    <tspan x="50" dy="24">• {bullet2}</tspan>
    <tspan x="50" dy="24">• {bullet3}</tspan>
  </text>

  <!-- Right card (secondary color) -->
  <rect x="410" y="190" width="360" height="400" rx="16" fill="#E8E2D4" filter="url(#shadow)"/>

  <!-- Right icon circle -->
  <circle cx="460" cy="240" r="24" fill="#FAFAF8"/>
  <!-- Icon path goes here -->

  <!-- Right card content (dark text) -->
  <text x="500" y="248" fill="#2C2C2C" font-size="20" font-weight="bold" font-family="system-ui">{branch2.title}</text>
  <!-- ... same structure as left card but with #2C2C2C text -->
</svg>
```

---

## Layout: comparison

Side-by-side comparison cards for 2-4 options.

### Extraction Schema

```typescript
{
  layout: "comparison"
  title?: string             // Optional main title above cards
  items: [{
    heading: string          // Option name (e.g., "React", "Vue")
    description: string      // Brief description (1-2 sentences)
    bullets?: string[]       // Optional 2-4 key points
    color: "primary" | "secondary"  // Card color alternation
    icon?: string            // Icon hint
  }]
}
```

### SVG Template (olive style, 2 items)

```svg
<svg width="800" height="520" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.1"/>
    </filter>
  </defs>

  <!-- Canvas -->
  <rect width="800" height="520" fill="#F5F0E6"/>

  <!-- Optional title -->
  <text x="400" y="50" text-anchor="middle" fill="#2C2C2C" font-size="24" font-weight="500" font-family="system-ui">{title}</text>

  <!-- Card 1 (primary) -->
  <rect x="30" y="80" width="360" height="410" rx="16" fill="#7D8B6E" filter="url(#shadow)"/>
  <circle cx="80" cy="130" r="24" fill="#FAFAF8"/>
  <!-- Icon -->
  <text x="120" y="138" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">{item1.heading}</text>
  <text x="50" y="180" fill="#FAFAF8" font-size="14" font-family="system-ui">
    <tspan x="50" dy="0">{description}</tspan>
  </text>
  <text x="50" y="240" fill="#FAFAF8" font-size="14" font-family="system-ui">
    <tspan x="50" dy="0">• {bullet1}</tspan>
    <tspan x="50" dy="24">• {bullet2}</tspan>
  </text>

  <!-- Card 2 (secondary) -->
  <rect x="410" y="80" width="360" height="410" rx="16" fill="#E8E2D4" filter="url(#shadow)"/>
  <circle cx="460" cy="130" r="24" fill="#FAFAF8"/>
  <!-- Icon -->
  <text x="500" y="138" fill="#2C2C2C" font-size="20" font-weight="bold" font-family="system-ui">{item2.heading}</text>
  <!-- ... -->
</svg>
```

### Sizing for multiple items
- 2 items: 800x520, cards 360px wide
- 3 items: 1000x520, cards 300px wide
- 4 items: 1200x520, cards 270px wide

---

## Layout: catalog

Table/catalog layout with swatches, multiple columns, and classical typography. Inspired by Werner's Nomenclature of Colours.

### Extraction Schema

```typescript
{
  layout: "catalog"
  title?: string           // Optional title above table (uppercase, letter-spaced)
  columns: string[]        // Column headers
  rows: [{
    swatch?: string        // Hex color for swatch column (optional)
    values: string[]       // Data for each column
    parts?: string[]       // Hex colors for palette dots (optional)
  }]
}
```

### SVG Template (werner style)

```svg
<svg width="900" height="{dynamicHeight}" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="900" height="{height}" fill="#F5F0E6"/>

  <!-- Title (optional) -->
  <text x="450" y="45" text-anchor="middle" fill="#2C2C2C" font-size="18" font-family="Georgia, serif" letter-spacing="4">{TITLE}</text>

  <!-- Header row with underlines -->
  <text x="60" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Color</text>
  <text x="130" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Name</text>
  <text x="280" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Animal</text>
  <text x="450" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Vegetable</text>
  <text x="620" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Mineral</text>
  <text x="790" y="90" fill="#2C2C2C" font-size="12" font-family="Georgia, serif" text-decoration="underline">Parts</text>

  <!-- Data row -->
  <rect x="60" y="110" width="50" height="60" fill="{swatchColor}" stroke="#C4B8A8" stroke-width="0.5"/>
  <text x="130" y="145" fill="#2C2C2C" font-size="14" font-family="Georgia, serif">24. Scotch Blue</text>
  <text x="280" y="145" fill="#2C2C2C" font-size="13" font-style="italic" font-family="Georgia, serif">Throat of Blue Titmouse.</text>
  <text x="450" y="145" fill="#2C2C2C" font-size="13" font-style="italic" font-family="Georgia, serif">Stamina of Single Purple Anemone.</text>
  <text x="620" y="145" fill="#2C2C2C" font-size="13" font-style="italic" font-family="Georgia, serif">Blue Copper Ore.</text>

  <!-- Parts palette dots -->
  <circle cx="795" cy="140" r="12" fill="#1a1a1a"/>
  <circle cx="823" cy="140" r="12" fill="#4a7089"/>
  <circle cx="851" cy="140" r="12" fill="#c4a5a0"/>

  <!-- Repeat rows with 80-90px vertical spacing -->
</svg>
```

### Layout Notes
- Row height: 80-90px (accommodates swatches and wrapped text)
- Swatch size: 50x60px or 60x70px
- Parts dots: 20-24px diameter, 4px gap or slight overlap
- Italics for descriptive/natural reference columns
- Number prefix for names when showing ordered items (e.g., "24. Scotch Blue")
- Add subtle row dividers (0.5px) or use whitespace (24px gap)
- Height is dynamic: `110 + (rowCount × 90)` pixels

---

## Layout: bars

Vertical bar chart with items ranked by height. Tick marks for data points along each bar.

### Extraction Schema

```typescript
{
  layout: "bars"
  title: string              // Main title
  subtitle?: string          // Byline or source
  description?: string       // Explanatory text
  bars: [{
    label: string            // Bar name (shown at bottom)
    value: number            // Determines bar height
    color?: string           // Override color
    ticks?: [{               // Horizontal tick marks
      position: number       // 0-100 percentage up the bar
      label: string          // Tick label
    }]
  }]
  sortOrder?: "asc" | "desc" // Default: "asc"
}
```

### SVG Template (transit style)

```svg
<svg width="800" height="1200" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="800" height="1200" fill="#E8DFD0"/>

  <!-- Title block -->
  <text x="60" y="80" fill="#2C2C2C" font-size="14" font-family="Helvetica, sans-serif" letter-spacing="3" text-decoration="underline">CHART TITLE</text>
  <text x="60" y="120" fill="#2C2C2C" font-size="42" font-weight="bold" font-family="Georgia, serif">Main Title</text>

  <!-- Bar (from bottom) -->
  <rect x="60" y="500" width="80" height="600" fill="#D4A574"/>

  <!-- Tick mark -->
  <line x1="60" y1="700" x2="140" y2="700" stroke="#2C2C2C" stroke-width="0.5"/>
  <text x="145" y="703" fill="#2C2C2C" font-size="9" font-family="Helvetica, sans-serif">Data point</text>

  <!-- Bar label -->
  <text x="100" y="1130" text-anchor="middle" fill="#2C2C2C" font-size="11" font-family="Helvetica, sans-serif">LABEL</text>
</svg>
```

### Layout Notes
- Tall format: 800x1200 or similar
- Bars start from same baseline
- Bar width: 60-100px, gap: 10-20px
- Sort ascending (shortest left) or descending
- Tick labels alternate sides or right-align

---

## Layout: tiles

Grid of colored tiles with icons and stat values. Dashboard-style multi-attribute display.

### Extraction Schema

```typescript
{
  layout: "tiles"
  items: [{
    title: string            // Item name
    subtitle?: string        // Location/category
    stats: [{
      icon: string           // elevation-up, elevation-down, area, calendar, people, rainfall, latitude, longitude
      value: string          // Display value
      color?: string         // Tile color
    }]
  }]
  columns?: number           // Tiles per row (default: 4)
  rows?: number              // Rows per item (default: 3)
}
```

### SVG Template (parks style)

```svg
<svg width="1200" height="500" xmlns="http://www.w3.org/2000/svg">
  <!-- Dark canvas -->
  <rect width="1200" height="500" fill="#3D2E1F"/>

  <!-- Tile -->
  <rect x="40" y="40" width="85" height="85" rx="8" fill="#6B4423"/>

  <!-- Icon (centered top) -->
  <g transform="translate(82,60)">
    <path d="M-8,4 L0,-4 L8,4" fill="none" stroke="#F5F0E6" stroke-width="3"/>
  </g>

  <!-- Value (centered bottom) -->
  <text x="82" y="105" text-anchor="middle" fill="#F5F0E6" font-size="14" font-family="Helvetica, sans-serif">10,197 ft</text>

  <!-- Item title below grid -->
  <text x="200" y="430" text-anchor="middle" fill="#F5F0E6" font-size="18" font-weight="bold" font-family="Helvetica, sans-serif">ITEM NAME</text>
  <text x="200" y="455" text-anchor="middle" fill="#F5F0E6" font-size="14" font-style="italic" font-family="Helvetica, sans-serif">Subtitle</text>
</svg>
```

### Layout Notes
- Tile size: 80-100px square
- Gap: 8-12px, corner radius: rx="8"
- Icon in upper half, value in lower half
- Dark canvas, earth-tone tiles
- Title/subtitle centered below each item's grid

---

## Layout: gallery

Grid of visual items with illustrations and captions. Bauhaus-inspired geometric compositions.

### Extraction Schema

```typescript
{
  layout: "gallery"
  title?: string             // Section title (italic, with period)
  items: [{
    label: string            // Item label (e.g., "BOOK I.")
    description: string      // Brief description
    illustration?: string    // Hint: triangle, square, circle, polygon, grid
  }]
  columns?: number           // Items per row (default: 3)
}
```

### SVG Template (euclid style)

```svg
<svg width="900" height="700" xmlns="http://www.w3.org/2000/svg">
  <!-- Cream canvas -->
  <rect width="900" height="700" fill="#F5EFE0"/>

  <!-- Title -->
  <text x="450" y="60" text-anchor="middle" fill="#2C2C2C" font-size="24" font-style="italic" font-family="Georgia, serif">TITLE.</text>

  <!-- Item illustration (Bauhaus colors) -->
  <g transform="translate(150,180)">
    <polygon points="0,-80 80,60 -80,60" fill="none" stroke="#1A1A1A" stroke-width="2"/>
    <rect x="-30" y="-20" width="40" height="40" fill="#D64045"/>
    <circle cx="20" cy="30" r="25" fill="#1B4B8A"/>
  </g>

  <!-- Caption -->
  <text x="150" y="360" text-anchor="middle" fill="#2C2C2C" font-size="16" font-family="Georgia, serif">ITEM I.</text>
  <text x="150" y="385" text-anchor="middle" fill="#2C2C2C" font-size="14" font-family="Georgia, serif">Description text</text>
</svg>
```

### Layout Notes
- Grid: typically 3 columns, 2 rows
- Illustration area: 180-220px
- Bauhaus colors: red #D64045, blue #1B4B8A, yellow #F5B800, black #1A1A1A
- Abstract geometric compositions
- Roman numerals for labels (I, II, III...)

---

## Layout: timeline

Vertical timeline with central spine and alternating event cards. Best for chronological histories.

### Extraction Schema

```typescript
{
  layout: "timeline"
  title?: string             // Optional main title
  subtitle?: string          // Optional byline or date range
  events: [{
    date: string             // Year or date (e.g., "1995", "March 2020")
    title: string            // Event title
    description: string      // Brief description (1-2 sentences)
    side?: "left" | "right"  // Override alternation
  }]
}
```

### SVG Template (timber style)

```svg
<svg width="800" height="{dynamicHeight}" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="800" height="{height}" fill="#F5F0E6"/>

  <!-- Title -->
  <text x="400" y="60" text-anchor="middle" fill="#2C2C2C" font-size="28" font-weight="bold" font-family="Georgia, serif">{title}</text>
  <text x="400" y="90" text-anchor="middle" fill="#8B7355" font-size="14" font-style="italic" font-family="Georgia, serif">{subtitle}</text>

  <!-- Central spine -->
  <line x1="400" y1="120" x2="400" y2="{spineEnd}" stroke="#8B7355" stroke-width="2"/>

  <!-- Timeline node (circle on spine) -->
  <circle cx="400" cy="180" r="8" fill="#8B7355"/>

  <!-- Date label (alternates sides) -->
  <text x="360" y="185" text-anchor="end" fill="#8B7355" font-size="14" font-weight="bold" font-family="Georgia, serif">1995</text>

  <!-- Event card (right side) -->
  <rect x="420" y="150" width="320" height="80" rx="4" fill="#FAFAF8" stroke="#D4C4A8" stroke-width="1"/>
  <text x="440" y="180" fill="#2C2C2C" font-size="16" font-weight="bold" font-family="Georgia, serif">{event.title}</text>
  <text x="440" y="205" fill="#5C5C5C" font-size="13" font-family="Georgia, serif">
    <tspan x="440" dy="0">{description line 1}</tspan>
    <tspan x="440" dy="18">{description line 2}</tspan>
  </text>

  <!-- Connector line to card -->
  <line x1="408" y1="180" x2="420" y2="180" stroke="#8B7355" stroke-width="1"/>

  <!-- Event card (left side, next event) -->
  <rect x="60" y="280" width="320" height="80" rx="4" fill="#FAFAF8" stroke="#D4C4A8" stroke-width="1"/>
  <!-- ... same structure, date on right of spine -->

  <!-- Repeat alternating pattern -->
</svg>
```

### Layout Notes
- Spine runs vertically through center
- Cards alternate left/right
- Node circles mark each event on spine
- Date labels opposite to card side
- Card height: 70-100px depending on content
- Vertical spacing: 130-160px between events
- Dynamic height: `120 + (eventCount × 150)` pixels

---

## Layout: process

Sequential flowchart with numbered steps and connecting arrows. Best for how-to guides and workflows.

### Extraction Schema

```typescript
{
  layout: "process"
  title?: string             // Optional main title
  subtitle?: string          // Optional description
  steps: [{
    number: number           // Step number (1, 2, 3...)
    title: string            // Step title
    description: string      // Brief description (1-2 sentences)
    icon?: string            // Icon hint: gear, code, check, etc.
  }]
  columns?: number           // Steps per row (default: 1 for vertical)
}
```

### SVG Template (preston style)

```svg
<svg width="800" height="{dynamicHeight}" xmlns="http://www.w3.org/2000/svg">
  <!-- Canvas -->
  <rect width="800" height="{height}" fill="#F5F0E6"/>

  <!-- Title -->
  <text x="400" y="60" text-anchor="middle" fill="#2C2C2C" font-size="28" font-weight="bold" font-family="Helvetica, sans-serif">{title}</text>
  <text x="400" y="90" text-anchor="middle" fill="#6B6B6B" font-size="14" font-family="Helvetica, sans-serif">{subtitle}</text>

  <!-- Step 1 -->
  <g transform="translate(100, 140)">
    <!-- Number circle -->
    <circle cx="30" cy="30" r="24" fill="#4A6741" stroke="none"/>
    <text x="30" y="38" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="Helvetica, sans-serif">1</text>

    <!-- Step content -->
    <text x="70" y="25" fill="#2C2C2C" font-size="18" font-weight="bold" font-family="Helvetica, sans-serif">{step.title}</text>
    <text x="70" y="50" fill="#5C5C5C" font-size="14" font-family="Helvetica, sans-serif">
      <tspan x="70" dy="0">{description line 1}</tspan>
      <tspan x="70" dy="20">{description line 2}</tspan>
    </text>
  </g>

  <!-- Connector arrow (vertical) -->
  <line x1="130" y1="220" x2="130" y2="260" stroke="#4A6741" stroke-width="2"/>
  <polygon points="130,270 125,260 135,260" fill="#4A6741"/>

  <!-- Step 2 -->
  <g transform="translate(100, 280)">
    <circle cx="30" cy="30" r="24" fill="#4A6741"/>
    <text x="30" y="38" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="Helvetica, sans-serif">2</text>
    <!-- ... same structure -->
  </g>

  <!-- Repeat for each step -->
</svg>
```

### Layout Notes
- Numbered circles (24-30px radius) on left
- Step content to right of number
- Vertical arrows connect steps
- Arrow length: 40-60px
- Step spacing: 140-160px vertical
- Accent color for numbers and arrows
- Dynamic height: `120 + (stepCount × 150)` pixels
- For horizontal layout (columns > 1): arrange in rows with horizontal arrows

---

## Icon Library

Simple SVG paths for common concepts. Use within a `<g transform="translate(x,y)">` centered in the icon circle.

### Available Icons

```svg
<!-- search: magnifying glass -->
<path d="M-6,-6 L6,6 M-4,0 a6,6 0 1,1 0,0.01" fill="none" stroke="#4A6741" stroke-width="2" stroke-linecap="round"/>

<!-- document: stacked pages -->
<path d="M-6,-8 L4,-8 L6,-6 L6,8 L-6,8 Z M-4,-5 L3,-5 M-4,-1 L3,-1 M-4,3 L1,3" fill="none" stroke="#4A6741" stroke-width="1.5" stroke-linecap="round"/>

<!-- data: circular arrows (refresh) -->
<path d="M0,-7 A7,7 0 0,1 6,3.5 M6,3.5 L4,0 M6,3.5 L9,2 M0,7 A7,7 0 0,1 -6,-3.5 M-6,-3.5 L-4,0 M-6,-3.5 L-9,-2" fill="none" stroke="#4A6741" stroke-width="1.5" stroke-linecap="round"/>

<!-- draft: pencil -->
<path d="M-6,8 L-2,8 L8,-6 L4,-6 Z M4,0 L0,0" fill="none" stroke="#4A6741" stroke-width="1.5" stroke-linejoin="round"/>

<!-- strategy: chess rook -->
<path d="M-5,8 L5,8 L5,6 L4,5 L4,2 L5,1 L5,-4 L3,-4 L3,-7 L1,-7 L1,-4 L-1,-4 L-1,-7 L-3,-7 L-3,-4 L-5,-4 L-5,1 L-4,2 L-4,5 L-5,6 Z" fill="none" stroke="#4A6741" stroke-width="1.5"/>

<!-- blocks: stacked cubes -->
<path d="M0,-8 L8,0 L0,8 L-8,0 Z M-8,0 L0,4 L8,0 M0,4 L0,8" fill="none" stroke="#4A6741" stroke-width="1.5" stroke-linejoin="round"/>

<!-- lightbulb: idea -->
<path d="M0,-8 L0,-6 M-6,-4 L-4,-3 M6,-4 L4,-3 M-4,6 L4,6 M-3,8 L3,8 M-4,2 Q-6,-2 0,-6 Q6,-2 4,2 L3,4 L-3,4 Z" fill="none" stroke="#4A6741" stroke-width="1.5" stroke-linecap="round"/>

<!-- check: checkmark in circle -->
<circle cx="0" cy="0" r="8" fill="none" stroke="#4A6741" stroke-width="1.5"/>
<path d="M-4,0 L-1,3 L5,-4" fill="none" stroke="#4A6741" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

<!-- warning: triangle exclamation -->
<path d="M0,-7 L8,7 L-8,7 Z M0,0 L0,2 M0,4 L0,5" fill="none" stroke="#4A6741" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>

<!-- code: angle brackets -->
<path d="M-3,-6 L-8,0 L-3,6 M3,-6 L8,0 L3,6" fill="none" stroke="#4A6741" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

<!-- users: two people -->
<circle cx="-3" cy="-4" r="3" fill="none" stroke="#4A6741" stroke-width="1.5"/>
<path d="M-9,6 Q-9,0 -3,0 Q3,0 3,6" fill="none" stroke="#4A6741" stroke-width="1.5"/>
<circle cx="5" cy="-2" r="2.5" fill="none" stroke="#4A6741" stroke-width="1.5"/>
<path d="M1,6 Q2,2 5,2 Q9,2 9,6" fill="none" stroke="#4A6741" stroke-width="1.5"/>

<!-- gear: cog wheel -->
<circle cx="0" cy="0" r="3" fill="none" stroke="#4A6741" stroke-width="1.5"/>
<path d="M0,-8 L0,-5 M0,5 L0,8 M-8,0 L-5,0 M5,0 L8,0 M-5.6,-5.6 L-3.5,-3.5 M3.5,3.5 L5.6,5.6 M5.6,-5.6 L3.5,-3.5 M-3.5,3.5 L-5.6,5.6" fill="none" stroke="#4A6741" stroke-width="2" stroke-linecap="round"/>

<!-- chat: speech bubble -->
<path d="M-8,-6 L8,-6 L8,4 L2,4 L-2,8 L-2,4 L-8,4 Z" fill="none" stroke="#4A6741" stroke-width="1.5" stroke-linejoin="round"/>

<!-- globe: world -->
<circle cx="0" cy="0" r="8" fill="none" stroke="#4A6741" stroke-width="1.5"/>
<path d="M-8,0 L8,0 M0,-8 Q-4,0 0,8 Q4,0 0,-8" fill="none" stroke="#4A6741" stroke-width="1"/>
```

### Icon Usage

1. Place icon circle at desired position
2. Add icon paths inside a `<g>` with `transform="translate(cx,cy)"` where cx,cy is the circle center
3. Match the icon hint from extracted data to the icon name

---

## Important Notes

- **Text wrapping:** Split long text into `<tspan>` elements with `dy="22"` for body text
- **Dynamic height:** Adjust canvas height based on content
- **stat-block notes:**
  - Section heading color: rotate through accent colors
  - Stats layout: center N stats evenly across content width
  - No shadows, no gradients, no rounded corners
  - All styles inline (SVG has no external CSS support via rsvg-convert)
- **olive layout notes:**
  - Always include shadow filter in defs
  - Primary cards use light text (#FAFAF8)
  - Secondary cards use dark text (#2C2C2C)
  - Icons centered in white circles
  - Rounded corners on all cards (rx="16")
- **werner layout notes:**
  - Serif typography throughout (Georgia)
  - Italic text for descriptive columns
  - Underlined column headers
  - Swatches need stroke if color is close to canvas
  - Parts dots can overlap slightly
- **transit layout notes:**
  - Tall format (800x1200+)
  - Bars from same baseline, sorted by value
  - Tick marks with small labels
  - Title block top-left with description
- **parks layout notes:**
  - Dark brown canvas
  - Earth-tone tiles in grid
  - Icon + value per tile
  - Light text on dark tiles, dark on light
- **euclid layout notes:**
  - Bauhaus palette: red, blue, yellow, black
  - Geometric illustrations (abstract compositions)
  - Serif italic title with period
  - Roman numeral labels

## Conversion

After writing SVG file, convert to PNG:

```bash
rsvg-convert -w 2000 input.svg -o output.png
```

Then open:
```bash
open output.png
```

## Examples

**Decision tree input:** "When should I use Perplexity vs ChatGPT?"
- Detects: decision-tree layout
- Question bubble: "When should I use Perplexity vs ChatGPT?"
- Branch 1: "Use Perplexity" with research-focused bullets
- Branch 2: "Use ChatGPT" with creative/coding bullets

**Comparison input:** "Compare React vs Vue for building web apps"
- Detects: comparison layout
- Two cards side by side with pros/features of each

**Stat-block input:** "Key findings from our user research study"
- Detects: stat-block layout (default)
- Classical sections with statistics and takeaway

**Catalog input:** "Show me the blues from Werner's color chart"
- Detects: catalog layout
- Table with color swatches, names, natural references, palette dots

**Bars input:** "Rank the 5 tallest mountains in Europe"
- Detects: bars layout
- Vertical bars sorted by height, tick marks for key elevations

**Tiles input:** "Show stats for 3 national parks: elevation, area, visitors, rainfall"
- Detects: tiles layout
- Grid of colored tiles with icons and values for each park

**Gallery input:** "Overview of the 6 books of Euclid's Elements"
- Detects: gallery layout
- Grid of geometric illustrations with captions
