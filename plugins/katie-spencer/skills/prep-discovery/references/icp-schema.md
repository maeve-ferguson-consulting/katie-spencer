# ICP.md schema

The `prep-discovery` skill reads consultant-specific ideal-client-profile (ICP) signal mapping from a single document called `ICP.md` that lives in the consultant's Claude Project Knowledge. This file defines the contract.

`ICP.md` is the consultant's mental signal map, made legible to a skill. Every entry the consultant adds sharpens the next briefing.

---

## Required structure

Plain markdown with a single fenced ```yaml block. The skill parses the first occurrence of each key.

```yaml
domain: <one-line description of the consultant's niche, e.g., "nonprofit board governance">

audience_types:
  - <e.g., "ED/CEO of mid-size nonprofit">
  - <e.g., "board chair">
  - <e.g., "community foundation officer">

signal_categories:
  - <name>          # used to spawn one parallel research agent per category
  - <name>
  # Examples for nonprofit governance: board_composition, funding_moves,
  # leadership_transition, governance_signals, capital_campaign_status.
  # Examples for SaaS GTM: funding_stage, hiring_patterns, product_launches,
  # exec_changes, pricing_moves.
  # The skill spawns one parallel web-research agent per category in Phase 1.

green_flags:
  - signal: <prospect language, org state, or recent event>
    indicates: <which offer name from SERVICES.md or BRAND.md > Offer Bank this points to>
    listen_for: <the literal phrase or pattern to listen for on the call>
    lane: <optional — A | B | A_or_B, when the consultant's BRAND.md has positioning lanes>

red_flags:
  - signal: <e.g., "we just need a fundraising consultant">
    why: <why this is a wrong-fit signal>
    redirect: <how the consultant should handle it on the call — reframe, hand off, decline>
```

### Optional sections

```yaml
yellow_flags:                # ambiguous — informs questions, doesn't disqualify
  - signal: <e.g., "first-time ED, less than 12 months in role">
    note: <what to weigh / what to ask>

disqualifiers:               # hard-stop signals that should block the call
  - signal: <e.g., "publicly disputing former service providers">
    why: <reason>

contextual_modifiers:        # things that shift offer weight without firing on their own
  - signal: <e.g., "high-stakes timing constraint visible in their public moves">
    modifier: <e.g., "weight the urgency-oriented offer higher; surface the constraint on the call">
```

---

## Field definitions

- **`domain`** — the consultant's niche, one line. Used in briefing voice (orients the research agents).
- **`audience_types`** — the kinds of decision-maker the consultant sells to. Used to disambiguate when a prospect org has multiple plausible contacts.
- **`signal_categories`** — high-level research themes. The skill spawns one parallel web-research agent per category in Phase 1. Keep the list to 3–6 — more than that fragments research without adding signal.
- **`green_flags`** — prospect language, org states, or recent events that indicate fit. Each one points to a specific offer (by name, verbatim from `SERVICES.md` or `BRAND.md > Offer Bank`) and includes a literal listen-for phrase.
- **`red_flags`** — disqualifying or wrong-fit signals. Each includes *why* and a *redirect* (how the consultant should handle it on the call).
- **`yellow_flags`** (optional) — ambiguous signals that shape questions but don't disqualify.
- **`disqualifiers`** (optional) — hard-stop signals that should block the call before it happens. Surface these in the brief's TL;DR.
- **`contextual_modifiers`** (optional) — signals that shift offer weight when paired with green/red flags.

---

## How the skill uses each field

- **Phase 1** spawns one parallel research agent per entry in `signal_categories`.
- **Phase 3** scores the prospect against every entry in `green_flags`, `red_flags`, `yellow_flags`, `disqualifiers`. Output: a table with status (Fired / Partial / Not fired / Insufficient evidence), evidence quote + URL, and the listen-for phrase.
- **Phase 4** uses each fired green flag's `indicates` field to rank offers from the consultant's catalog.
- **Lane awareness:** if a flag's `lane` field disagrees with `BRAND.md > Positioning > current_lane`, the brief surfaces the tension instead of silently switching lanes.

---

## Provisional markers

If a section is filled during inline first-run elicitation but with starter values the consultant hasn't fully ratified yet, place a single HTML-comment marker between the section heading and the YAML fence:

```
### `green_flags`
<!-- PROVISIONAL: seeded from a 60-second elicitation, refine after the next 2-3 calls -->
```yaml
...
```

`prep-discovery` treats PROVISIONAL sections as present-but-placeholder. It will proceed but warn the consultant: "Your green-flag list is still PROVISIONAL — this brief will be only as sharp as those starter signals. Worth a 10-minute refinement pass after the call."

