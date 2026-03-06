#!/usr/bin/env python3
"""Claude skills audit — parses history.jsonl and generates a static HTML report."""

import json
import re
from collections import Counter
from datetime import datetime, timedelta
from pathlib import Path

CLAUDE_DIR = Path.home() / ".claude"
HISTORY = CLAUDE_DIR / "history.jsonl"
REPORTS_DIR = CLAUDE_DIR / "reports"
OUTPUT = REPORTS_DIR / "claudit.html"

STALE_DAYS = 30


def ordinal(day):
    if 11 <= day <= 13:
        return f"{day}th"
    return f"{day}{['th','st','nd','rd','th','th','th','th','th','th'][day % 10]}"


def short_ordinal(dt):
    return f"{dt.strftime('%b')} {ordinal(dt.day)}"


def get_known_items():
    skills = set()
    skills_dir = CLAUDE_DIR / "skills"
    if skills_dir.is_dir():
        for d in skills_dir.iterdir():
            if d.is_dir():
                skills.add("/" + d.name)

    commands = set()
    cmds_dir = CLAUDE_DIR / "commands"
    if cmds_dir.is_dir():
        for f in cmds_dir.iterdir():
            if f.is_file():
                commands.add("/" + f.stem)

    return skills, commands


def parse_history():
    skills, commands = get_known_items()
    all_known = skills | commands

    usage = Counter()
    last_used = {}
    projects = Counter()
    daily = Counter()
    total = 0

    if not HISTORY.exists():
        return {}, {}, {}, {}, 0, skills, commands

    with open(HISTORY) as f:
        for line in f:
            total += 1
            d = json.loads(line)
            text = d.get("display", "")
            ts = d.get("timestamp", 0)
            proj = d.get("project", "")
            dt = datetime.fromtimestamp(ts / 1000)
            daily[dt.strftime("%Y-%m-%d")] += 1

            if proj:
                short = proj.replace(str(Path.home()), "~")
                projects[short] += 1

            for m in re.findall(r"(?:^|\s)(/[a-z][a-z0-9_:-]*)", text):
                base = m.split(":")[0] if ":" in m else m
                if base in all_known:
                    usage[m] += 1
                    last_used[m] = dt

    return usage, last_used, projects, daily, total, skills, commands


