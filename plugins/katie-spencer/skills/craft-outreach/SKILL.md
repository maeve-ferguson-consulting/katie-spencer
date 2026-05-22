---
name: craft-outreach
description: "Personalized first-touches and follow-ups for one prospect or a batch. Produces three distinct angle variants per message (Affirm+Extend, Disagree+Reframe, Observation+Credential — configurable), each tethered to the consultant's current positioning hook AND a specific recent signal from the prospect's dossier. Refuses without a real 90-day prospect hook, a populated dossier, and a current positioning hook from POSITIONING_HOOKS.md. Triggers on /outreach, /message, /reach-out, /firsttouch, /followup, /nudge, /reengage, 'draft a message to', 'write outreach to', 'cold open for', 'follow up with', 'ping', 'voice note for', 'what should I say to', or any personalized outbound to a prospect, lead, JV partner, or referral. Channels: LinkedIn DM (max 80w), email (max 120w), voice note script (max 60s spoken). Modes: single prospect or batch from a CSV/markdown OUTREACH_DATABASE. On first run, captures POSITIONING_HOOKS.md inline if missing. Not for proposals, agreements, or sending — drafts only."
---

# CRAFT OUTREACH

Universal outreach drafter. Produces three angle variants of a personalized message for a single prospect (or a batch of prospects from a database), tethered to the consultant's current positioning hook and a specific recent signal from each prospect's dossier.

**The bar:** would a peer in this prospect's field actually send this message, and would the prospect read it as a peer reaching out — not a vendor pitching? If the answer to either is no, the skill rewrites or refuses.

---

## How this skill reads consultant context

This skill is consultant-agnostic. Every consultant-specific input (brand voice, current drum-beats, prospect dossiers, ideal-client signals) is read at runtime from documents the consultant maintains in their Claude Project Knowledge or workspace. The skill never invents defaults for these.

| Doc | Purpose | Required? |
|---|---|---|
| `BRAND.md` | Voice, signature phrases, banned words, dialect, person | **Required** |
| `POSITIONING_HOOKS.md` | Current drum-beats from the consultant's content (latest piece, primary headline, prospects it lands with) | **Required** — elicited inline on first run if missing |
| `IDEAL_CLIENT.md` | Green/red flag signal map for the consultant's offer | Optional — improves angle selection if present |
| Prospect dossier | Output of `lead-dossier-builder` or an equivalent file | **Required** — built on the fly if missing |
| `OUTREACH_DATABASE` (CSV/md) | Prospect roster for batch mode | Optional — single-prospect mode works without it |
| `outreach-angles.yml` | Override the three default angles | Optional — defaults ship and are good across consulting domains |

If any **required** input is missing, the skill stops and walks the user through capturing it inline (see PRECHECK and FIRST-RUN ELICITATION). It never substitutes its own defaults.

---

## PRECHECK (run before anything else)

1. **`BRAND.md`** — look for it in conversation context (Project Knowledge will inject it). Verify `Brand Identity`, `Voice Rules` sections are populated. If missing or empty: stop and tell the user to run `define-brand-voice` first. Their next step is to capture brand context (one-time, ~10 min), then re-run this skill.

2. **`POSITIONING_HOOKS.md`** — look for it. If missing or `current_primary_hook` is empty: announce the head-up and run FIRST-RUN ELICITATION (below). Do NOT silently proceed without a tethered hook — outreach without one drifts into generic.

3. **Prospect dossier** — for single-prospect mode, confirm the prospect's dossier exists (path provided, or recently built in this session). If missing: ask whether to invoke `lead-dossier-builder` first. Do NOT write outreach without research — the whole point is the homework.

4. **`outreach-angles.yml`** — optional; if present, load the consultant's preferred angle set. Otherwise use the defaults below.

If any required input is missing and the user declines to capture it, stop. Tell them why. Do not produce a generic message.

---

## FIRST-RUN ELICITATION: `POSITIONING_HOOKS.md`

When `POSITIONING_HOOKS.md` is missing or its `current_primary_hook` is empty, surface a transparent head-up:

> "This is your first run, so I need to capture your current positioning hook before I write — the drum-beat you're publicly pushing right now. Without it, the message tethers to nothing. Takes about 5 minutes, one question at a time. Ready?"

