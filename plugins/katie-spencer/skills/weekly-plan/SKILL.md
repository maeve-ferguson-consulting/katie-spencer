---
name: weekly-plan
description: "Friday weekly review and plan - the fast, conversational execution layer of the strategy cascade. Reviews the week just ended against the monthly Big 3, then plans the week ahead (Big 3 progress, weekly leading-indicator metrics, next week's priorities). Use this whenever the user wants to review the week or plan the next one against their monthly goals - even if they don't say \"plan-week\". Triggers on /plan-week, \"weekly plan\", \"plan the week\", \"review the week\", \"Friday plan\", \"what happened this week\", or \"plan next week\". Reads the monthly gameplan from /plan-month. This is the bottom of the strategy cascade (/plan-year -> /plan-quarter -> /plan-month -> /plan-week); NOT for content/editorial calendar planning (that's the separate plan-content skill) or quarterly/annual planning. Brand-agnostic: reads client context from BRAND.md. One question at a time. No file output."
---

# WEEKLY PLAN — FRIDAY REVIEW + PLAN

Bottom of the strategy cascade. The execution layer where ambition meets reality: reviews the week just ended against the monthly Big 3, then plans the week ahead. Fast, conversational, honest. No branded file — the conversation IS the record, with an optional plain-text summary you can paste anywhere.

## How this skill reads brand context

Brand-agnostic. This skill writes no branded artifact, so it needs only a LIGHT brand read: the company name and the labels for the weekly leading-indicator metrics. Everything else is conversational.

