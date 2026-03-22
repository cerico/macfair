#!/usr/bin/env python3
"""Generate KM16 Pro infographic from karabiner.json rules."""

import json
import re
import sys
from datetime import datetime
from pathlib import Path

KARABINER = Path(__file__).parent.parent / "karabiner" / "karabiner.json"
OUTPUT = Path(__file__).parent / "index.html"

PHYSICAL_LAYOUT = [
    ["1", "2", "3", "4"],
    ["5", "6", "7", "8"],
    ["9", "0", "up_arrow", "return_or_enter"],
    ["fn", "left_arrow", "down_arrow", "right_arrow"],
]

DISPLAY_LABELS = {
    "up_arrow": "&uarr;",
    "down_arrow": "&darr;",
    "left_arrow": "&larr;",
    "right_arrow": "&rarr;",
    "return_or_enter": "Enter",
    "fn": "Fn",
}

FRIENDLY = {
    "/speak + start whisper": ("/speak", "+ whisper"),
    "Whisper toggle": ("Whisper", "toggle"),
    "/commit": ("/commit", None),
    "/clear": ("/clear", None),
    "Focus WezTerm": ("WezTerm", "focus"),
    "Cycle WezTerm pane": ("Cycle", "pane"),
    "Cycle app windows (⌘`)": ("Cycle", "windows"),
    "New WezTerm window": ("WezTerm", "new window"),
    "Jump to Desktop 9": ("Desktop", "9"),
    "Jump to Desktop 16": ("Desktop", "16"),
    "Jump to Desktop 1": ("Desktop", "1"),
    "Previous desktop": ("Prev", "desktop"),
    "Next desktop": ("Next", "desktop"),
    "Ctrl+C interrupt → return": ("Ctrl+C", None),
    "Open Vivaldi → return": ("Vivaldi", None),
    "Open Firefox → return": ("Firefox", None),
    "Open Safari → return": ("Safari", None),
    "Open Linear → return": ("Linear", None),
    "Open Slack → return": ("Slack", None),
    "Open Obsidian → return": ("Obsidian", None),
}

LAYER_TOGGLE_RE = re.compile(r"Enter Layer 1")


def parse_rules(path):
    with open(path) as f:
        config = json.load(f)

    layers = {0: {}, 1: {}}
    layer_toggle_key = None

    for profile in config.get("profiles", []):
        for rule in profile.get("complex_modifications", {}).get("rules", []):
            desc = rule.get("description", "")
            m = re.match(r"KM16 L(\d): (.+?) — (.+)", desc)
            if not m:
                continue
            layer = int(m.group(1))
            key = m.group(2)
            action = m.group(3)

            if LAYER_TOGGLE_RE.search(action):
                layer_toggle_key = key

            layers[layer][key] = action

    return layers, layer_toggle_key


def render_key_l0(key, label, action, is_toggle):
    if key in ("return_or_enter", "fn"):
        if key == "fn":
            return (
                '          <div class="bg-black text-cream/30 border-4 border-black/30 '
                'p-4 aspect-square flex flex-col justify-between">\n'
                f'            <span class="text-xs">{label}</span>\n'
                '            <p class="text-xs italic">firmware</p>\n'
                '          </div>'
            )
        return (
            '          <div class="bg-black text-cream/30 border-4 border-black/30 '
            'p-4 aspect-square flex flex-col justify-between">\n'
            f'            <span class="text-xs">{label}</span>\n'
            '            <p class="text-xs italic">enter</p>\n'
            '          </div>'
        )

    if is_toggle:
        title, subtitle = "Layer 1", "app launcher"
        return (
            '          <div class="bg-black text-gold border-4 border-gold '
            'p-4 aspect-square flex flex-col justify-between">\n'
            f'            <span class="text-xs text-gold/50">{label}</span>\n'
            '            <div>\n'
            f'              <p class="text-sm font-bold">{title}</p>\n'
            f'              <p class="text-xs text-gold/60">{subtitle}</p>\n'
            '            </div>\n'
            '          </div>'
        )

    if not action:
        return (
            '          <div class="bg-black text-cream/30 border-4 border-black/30 '
            'p-4 aspect-square flex flex-col justify-between">\n'
            f'            <span class="text-xs">{label}</span>\n'
            '            <p class="text-xs italic">unmapped</p>\n'
            '          </div>'
        )

    title, subtitle = FRIENDLY.get(action, (action, None))
    sub_html = ""
    if subtitle:
        sub_html = f'\n              <p class="text-xs text-cream/60">{subtitle}</p>'

    return (
        '          <div class="bg-black text-cream border-4 border-black '
        'p-4 aspect-square flex flex-col justify-between">\n'
        f'            <span class="text-xs text-cream/50">{label}</span>\n'
        '            <div>\n'
        f'              <p class="text-sm font-bold">{title}</p>{sub_html}\n'
        '            </div>\n'
        '          </div>'
    )