def generate_html(usage, last_used, projects, daily, total, skills, commands):
    now = datetime.now()
    cutoff = now - timedelta(days=STALE_DAYS)
    all_known = skills | commands

    never_used = sorted(all_known - {s.split(":")[0] for s in usage})
    stale = sorted(
        [s for s, dt in last_used.items() if dt < cutoff],
        key=lambda s: last_used[s],
    )
    active = sorted(
        [s for s, dt in last_used.items() if dt >= cutoff],
        key=lambda s: -usage[s],
    )

    def skill_type(name):
        base = name.split(":")[0]
        if base in commands:
            return "command"
        if base.startswith("/gsd"):
            return "gsd"
        return "skill"

    def type_badge(stype):
        if stype == "skill":
            return '<span class="inline-block px-2 py-0.5 text-xs font-bold bg-gold text-ink">skill</span>'
        if stype == "command":
            return '<span class="inline-block px-2 py-0.5 text-xs font-bold bg-red text-cream">command</span>'
        return '<span class="inline-block px-2 py-0.5 text-xs font-bold border border-ink/30">gsd</span>'

    def rows_html(items):
        rows = []
        for s in items:
            stype = skill_type(s)
            count = usage.get(s, 0)
            last = last_used.get(s, None)
            last_str = short_ordinal(last) if last else "never"
            days_ago = (now - last).days if last else None
            days_str = str(days_ago) if days_ago is not None else ""
            rows.append(
                f'<tr>'
                f'<td class="py-3 pr-4 font-bold">{s}</td>'
                f'<td class="pr-4">{type_badge(stype)}</td>'
                f'<td class="pr-4 text-right tabular-nums">{count:,}</td>'
                f'<td class="pr-4">{last_str}</td>'
                f'<td class="text-right tabular-nums opacity-50">{days_str}</td>'
                f'</tr>'
            )
        return "\n            ".join(rows)

    top_projects = projects.most_common(10)
    max_proj = top_projects[0][1] if top_projects else 1
    projects_html = "\n          ".join(
        f'<div>'
        f'<div class="flex justify-between text-sm mb-1"><span class="font-bold">{p.replace("~/", "")}</span><span>{c:,}</span></div>'
        f'<div class="w-full h-5 bg-cream border border-ink/20"><div class="h-full bg-red" style="width:{c * 100 / max_proj:.1f}%"></div></div>'
        f'</div>'
        for p, c in top_projects
    )

    weeks = []
    for i in range(11, -1, -1):
        week_start = now - timedelta(days=now.weekday() + 7 * i)
        week_total = sum(
            c for d, c in daily.items()
            if week_start <= datetime.strptime(d, "%Y-%m-%d") < week_start + timedelta(days=7)
        )
        weeks.append((week_start.strftime("%b %d"), week_total))
    max_week = max((w[1] for w in weeks), default=1)
    activity_html = "\n          ".join(
        f'<div>'
        f'<div class="flex justify-between text-sm mb-1"><span class="font-bold">{label}</span><span>{count:,}</span></div>'
        f'<div class="w-full h-5 bg-cream border border-ink/20"><div class="h-full bg-gold" style="width:{count * 100 / max(max_week, 1):.1f}%"></div></div>'
        f'</div>'
        for label, count in weeks
    )

    never_html = "\n        ".join(
        f'<span class="inline-block px-3 py-1.5 text-sm font-bold bg-pink border-4 border-red">{s}</span>'
        for s in never_used
    ) if never_used else '<p class="opacity-50">None</p>'

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>claudit</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
  <script>
    tailwind.config = {{
      theme: {{
        extend: {{
          colors: {{
            cream: '#f5f3e8',
            ink: '#222',
            red: '#db5439',
            pink: 'rgba(220,84,57,0.5)',
            gold: '#eebe6d',
          }},
          fontFamily: {{
            serif: ['"Libre Baskerville"', 'Georgia', 'serif'],
          }},
        }},
      }},
    }}
  </script>
  <style>
    * {{ border-radius: 0 !important; }}
    .tabular-nums {{ font-variant-numeric: tabular-nums; }}
    .dark {{ --cream: #1a1a18; --ink: #f5f3e8; --red: #e8654e; --pink: rgba(232,101,78,0.15); --gold: #d4b36a; }}
    .dark body, .dark {{ background: var(--cream, #1a1a18); color: var(--ink, #f5f3e8); }}
    .dark .bg-cream {{ background: #1a1a18 !important; }}
    .dark .bg-pink {{ background: rgba(232,101,78,0.15) !important; }}
    .dark .text-ink {{ color: #f5f3e8 !important; }}
    .dark .border-ink {{ border-color: #f5f3e8 !important; }}
    .dark .border-ink\\/20 {{ border-color: rgba(245,243,232,0.2) !important; }}
    .dark .border-ink\\/10 {{ border-color: rgba(245,243,232,0.1) !important; }}
    .dark .divide-ink\\/10 > :not(:last-child) {{ border-color: rgba(245,243,232,0.1) !important; }}
    .dark .border-ink\\/30 {{ border-color: rgba(245,243,232,0.3) !important; }}
    .dark .bg-gold {{ background: #d4b36a !important; }}
    .dark .text-cream {{ color: #1a1a18 !important; }}
    .dark .bg-red {{ background: #e8654e !important; }}
    .dark .border-red {{ border-color: #e8654e !important; }}
    .dark .border-gold {{ border-color: #d4b36a !important; }}
    .toggle {{ position: fixed; top: 1.5rem; right: 1.5rem; background: none; border: 2px solid; padding: 0.4rem 0.8rem; font-family: inherit; font-size: 0.75rem; cursor: pointer; text-transform: uppercase; letter-spacing: 0.1em; }}
  </style>
</head>
<body class="bg-cream text-ink font-serif min-h-screen">
  <button class="toggle" onclick="document.documentElement.classList.toggle('dark'); localStorage.setItem('claudit-dark', document.documentElement.classList.contains('dark'))">dark</button>
  <script>if (localStorage.getItem('claudit-dark') === 'true' || (!localStorage.getItem('claudit-dark') && matchMedia('(prefers-color-scheme:dark)').matches)) document.documentElement.classList.add('dark')</script>

  <header class="max-w-6xl mx-auto px-6 pt-16 pb-10">
    <h1 class="text-5xl font-bold tracking-tight">claudit</h1>
    <p class="mt-3 text-lg opacity-70">Skills audit — generated {short_ordinal(now)} — {total:,} prompts analysed</p>
  </header>

  <main class="max-w-6xl mx-auto px-6 space-y-16 pb-20">

    <section class="grid grid-cols-2 md:grid-cols-4 gap-6">
      <div class="bg-pink border-4 border-red p-6">
        <div class="text-4xl font-bold">{len(active)}</div>
        <div class="mt-1 text-sm uppercase tracking-wider">Active</div>
      </div>
      <div class="bg-pink border-4 border-red p-6">
        <div class="text-4xl font-bold">{len(stale)}</div>
        <div class="mt-1 text-sm uppercase tracking-wider">Stale (30+)</div>
      </div>
      <div class="bg-pink border-4 border-red p-6">
        <div class="text-4xl font-bold">{len(never_used)}</div>
        <div class="mt-1 text-sm uppercase tracking-wider">Never used</div>
      </div>
      <div class="bg-pink border-4 border-red p-6">
        <div class="text-4xl font-bold">{sum(usage.values()):,}</div>
        <div class="mt-1 text-sm uppercase tracking-wider">Total invocations</div>
      </div>
    </section>

    <section>
      <h2 class="text-2xl font-bold mb-6">Active Skills</h2>
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead>
            <tr class="border-b-2 border-ink text-left">
              <th class="pb-3 pr-4">Skill</th>
              <th class="pb-3 pr-4">Type</th>
              <th class="pb-3 pr-4 text-right">Uses</th>
              <th class="pb-3 pr-4">Last Used</th>
              <th class="pb-3 text-right">Days</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-ink/10">
            {rows_html(active)}
          </tbody>
        </table>
      </div>
    </section>

    <section>
      <h2 class="text-2xl font-bold mb-6">Stale Skills <span class="text-base font-normal opacity-60">30+ days</span></h2>
      <div class="overflow-x-auto border-l-4 border-gold pl-6">
        <table class="w-full text-sm">
          <thead>
            <tr class="border-b-2 border-ink text-left">
              <th class="pb-3 pr-4">Skill</th>
              <th class="pb-3 pr-4">Type</th>
              <th class="pb-3 pr-4 text-right">Uses</th>
              <th class="pb-3 pr-4">Last Used</th>
              <th class="pb-3 text-right">Days</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-ink/10">
            {rows_html(stale)}
          </tbody>
        </table>
      </div>
    </section>

    <section>
      <h2 class="text-2xl font-bold mb-6">Never Used</h2>
      <div class="flex flex-wrap gap-3">
        {never_html}
      </div>
    </section>

    <section class="grid md:grid-cols-2 gap-10">
      <div>
        <h2 class="text-2xl font-bold mb-6">Top Projects</h2>
        <div class="space-y-3">
          {projects_html}
        </div>
      </div>
      <div>
        <h2 class="text-2xl font-bold mb-6">Weekly Activity</h2>
        <div class="space-y-3">
          {activity_html}
        </div>
      </div>
    </section>

  </main>

  <footer class="max-w-6xl mx-auto px-6 py-10 border-t-2 border-ink/20">
    <p class="text-sm opacity-50">Generated {short_ordinal(now)}</p>
  </footer>

</body>
</html>"""
    return html


def main():
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    data = parse_history()
    html = generate_html(*data)
    OUTPUT.write_text(html)
    print(f"Report written to {OUTPUT}")


if __name__ == "__main__":
    main()
