# Style: preston

Process/flowchart with numbered steps and connecting arrows. Soft, approachable style derived from olive.

## Typography
- **Headings:** system-ui, -apple-system, sans-serif — medium weight (500)
- **Body:** system-ui, -apple-system, sans-serif — regular weight (400), line-height 1.5
- **Step numbers:** Sans-serif, bold, 18-20px (white on dark circle)
- **Step titles:** Sans-serif, bold, 16-18px
- **Step descriptions:** Sans-serif, 13-14px

## Color Palette

Warm earth tones (olive-derived):
- Canvas: #F5F0E6 (warm cream)
- Primary card: #7D8B6E (olive/sage green)
- Secondary card: #E8E2D4 (light tan/beige)
- Text dark: #2C2C2C (near-black)
- Text light: #FAFAF8 (off-white, for dark cards)
- Text muted: #6B6B6B (medium gray)
- Number circle: #4A6741 (darker green)
- Arrow/connector: #2C2C2C

## Visual Elements
- **Rounded corners:** rx="16" for cards
- **Number circles:** 40px diameter, white text on dark circle
- **Shadows:** `<filter id="shadow"><feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.1"/></filter>`
- **Curved arrows:** Quadratic bezier paths connecting steps
- **Arrow heads:** Small triangular markers

## Layout: process

Steps connected by arrows, horizontal or vertical arrangement.

### Extraction Schema

```typescript
{
  layout: "process"
  title?: string             // Optional main title
  steps: [{
    number: number           // Step number (1, 2, 3...)
    label: string            // Step name/title
    description?: string     // Detail text (1-2 sentences)
    icon?: string            // Icon hint (optional)
  }]
  direction?: "horizontal" | "vertical"  // Default: "horizontal"
}
```

### SVG Template (Horizontal, 4 steps)

```svg
<svg width="1000" height="400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.1"/>
    </filter>
    <!-- Arrow marker -->
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#2C2C2C"/>
    </marker>
  </defs>

  <!-- Canvas -->
  <rect width="1000" height="400" fill="#F5F0E6"/>

  <!-- Optional title -->
  <text x="500" y="45" text-anchor="middle" fill="#2C2C2C" font-size="24" font-weight="500" font-family="system-ui">How to Deploy Your App</text>

  <!-- Step 1 (primary color) -->
  <rect x="30" y="80" width="200" height="280" rx="16" fill="#7D8B6E" filter="url(#shadow)"/>

  <!-- Number circle -->
  <circle cx="130" cy="130" r="24" fill="#4A6741"/>
  <text x="130" y="138" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">1</text>

  <!-- Step title and description -->
  <text x="130" y="180" text-anchor="middle" fill="#FAFAF8" font-size="16" font-weight="bold" font-family="system-ui">Prepare Code</text>
  <text x="130" y="210" text-anchor="middle" fill="#FAFAF8" font-size="13" font-family="system-ui">
    <tspan x="130" dy="0">Review your code and</tspan>
    <tspan x="130" dy="18">ensure tests pass.</tspan>
  </text>

  <!-- Arrow from step 1 to step 2 -->
  <path d="M230,220 Q255,220 270,220" fill="none" stroke="#2C2C2C" stroke-width="2" marker-end="url(#arrowhead)"/>

  <!-- Step 2 (secondary color) -->
  <rect x="280" y="80" width="200" height="280" rx="16" fill="#E8E2D4" filter="url(#shadow)"/>

  <!-- Number circle -->
  <circle cx="380" cy="130" r="24" fill="#4A6741"/>
  <text x="380" y="138" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">2</text>

  <!-- Step title and description (dark text on light card) -->
  <text x="380" y="180" text-anchor="middle" fill="#2C2C2C" font-size="16" font-weight="bold" font-family="system-ui">Build Project</text>
  <text x="380" y="210" text-anchor="middle" fill="#2C2C2C" font-size="13" font-family="system-ui">
    <tspan x="380" dy="0">Run build command to</tspan>
    <tspan x="380" dy="18">generate production assets.</tspan>
  </text>

  <!-- Arrow from step 2 to step 3 -->
  <path d="M480,220 Q505,220 520,220" fill="none" stroke="#2C2C2C" stroke-width="2" marker-end="url(#arrowhead)"/>

  <!-- Step 3 (primary color) -->
  <rect x="530" y="80" width="200" height="280" rx="16" fill="#7D8B6E" filter="url(#shadow)"/>

  <!-- Number circle -->
  <circle cx="630" cy="130" r="24" fill="#4A6741"/>
  <text x="630" y="138" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">3</text>

  <text x="630" y="180" text-anchor="middle" fill="#FAFAF8" font-size="16" font-weight="bold" font-family="system-ui">Deploy</text>
  <text x="630" y="210" text-anchor="middle" fill="#FAFAF8" font-size="13" font-family="system-ui">
    <tspan x="630" dy="0">Push to production</tspan>
    <tspan x="630" dy="18">environment.</tspan>
  </text>

  <!-- Arrow from step 3 to step 4 -->
  <path d="M730,220 Q755,220 770,220" fill="none" stroke="#2C2C2C" stroke-width="2" marker-end="url(#arrowhead)"/>

  <!-- Step 4 (secondary color) -->
  <rect x="780" y="80" width="200" height="280" rx="16" fill="#E8E2D4" filter="url(#shadow)"/>

  <!-- Number circle -->
  <circle cx="880" cy="130" r="24" fill="#4A6741"/>
  <text x="880" y="138" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">4</text>

  <text x="880" y="180" text-anchor="middle" fill="#2C2C2C" font-size="16" font-weight="bold" font-family="system-ui">Verify</text>
  <text x="880" y="210" text-anchor="middle" fill="#2C2C2C" font-size="13" font-family="system-ui">
    <tspan x="880" dy="0">Check deployment and</tspan>
    <tspan x="880" dy="18">monitor for errors.</tspan>
  </text>
</svg>
```