def render_key_l1(key, label, action):
    if key in ("return_or_enter", "fn"):
        cls = "bg-cream text-black/30 border-4 border-black/10"
        inner = "firmware" if key == "fn" else "unmapped"
        return (
            f'          <div class="{cls} '
            'p-4 aspect-square flex flex-col justify-between">\n'
            f'            <span class="text-xs">{label}</span>\n'
            f'            <p class="text-xs italic">{inner}</p>\n'
            '          </div>'
        )

    if not action:
        return (
            '          <div class="bg-cream text-black/30 border-4 border-black/10 '
            'p-4 aspect-square flex flex-col justify-between">\n'
            f'            <span class="text-xs">{label}</span>\n'
            '            <p class="text-xs italic">unmapped</p>\n'
            '          </div>'
        )

    title, subtitle = FRIENDLY.get(action, (action, None))
    sub_html = ""
    if subtitle:
        sub_html = f'\n              <p class="text-xs text-black/60">{subtitle}</p>'

    return (
        '          <div class="bg-pink text-black border-4 border-red '
        'p-4 aspect-square flex flex-col justify-between">\n'
        f'            <span class="text-xs text-black/40">{label}</span>\n'
        '            <div>\n'
        f'              <p class="text-sm font-bold">{title}</p>{sub_html}\n'
        '            </div>\n'
        '          </div>'
    )


def render_grid(layer_data, layer_num, toggle_key):
    keys = []
    for row in PHYSICAL_LAYOUT:
        for key in row:
            label = DISPLAY_LABELS.get(key, key)
            action = layer_data.get(key) or layer_data.get(label)
            is_toggle = layer_num == 0 and key == toggle_key
            if layer_num == 0:
                keys.append(render_key_l0(key, label, action, is_toggle))
            else:
                keys.append(render_key_l1(key, label, action))
    return "\n".join(keys)


def generate(layers, toggle_key):
    now = datetime.now().strftime("%-d %B %Y")
    l0_grid = render_grid(layers[0], 0, toggle_key)
    l1_grid = render_grid(layers[1], 1, toggle_key)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>KM16 Pro Key Map</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:ital,wght@0,400;0,700;1,400&display=swap">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    :root {{
      --cream: #f5f3e8;
      --black: #222;
      --red: #db5439;
      --pink: rgba(220, 84, 57, 0.5);
      --gold: #eebe6d;
    }}
  </style>
  <script>
    tailwind.config = {{
      theme: {{
        fontFamily: {{
          serif: ['"Libre Baskerville"', 'Georgia', 'serif'],
        }},
        extend: {{
          colors: {{
            cream: 'var(--cream)',
            black: 'var(--black)',
            red: 'var(--red)',
            pink: 'var(--pink)',
            gold: 'var(--gold)',
          }}
        }}
      }}
    }}
  </script>
</head>
<body class="bg-cream text-black font-serif min-h-screen">
  <div class="max-w-4xl mx-auto px-8 py-16">
    <header class="mb-12">
      <h1 class="text-2xl font-bold uppercase tracking-wide">KM16 Pro Key Map</h1>
      <p class="text-sm mt-2 italic text-black/70">Software layers via Karabiner Elements. Key {toggle_key} enters Layer 1; actions auto-return to Layer 0. 5s timeout.</p>
    </header>

    <main>
      <section class="mb-12">
        <h2 class="text-lg font-bold uppercase tracking-wide mb-6">Layer 0 <span class="text-xs font-bold bg-gold text-black px-2 py-1 ml-2">Default</span></h2>
        <div class="grid grid-cols-4 gap-3">
{l0_grid}
        </div>
      </section>

      <hr class="my-8 border-black">

      <section class="mb-12">
        <h2 class="text-lg font-bold uppercase tracking-wide mb-6">Layer 1 <span class="text-xs font-bold bg-red text-cream px-2 py-1 ml-2">App Launcher</span></h2>
        <div class="border-l-4 border-red pl-4 mb-6 py-2 pr-4">
          <p class="text-sm italic">Press key {toggle_key} to enter. Each action auto-returns to Layer 0. Times out after 5 seconds.</p>
        </div>
        <div class="grid grid-cols-4 gap-3">
{l1_grid}
        </div>
      </section>

      <hr class="my-8 border-black">

      <section>
        <h2 class="text-lg font-bold uppercase tracking-wide mb-4">Connection</h2>
        <dl class="space-y-2 text-sm">
          <div class="flex gap-4">
            <dt class="font-semibold min-w-32">Fn + 1</dt>
            <dd>Bluetooth 1</dd>
          </div>
          <div class="flex gap-4">
            <dt class="font-semibold min-w-32">Fn + 2</dt>
            <dd>Bluetooth 2 (pairing)</dd>
          </div>
          <div class="flex gap-4">
            <dt class="font-semibold min-w-32">Fn + 3</dt>
            <dd>Bluetooth 3</dd>
          </div>
          <div class="flex gap-4">
            <dt class="font-semibold min-w-32">Fn + 4</dt>
            <dd>2.4G dongle</dd>
          </div>
          <div class="flex gap-4">
            <dt class="font-semibold min-w-32">USB cable</dt>
            <dd>Charge only (data not working)</dd>
          </div>
          <div class="flex gap-4">
            <dt class="font-semibold min-w-32">Big button</dt>
            <dd>Hardware layer cycle (LED color, no keycode sent)</dd>
          </div>
        </dl>
      </section>
    </main>

    <footer class="mt-16 pt-8 border-t border-black/20 text-sm text-black/60">
      Generated {now}
    </footer>
  </div>
</body>
</html>
"""


def main():
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else KARABINER
    layers, toggle_key = parse_rules(src)
    html = generate(layers, toggle_key)
    OUTPUT.write_text(html)
    print(f"Generated {OUTPUT}")


if __name__ == "__main__":
    main()
