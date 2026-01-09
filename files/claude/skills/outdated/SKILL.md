---
name: outdated
description: Analyze major version upgrades and write migration recommendations to tmp/UPGRADES.md
---

# Major Version Upgrade Analysis

Identify packages with major version upgrades available and assess whether upgrading is advisable.

**Scope**: Major versions only. Minor/patch updates are handled automatically by the daily audit script.

## Instructions

1. Run `pnpm outdated` to identify packages with major version changes
2. Read existing `tmp/UPGRADES.md` if it exists (preserve previous decisions/notes)
3. For each major version upgrade, assess:
   - **Stability of new version** (see Maturity Assessment below)
   - **Support status of current version** (still maintained? security patches?)
   - **Breaking changes** and migration effort
4. Write findings to `tmp/UPGRADES.md`

## Maturity Assessment

Before recommending any upgrade, check the new version's maturity:

```bash
pnpm view <package> dist-tags --json    # Is "latest" stable or beta?
pnpm view <package> versions --json     # Version history
pnpm view <package> time --json         # Release dates
```

**The minor version is the key signal** - it indicates how many release cycles the major has been through:
- `x.0.x` = Just released, avoid. Ecosystem still finding bugs.
- `x.1.x` = Early adopter phase. Only if you need a specific feature.
- `x.2.x` = Stabilizing. Reasonable to start planning.
- `x.3.x+` = Battle-tested. Safe to upgrade.

**Red flags**:
- Only beta/rc/canary releases for new major
- New major released < 1 month ago
- Major version with only .0.x patches (no minor releases yet)
- Changelog full of breaking change fixes post-release

**Check npm release date**: `pnpm view <package> time --json | grep "5.0.0"` to see when major was released.

## Output Format

Write to `tmp/UPGRADES.md`:

```markdown
# Major Version Upgrades

Last checked: YYYY-MM-DD

## Direct Dependencies

| Action | Package | Current | Latest Stable | Maturity | Urgency | Difficulty | Notes |
|--------|---------|---------|---------------|----------|---------|------------|-------|
| plan | zod | 3.23 | 4.3.5 | mature | low | moderate | x.3 = safe; [Migration](link) |
| wait | next-auth | 4.24 | 5.0-beta | beta | low | major | No stable release yet |
| wait | some-lib | 2.8 | 3.0.4 | fresh | low | easy | x.0 = wait for 3.2+ |
| wait | other-lib | 1.5 | 2.1.3 | early | low | moderate | x.1 = early adopter territory |
| plan | date-fns | 3.6 | 4.4.0 | mature | low | easy | x.4 = battle-tested |
| blocked | react | 18.3 | 19.2.1 | stable | low | hard | x.2 but blocked by next-auth |

## Dev Dependencies

| Action | Package | Current | Latest Stable | Maturity | Urgency | Difficulty | Notes |
|--------|---------|---------|---------------|----------|---------|------------|-------|
| plan | vite | 6.4 | 7.3 | mature | low | easy | Dev tooling only |

## Transitive

Major version updates needed in parent packages (not directly actionable).

| Package | Current | Latest | Via | Notes |
|---------|---------|--------|-----|-------|
| preact | 10.x | 11.x | next-auth | Will resolve when next-auth updated |
```

## Scoring

**Action**:
- `plan`: Ready to upgrade - version is mature and migration path is clear
- `wait`: Not ready - version too fresh, still in beta, or ecosystem not ready
- `blocked`: Dependency conflict prevents upgrade
- `skip`: Intentionally staying on current version (document reason)

**Maturity** (based on minor version):
- `beta`: Only pre-release versions available (no stable x.0.0 yet)
- `fresh`: x.0.x - just released, avoid
- `early`: x.1.x - early adopter territory
- `stable`: x.2.x - stabilizing, okay to plan
- `mature`: x.3.x+ - battle-tested, safe to upgrade

**Urgency** (based on current version status, NOT new version existence):
- `critical`: Known security vulnerability in current version
- `high`: Current version deprecated/EOL/no longer receiving patches
- `medium`: Current version in maintenance mode (security only)
- `low`: Current version still actively supported

**Difficulty**:
- `trivial`: Drop-in replacement, no code changes
- `easy`: Config/import changes only
- `moderate`: Some code changes required
- `hard`: Significant refactor needed
- `major`: Full migration/rewrite

## Important

- **Skip minor/patch updates** - the audit script handles those
- **Always check maturity** before recommending an upgrade
- **"Latest exists" ≠ "should upgrade"** - new majors need time to stabilize
- **Preserve existing entries** - update status, don't remove previous decisions
- **Check release dates** - a 5.0.1 from last week is very different from 5.0.1 from 6 months ago