Then run the questions below, **one at a time**. Wait for each answer before moving on. Pull from existing material whenever possible — if the consultant points to a recent piece, podcast, or newsletter, fetch and summarize back to confirm rather than asking cold.

### Question 1 — Primary headline
> "What's the single line you'd say across the table to a stranger to explain the work right now? The bumper sticker for the drum-beat you're currently pushing. One sentence."

### Question 2 — Why now
> "What's making this the right line right now — a recent keynote, podcast, piece, or moment in your field that's pushing this idea to the surface? One sentence."

### Question 3 — Evidence
> "One or two links to where this hook is showing up publicly — a podcast episode, an article, a LinkedIn post, a newsletter. Paste URLs. (If nothing's published yet, say so — we'll mark it as a pre-launch hook.)"

### Question 4 — Who it lands with
> "Which prospects does this hook land with most? Describe the situation, not the demographics — e.g., 'EDs who just survived a strategic plan and are watching their board drift,' not 'mid-size nonprofits.'"

### Question 5 — Secondary hooks (optional, skip cleanly if not ready)
> "Any secondary positioning hooks I should know about — alternates you'd use for a different audience segment or off-primary positioning? Skip if the primary is the only one for now."

### Save

Write `POSITIONING_HOOKS.md` to the consultant's working directory in the schema documented in `references/positioning-hooks-schema.md`. Tell the user plainly:

> "Saved POSITIONING_HOOKS.md. Upload it to your Claude Project Knowledge so future runs read it automatically. You can refine it any time — re-run /outreach with the word 'refresh hooks' and I'll re-elicit."

Then continue with the outreach request.

---

## TRIGGER

Activates on: `/outreach`, `/message`, `/reach-out`, `/firsttouch`, `/followup`, `/nudge`, `/reengage`, "draft a message to [Name]", "write outreach to [Name]", "cold open for [Name]", "follow up with [Name]", "ping [Name]", "voice note for [Name]", "what should I say to [Name]", or any request to write personalized outbound to a prospect, lead, JV partner, or referral candidate.

If the user pastes a CSV path, a markdown table, or a directory of dossiers, treat it as a batch request.

---

## INPUTS (gather, one question at a time if missing)

1. **Prospect identifier.** One of:
   - Name + organisation (skill builds the dossier via `lead-dossier-builder` first)
   - Path to an existing dossier file
   - Path to an `OUTREACH_DATABASE` (CSV / markdown / table) — batch mode

2. **Message type** (required):
   - `first-touch` — cold open, prospect has never heard from the consultant
   - `follow-up` — they didn't respond to the previous touch
   - `nudge` — they replied warm but went silent
   - `re-engage` — quiet for 3+ months
   - `ping` — milestone acknowledgement, no ask (1–2 sentences max)

3. **Channel** (optional, defaults to LinkedIn DM):
   - `linkedin-dm` — ≤80 words
   - `email` — ≤120 words
   - `voice-note` — ≤60 seconds spoken (150–220 words)
   - `substack-reply` / `comment-then-dm` — short and contextual

If the user gives only a name and a message type, default channel to LinkedIn DM and confirm.

---

## THE THREE ANGLES (defaults — keep, configurable)

The skill always writes **three distinct strategic angles** on the same hook. Not three rewordings — three genuinely different positions.

### Angle 1 — Affirm + Extend
> "You said X. Here's where I'd take that further: Y."
**Used when:** the prospect has publicly aligned with the consultant's positioning hook (a recent post, podcast take, article) and the consultant has a credible extension. Lowest risk, moderate reply rate.

### Angle 2 — Disagree + Reframe
> "You're framing it as X. I'd argue it's actually Y."
**Used when:** the consultant has a strong contrarian read on the prospect's stated problem and they're a peer who engages with friction. Higher ceiling, higher risk of no reply. Peer-to-peer only — never use when the consultant is reaching upward in status.

### Angle 3 — Observation + Credential
> "I noticed your org just [did X]. I helped [comparable org] navigate the same transition — happy to share what worked."
**Used when:** cold opens where the prospect doesn't know the consultant's content yet. Establishes credibility fast through an adjacent client example or pattern.

These are configurable via an optional `outreach-angles.yml` in the consultant's Project Knowledge (schema in `references/positioning-hooks-schema.md`). If present, load and use those instead. The defaults are good across consulting domains — don't change them without reason.

---