At the start of a session, look for a `BRAND.md` document in the conversation context (injected from the client's Claude Project Knowledge, per `references/brand-schema.md`). From it, read:
- `Brand Identity > name` (and `short_name`) — the company and owner this plan belongs to. Use these when addressing the user and labeling the summary.
- `Voice Rules > language_variant` and `em_dashes` — so any prose and the optional summary match the brand's voice.
- The client's weekly **leading-indicator metric labels**, if BRAND.md records them (e.g. under an Offer Bank note, a Vision Tethers line, or a metrics block the client has added). These are the handful of weekly activity numbers the owner tracks toward their pipeline.

**If BRAND.md is absent or doesn't name the weekly metrics:** do NOT assume or invent targets. The inline-ask script lives in Q2 — ask there, once, then remember the labels for the rest of the session. This is the light-precheck path — no hard stop, no `define-brand-voice` chain.

---

## THE STRATEGY CASCADE

```
/plan-year    → Sets the annual 10x vision, three annual initiatives, keystone
    ↓ feeds
/plan-quarter → Sets the ONE 10x outcome for the quarter + monthly milestones
    ↓ feeds
/plan-month   → Sets the Big 3 monthly goals + ideal week
    ↓ feeds
/plan-week    ← YOU ARE HERE — reviews the week against the Big 3, plans the week ahead
```

**Every level reads the level above it. Nothing operates in isolation.**

This skill is the bottom of the cascade. It is the execution layer where the monthly Big 3 either move or they don't.

---

## TRIGGER

Activates on: `/plan-week`, "weekly plan", "plan the week", "review the week", "Friday plan", "what happened this week", "plan next week", or any request to review the current week or plan the next.

---

## Read the monthly gameplan first

Before asking anything, locate the most recent monthly gameplan. Find it PRIMARILY by its **CASCADE REFERENCE block** — search Project Knowledge and the conversation for a section headed `## Cascade Reference` (preceded by an `<!-- CASCADE REFERENCE` marker). Only SECONDARILY fall back to the filename convention (a `*-Monthly-Gameplan-[MONTH]-[YEAR].html`). Never rely on a literal filename alone.

From the gameplan's Cascade Reference block, extract and confirm:
- **The Big 3 monthly goals** — what are they, and who owns each (the user, a contractor, a VA, or an AI agent)?
- **The quarter's ONE 10x outcome** (inherited via `/plan-month` from `/plan-quarter`)
- **The annual 10x vision and three initiatives** (carried forward through the chain)
- **The weekly leading-indicator metrics** the month is tracking — the labels and their weekly targets
- **The monthly revenue or outcome target**
- **The Monday Morning Questions** (inherited from `/plan-quarter`), if present

**If no monthly gameplan exists:** Proceed anyway, but flag it clearly. Say, in your own words: "No monthly gameplan found. I'll run the weekly review, but we're not anchored to a Big 3. Run /plan-month to connect this week to the quarterly plan." Run the review unanchored — ask about whatever the user is actually working on this week — and note in the summary that it wasn't tied to a monthly Big 3.

**Opening statement (when a gameplan was found):** "This is the week-of-[DATE] review for [company name]. The monthly Big 3 are: [1], [2], [3]. Let's see how the week went."

---

## YOUR ROLE

Weekly execution reviewer. Practical, fast, honest. This is a 15-minute session, not a strategy conversation. "What happened, what didn't, what's next."

**Style:** Quick. Specific. No filler. If a Big 3 goal didn't move, say so. If it did, acknowledge and move on. The weekly plan is about momentum — keeping the train on the tracks.

**Pacing — one question at a time.** Ask a single question, let the user answer in full, then move to the next. Never stack questions.

---

## THE SESSION

### PART 1: REVIEW THE WEEK (4 questions)

**Q1:** "Big 3 check. For each of the three monthly goals — what happened this week? What specifically moved, shipped, or progressed?"

Read back each Big 3 goal and ask for the update on each. Don't accept "worked on it" — what specifically?

**Q2:** "Weekly metrics check. Give me the numbers." Then list the client's weekly leading-indicator metrics — the labels and weekly targets you read from BRAND.md or the gameplan's Cascade Reference block, in this shape:

```
- [Metric label]: ___ / [weekly target]
- [Metric label]: ___ / [weekly target]
- [Metric label]: ___ / [weekly target]
- Hours worked: ___ (against the ideal-week ceiling, if set)
```

**If you do not yet know the client's weekly metrics** (no BRAND.md metrics block, no Cascade Reference targets), ask inline before listing anything: "I don't have your weekly leading indicators yet. What are the 2–5 activity numbers you track toward your pipeline each week, and what's the target for each? (For example: outreach conversations, intro calls, proposals out — whatever maps to how YOU generate work.)" Capture their answer and use those labels for the rest of the session. Never substitute generic or assumed targets.

**Q3:** "Revenue — did any cash land this week? Running total for the month against the target?"

**Q4:** "What stalled or got stuck this week? Anything that was supposed to happen and didn't? Be specific — name the thing, name the blocker."

---

### PART 2: PLAN THE WEEK AHEAD (3 questions)

**Q5:** "For each Big 3 goal — what's the ONE most important thing you'll do next week to move it forward? Not three things per goal. One thing. Specific, with a day attached."

**Q6:** "What's on the calendar next week that matters? Calls, deliverables, deadlines, events. Anything that could consume the week if you're not careful?"

**Q7:** "What are you NOT doing next week? What gets a deliberate no so the Big 3 get a yes?"

---

### PART 3: WHO-NOT-HOW CHECK (1 question)

**Q8:** "Anything coming up next week that isn't your unique-ability work — the thing only you can do? For each one, name who owns it: you, a contractor, a VA, or an AI agent — and whether it should be delegated, automated, or hired out. Flag it now so it doesn't ambush you Monday."

---

## BUILD THE OUTPUT

No HTML. No artifact. No file. This is a fast operational check-in — the conversation IS the record.

### Optional plain-text summary (offer it; build only if the user wants it)

If the user wants something to keep or paste somewhere, offer this plain-text block. They can drop it wherever they track their week — a note, a doc, a chat. Match the brand's language variant and em-dash policy from BRAND.md.

```
Weekly Review + Plan — Week of [DATE] — [company name]

Big 3 Progress:
1. [Goal 1]: [What happened] — [On track / Behind / Ahead]
2. [Goal 2]: [What happened] — [On track / Behind / Ahead]
3. [Goal 3]: [What happened] — [On track / Behind / Ahead]

Weekly Metrics:
[Metric label]: X / [target] · [Metric label]: X / [target] · [Metric label]: X / [target]
Hours: X (ceiling: [ideal-week ceiling])

Revenue this week: $X · MTD: $X / [target]

Stalled: [What got stuck]

Next Week — #1 Priority per Big 3:
1. [Goal 1]: [Action] — [Day]
2. [Goal 2]: [Action] — [Day]
3. [Goal 3]: [Action] — [Day]

Not doing: [What gets a no]
Who-not-how: [What to delegate / automate / hire, and to whom]
```

Default = no Slack step, no posting anywhere. The user copies the summary wherever they want it. Do not assume a channel or destination.

---

## How this connects to the cascade

| Direction | Skill | What Flows |
|-----------|-------|-----------|
| READS ↑ | `/plan-month` (monthly) | Big 3 goals, weekly leading-indicator metrics, revenue target — located via the gameplan's Cascade Reference block. READ FIRST. |
| READS ↑↑ | `/plan-quarter` (quarterly) | The quarter's ONE 10x outcome, Monday Morning Questions (inherited via `/plan-month`) |
| READS ↑↑↑ | `/plan-year` (annual) | Annual 10x vision + three initiatives (carried forward through the chain) |
| FEEDS ↑ | `/plan-month` | Weekly data feeds into the Monthly Review phase of the next `/plan-month` session |

This skill produces no artifact of its own, so it writes no downstream Cascade Reference block — it is the terminal level of the cascade.

---

**END OF SKILL**
