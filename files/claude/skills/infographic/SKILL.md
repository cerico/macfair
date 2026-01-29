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
```

Then paste or describe your content when prompted.

Or provide text directly:
```
/infographic "Your article or content here..."
/infographic nico "Your article or content here..."
```

## Style Resolution

The first argument (if not quoted text) is treated as a style name. Default: `c82`.

Loading order:
1. Load `styles/<name>.md` from this skill directory
2. If the style declares `inherits: design:<name>`, also load `design/<name>/SKILL.md` from the skills directory
3. Design system = foundation, infographic style = overrides

Available styles:
- **c82** (default) — Classical typography, warm cream canvas, muted naturalist palette
- **nico** — Dark forest aesthetic, luminous text, desaturated accents

## Process

1. **Resolve Style** — Determine style from arguments, load style file(s)
2. **Extract Structure** — Analyze the text and extract structured data (see schema below)
3. **Generate SVG** — Write SVG following the loaded style guide
4. **Export PNG** — Convert to high-res PNG (2000px wide)
5. **Open** — Display result for review

## Output Location

Files saved to: `~/Downloads/infographic-{timestamp}.png`

## Extraction Schema

When analyzing text, extract this structure:

```typescript
{
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

## SVG Template Structure

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

## Important Notes

- **Text wrapping:** Split long text into `<tspan>` elements with `dy="22"` for body text
- **Dynamic height:** Adjust canvas height based on content. 1100px is baseline for 3 sections
- **Section heading color:** Rotate through accent colors for section headings
- **Stats layout:** Center N stats evenly across content width. For N stats, place stat i at x = `margin + contentWidth/(2*N) + i*(contentWidth/N)` with `text-anchor="middle"`
- **No shadows, no gradients, no rounded corners** — clean, flat, classical
- All styles inline (SVG has no external CSS support via rsvg-convert)

## Conversion

After writing SVG file, convert to PNG:

```bash
rsvg-convert -w 2000 input.svg -o output.png
```

Then open:
```bash
open output.png
```

## Example

Input text about climate change would produce:
- Title in centered serif
- Styled canvas with border frame per style guide
- Sections with rotating accent-colored headings
- Large serif stat numbers
- Italic takeaway between double rules at bottom
- Overall feel varies by style: museum panel (c82), luminous dark (nico)