## NO-HALLUCINATION DISCIPLINE (absolute)

The skill **refuses to write** when any of these are true:

1. **No recent prospect hook.** The dossier surfaces no public activity within the last 90 days — no posts, no transitions, no events, no podcast appearances, no announcements.
2. **No dossier.** The prospect doesn't have a research file yet. Offer to invoke `lead-dossier-builder` first.
3. **Generic activity only.** The "recent activity" is reposts, "happy to be at X conference," or generic life updates — nothing substantive to tether to.
4. **No current positioning hook.** `POSITIONING_HOOKS.md` is missing or its `current_primary_hook` is empty. Run FIRST-RUN ELICITATION first.
5. **Speculative hook.** The user says "I think they posted something about X recently." Make them verify. Don't write on unverified hooks.
6. **Prospect is a real named public figure and the message would put quotes in their mouth.** Standard creative-content rule applies.

### Refusal template

```
I can't write a personalized message to <Name> right now. <Specific reason — which input is missing or generic>.

Options:
1. <Concrete first step — wait for substantive activity, deepen the dossier, warm via mutual connection, etc.>
2. <Alternative first step>
3. <Override with --force and accept a generic message> (rarely the right call — flag this)

Which path?
```

Never leave the user stuck. Always offer the next best step.

---

## OUTPUT FORMAT (single prospect)

```markdown
# Outreach Drafts — <Prospect Name> · <Org>

**Channel:** <LinkedIn DM | Email | Voice note script | etc.>
**Message type:** <first-touch | follow-up | nudge | re-engage | ping>
**Tethered hook:** "<consultant's current_primary_hook headline from POSITIONING_HOOKS.md>"
**Prospect hook:** <one-line description of the specific recent activity + source + date>

---

## Variant 1 — Affirm + Extend

<message body, peer-level, specific, within channel length cap>

**Why this angle:** <1 sentence — what signal in the dossier supports this>
**Risk:** <1 sentence — what could land wrong>

---

## Variant 2 — Disagree + Reframe

<message body>

**Why this angle:** …
**Risk:** …

---

## Variant 3 — Observation + Credential

<message body>

**Why this angle:** …
**Risk:** …

---

**Recommended next step:** <e.g., "Send Variant 1 Thursday morning. If no reply by Tuesday, send Variant 3 as follow-up referencing the first message.">

**Future touches:** <suggested cadence + content tether — e.g., "Next month's piece on board-ED partnership will be a natural reason to circle back if no reply.">
```

### Ping mode (special case)

Pings are 1–2 sentences, ≤30 words, no ask, no CTA, no "would love to." A 30-word milestone acknowledgement with a forced hook tether reads as opportunistic. Skip the three-variant treatment — produce one tight ping. Mark "Tethered hook: not applicable (ping)" in the output.

---

## OUTPUT FORMAT (batch mode)

When the user supplies an `OUTREACH_DATABASE` path, process N prospects in one run. Output one of:

**Option A — Per-prospect markdown stubs** (default for ≤10 prospects). Write each prospect's full three-variant draft to its own section. Stack in a single document.

**Option B — Compressed table** (default for >10 prospects). Per row: Name, Org, Tethered hook, Variant 1 (full text), Variant 2 (full text), Variant 3 (full text), Recommended next step. Use markdown table or CSV — match the database's format.