Remove the marker the instant the consultant confirms a section is theirs.

---

## First-run elicitation

When `ICP.md` is missing, `prep-discovery` elicits inline (per the Option-B inline-elicitation decision in the shared-context handoff) before researching. Goal: a usable signal map in 5 minutes, not a perfect one.

### Step 1 — domain (one question)

> "What's your niche in one line? Examples: 'nonprofit board governance,' 'B2B SaaS GTM,' 'private-practice operations.' This orients my research agents."

### Step 2 — audience types (one question)

> "Who do you sell to? Two or three role types is enough. Examples: 'EDs of mid-size nonprofits, board chairs, community foundation officers.'"

### Step 3 — signal categories (one question, draft from material)

> "When you walk into a prospect call, what 3–6 things are you scanning for on their website, LinkedIn, recent news? I'll spawn one parallel research agent per category. If you're not sure, I'll draft a starter set for your domain and you confirm."

Draft a starter set if needed (examples baked into the schema comments above). Confirm before continuing.

### Step 4 — green flags (one question)

> "What 3–6 things, if true about a prospect, tell you it's a strong fit? Each one should map to a specific offer in your catalog. Example: 'recent leadership transition in the last 12 months → your leadership-transition offer.' I'll work with whatever you give me; we can refine after the next couple of calls."

For each green flag, ask the consultant for a literal listen-for phrase ("what would they actually say on the call?"). If the consultant can't give one, draft from public-facing material in `BRAND.md` and confirm.

### Step 5 — red flags (one question)

> "What 2–4 things, if true about a prospect, tell you it's a wrong fit — and what do you say on the call when you spot one?"

### Step 6 — save and proceed

Write `ICP.md` to the working directory. If any section is starter-only, emit the `<!-- PROVISIONAL: ... -->` marker on that section. Tell the consultant: "Upload `ICP.md` to your Claude Project Knowledge. I'll use it for this brief and every future one. The PROVISIONAL sections will sharpen as you refine them after real calls."

Then continue to Phase 0 of the briefing.

---

## Example — B2B SaaS GTM consultant (fictional)

A worked example using a fictional consultant's domain. All offer names and signals are illustrative — yours will be different. The shape is what matters.

```yaml
domain: "B2B SaaS go-to-market strategy for Series A/B companies"

audience_types:
  - "VP Marketing or VP Sales at a Series A/B SaaS company"
  - "founder/CEO of a Series A SaaS company without a senior GTM hire yet"
  - "Chief Revenue Officer joining in the first 6 months"

signal_categories:
  - funding_stage             # recent rounds, runway commentary, valuation moves
  - hiring_patterns           # GTM hires posted, sales/marketing team growth or freeze
  - product_launches          # major release cadence, expansion into new segments
  - exec_changes              # VP/CRO/CMO turnover, board changes
  - pricing_moves             # public price changes, packaging shifts, new tiers

green_flags:
  - signal: "Series A or B raised in last 6 months with stated GTM scaling thesis"
    indicates: "GTM Foundations Sprint"
    listen_for: "'we just raised and we know we need to build the engine' / 'the board wants to see efficient growth'"
    lane: A

  - signal: "VP Marketing or VP Sales hired in last 90 days"
    indicates: "First-90-Days Playbook"
    listen_for: "'I'm new and trying to figure out what's working' / 'I'm building from what I inherited'"
    lane: A

  - signal: "ICP drift — selling into too many segments, win rates declining"
    indicates: "ICP Reset Engagement"
    listen_for: "'we close everywhere but nowhere well' / 'every deal looks different'"
    lane: B

  - signal: "pricing/packaging change in last 12 months without measurable lift"
    indicates: "Pricing Reset Engagement"
    listen_for: "'we changed pricing but it didn't move the needle' / 'we don't know if we're priced right'"
    lane: B

red_flags:
  - signal: "'we just need more leads'"
    why: "lead-volume-as-symptom framing; this consultant works on conversion economics, not top-of-funnel"
    redirect: "reframe to the conversion gaps the lead engine would feed into; refer to a demand-gen specialist if they hold the frame"

  - signal: "founder unwilling to narrow ICP"
    why: "every engagement requires willingness to focus; without it, the work doesn't take"
    redirect: "name it; offer a one-session ICP diagnostic as the readiness test before any larger engagement"
```

This example uses a B2B SaaS GTM consultant — a different domain from any specific consultant who might be reading it. The schema itself is universal: the same shape works for nonprofit board governance, private-practice operations, executive coaching, or any other consulting practice with a discovery → proposal flow.
