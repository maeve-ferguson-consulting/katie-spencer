# `POSITIONING_HOOKS.md` schema

The contract `craft-outreach` reads at runtime. The consultant keeps this file in their Claude Project Knowledge (or workspace). The skill never invents these values — if the file is missing or `current_primary_hook` is empty, the skill runs the inline first-run elicitation and writes the file.

## Required structure

```yaml
current_primary_hook:
  headline: >
    The single line the consultant would say across the table to a stranger
    to explain the work right now. The bumper sticker for the drum-beat
    they're currently pushing.
  why_now: >
    What's making this the right line right now — a recent keynote, podcast,
    piece, or moment in the field.
  evidence_links:
    - <URL of the most recent piece pushing this hook>
    - <URL of a second piece, if available>
  prospects_it_lands_with: >
    Situation-based description of who this hook reaches, not demographic
    description. E.g., "EDs who just survived a strategic plan and are
    watching their board drift," not "mid-size nonprofits."

recent_pieces:
  # Most recent first. Each piece is fair game for outreach to reference.
  - title: <e.g., "Why Your Nonprofit Board Is Disengaged and Exactly How to Fix It">
    url: <podcast URL, article URL, newsletter URL>
    published: <ISO date, e.g., 2026-01-15>
    one_line_takeaway: <e.g., "Disengagement is a role-clarity failure, not apathy.">
    quotable_lines:
      - <grab-able phrase 1>
      - <grab-able phrase 2>

secondary_hooks:
  # Optional. Alternates the consultant uses for different audience segments
  # or off-primary positioning (e.g., Lane A vs Lane B). Skip cleanly if there
  # is no secondary hook yet.
  - headline: <alternate hook>
    used_for: <which segment / situation>
```

## Required fields

The skill treats these as required for the file to be considered populated:

- `current_primary_hook.headline` — non-empty
- `current_primary_hook.why_now` — non-empty
- At least one entry in `current_primary_hook.evidence_links` **OR** `recent_pieces` — the skill needs at least one URL to anchor specificity

If any required field is empty, the skill runs the inline first-run elicitation to fill it before writing.

## Optional fields

- `current_primary_hook.prospects_it_lands_with` — improves angle selection in outreach
- `recent_pieces` — the more entries, the richer the tether language available
- `secondary_hooks` — needed only if the consultant carries multiple positioning lanes

## Refresh cadence

Positioning hooks drift fast — every new keynote, podcast, or major piece can shift the primary headline. The skill supports a manual refresh: when the user says "refresh hooks" or `/outreach refresh`, re-run the elicitation, append new entries to `recent_pieces`, and overwrite `current_primary_hook` if it has changed.

Never silently overwrite the consultant's edits. If the file exists with hand-edited values, confirm before changing structural sections.

---

## Optional companion: `outreach-angles.yml`

The default three angles (Affirm+Extend, Disagree+Reframe, Observation+Credential) ship with the skill and work across consulting domains. A consultant can override them by placing this file alongside `POSITIONING_HOOKS.md`:

```yaml
angles:
  - name: <Angle name>
    description: <One-line strategic intent>
    use_when: <Situation where this angle fits>
    risk: <What could land wrong>
  - name: <Second angle>
    description: …
    use_when: …
    risk: …
  - name: <Third angle>
    description: …
    use_when: …
    risk: …
```

Must contain exactly three angles. The skill loads these in order and applies them to every outreach run.

## Optional companion: `OUTREACH_CADENCE.md`

If the consultant has a preferred recommended-next-step cadence different from the skill's defaults, they can override per message type. See the rubric in `SKILL.md`. The file is a simple markdown table or YAML — the skill reads `linkedin_dm.first_touch.no_reply_days`, etc.