### SVG Template (Vertical, 4 steps)

```svg
<svg width="600" height="900" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.1"/>
    </filter>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#2C2C2C"/>
    </marker>
  </defs>

  <!-- Canvas -->
  <rect width="600" height="900" fill="#F5F0E6"/>

  <!-- Optional title -->
  <text x="300" y="50" text-anchor="middle" fill="#2C2C2C" font-size="24" font-weight="500" font-family="system-ui">Process Title</text>

  <!-- Step 1 -->
  <rect x="50" y="80" width="500" height="150" rx="16" fill="#7D8B6E" filter="url(#shadow)"/>
  <circle cx="100" cy="155" r="24" fill="#4A6741"/>
  <text x="100" y="163" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">1</text>
  <text x="150" y="140" fill="#FAFAF8" font-size="16" font-weight="bold" font-family="system-ui">Step Title</text>
  <text x="150" y="170" fill="#FAFAF8" font-size="13" font-family="system-ui">Description text here.</text>

  <!-- Arrow down -->
  <path d="M300,230 Q300,250 300,260" fill="none" stroke="#2C2C2C" stroke-width="2" marker-end="url(#arrowhead)"/>

  <!-- Step 2 -->
  <rect x="50" y="280" width="500" height="150" rx="16" fill="#E8E2D4" filter="url(#shadow)"/>
  <circle cx="100" cy="355" r="24" fill="#4A6741"/>
  <text x="100" y="363" text-anchor="middle" fill="#FAFAF8" font-size="20" font-weight="bold" font-family="system-ui">2</text>
  <text x="150" y="340" fill="#2C2C2C" font-size="16" font-weight="bold" font-family="system-ui">Step Title</text>
  <text x="150" y="370" fill="#2C2C2C" font-size="13" font-family="system-ui">Description text here.</text>

  <!-- More steps... -->
</svg>
```

## Layout Notes
- Horizontal (default): 1000x400 for 3-5 steps
- Vertical: 600x900 for 4-6 steps
- Card width: 180-220px (horizontal), 500px (vertical)
- Card height: 280px (horizontal), 150px (vertical)
- Gap between cards: 30-50px (arrow space)
- Number circles: 40-48px diameter
- Alternate primary/secondary colors for visual rhythm
- Arrows use bezier curves for smooth connections

## Sizing by Step Count
- 3 steps horizontal: 800x400
- 4 steps horizontal: 1000x400
- 5 steps horizontal: 1200x400
- 4 steps vertical: 600x900
- 5 steps vertical: 600x1100
- 6 steps vertical: 600x1300

## Detection
Content that matches process layout:
- "how to", "steps to", "guide to"
- Numbered lists (1. 2. 3. or Step 1, Step 2)
- "workflow", "process", "procedure"
- Sequential actions with clear ordering
- "first... then... finally..."