In batch mode, run the NO-HALLUCINATION discipline per prospect. Flag (don't write) any prospect whose dossier hook is missing or generic. Surface the flagged list at the top of the output so the user can run `lead-dossier-builder` on those before re-running.

See `references/outreach-database-schema.md` for the expected CSV/markdown shape.

---

## VOICE CONSTRAINTS (universal good outreach)

Run every variant through this list before presenting:

- **Peer voice.** No "I admire your work" / "huge fan" / "your work has been an inspiration." Consultants don't fan-girl. The opener treats the prospect as a peer at the same table.
- **Specific or silent.** No generic compliments ("loved your podcast!"). Quote a line, name a specific moment, or skip the compliment entirely.
- **One clear next step.** Never "let me know if you'd ever like to chat sometime." Always something the prospect can accept or decline in one beat — "Are you open to a 20-minute call Thursday or Friday next week?" "Want a copy of the [specific resource]?" "Worth a reply with your read?"
- **Length matches channel.** LinkedIn DM ≤80 words. Cold email ≤120 words. Voice note script ≤60 seconds spoken (150–220 words). Ping ≤30 words.
- **Signature phrases used sparingly.** A signature phrase from `BRAND.md` appears at most once per message. Overuse is an AI-tell.
- **Banned words from `BRAND.md`** never appear.
- **Dialect from `BRAND.md`** is respected (en-US, en-GB, etc.).
- **Em-dash policy from `BRAND.md`** is respected.
- **Emojis** only if `BRAND.md > Voice Rules > emojis: allow`.
- **No corporate filler.** Cut: "I hope this finds you well," "I wanted to reach out," "I came across your profile," "just touching base," "circling back," "quick question."

---

## PER-VARIANT REQUIREMENTS

Each of the three variants must contain:

1. **Opener.** References the specific prospect hook by content, not by generic compliment. "Your piece on board re-engagement on Tuesday" not "Loved your recent post."
2. **Bridge.** Connects the prospect's hook to an idea, observation, or stance that reflects the consultant's current positioning hook — without pitching.
3. **Positioning tether.** The consultant's `current_primary_hook` shows up through framing or language. Don't name the hook explicitly (don't say "you need [Methodology]"). Reflect it.
4. **Ask or close.** Specific, accept/decline-able in one beat. Vague asks get vague answers.
5. **Length** appropriate to channel.
6. **Voice match.** Reads in the consultant's voice from `BRAND.md`. If you swapped the prospect's name for someone else's and the message still worked, the variant has failed — start over.

---

## RECOMMENDED-NEXT-STEP RUBRIC

Default cadence per message type — adjust based on the consultant's stated preferences if `BRAND.md` or a separate `OUTREACH_CADENCE.md` overrides:

| Message type | If no reply | After two nudges |
|---|---|---|
| `first-touch` | Nudge at 7 days | Move to "follow up later" with a 60–90 day re-engage trigger |
| `follow-up` | Nudge at 5 days with a lower-friction alternative | Let it go; log status |
| `nudge` (post-warm) | Add value at 14 days (resource, intro, observation) | Move to "nurture — relationship" |
| `re-engage` | One follow-up at 10 days; then drop | Drop |
| `ping` | No follow-up. The ping is the action. | — |

State the cadence explicitly so the user can diary it.

---

## QUALITY CHECKLIST (run before presenting)

- [ ] `BRAND.md` voice rules applied (dialect, em-dash policy, banned words, signature phrase frequency)
- [ ] `POSITIONING_HOOKS.md` current_primary_hook tethered in every variant (through framing, not by name)
- [ ] Specific prospect hook present in every variant — verifiable, dated, sourced
- [ ] Three angles are genuinely different positions, not three rewordings
- [ ] Each variant ≤ channel length cap
- [ ] Each variant has exactly one clear next step (or none if ping)
- [ ] Peer voice — no supplicant tone, no "admire your work"
- [ ] No banned words from `BRAND.md`
- [ ] No corporate filler
- [ ] Recommended next-step timing stated
- [ ] Refusal triggered correctly if dossier hook or positioning hook is missing — never produced silently

If any box is unchecked, fix before presenting.

---

## WHAT THIS SKILL IS NOT

- **Not a proposal writer.** That's `build-proposal` / `/proposal`.
- **Not a contract/agreement drafter.** That's `build-agreement` / `/agreement`.
- **Not a content repurposing skill.** That's `content-repurposing-machine` / `repurpose-content`.
- **Not a sender.** Produces drafts. The consultant or a separate connector skill sends them.
- **Not a CRM.** The `OUTREACH_DATABASE` is a flat file the consultant maintains. The skill reads status; it doesn't write back.
- **Not a dossier builder.** Depends on `lead-dossier-builder`. If a dossier is missing, hand off — don't duplicate the research logic.
- **Not a template generator.** Every variant is custom to this prospect and this hook. If two messages for two different prospects look interchangeable, the skill has failed.

---

## REMEMBER

The job is to write the message the consultant would write if they had thirty minutes, a fresh coffee, the dossier open on one screen, and their latest piece open on the other. Every time. No generic openers. No hallucinated hooks. Peer-level. Positioning-tethered. Three angles or refuse.

Every message is a first impression, a brand impression, and a category impression at once. There are no throwaway DMs.

**END OF SKILL**
