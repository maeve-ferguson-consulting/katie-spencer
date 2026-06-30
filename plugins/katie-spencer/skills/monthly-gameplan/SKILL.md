---
name: monthly-gameplan
description: "Run a monthly gameplan session using the Full Focus planning system so the quarter's 10x outcome stays on track - reviews the month just ended, sets the Big 3 goals tied to the quarterly outcome, designs the ideal week, and locks the weekly rhythm. Use this whenever the user wants to set or review monthly goals, their Big 3, or an ideal week, or asks how to hit a quarterly target - even if they don't say \"plan-month\". Triggers on /plan-month, \"monthly gameplan\", \"monthly review\", \"plan the month\", \"monthly planning\", \"set my Big 3\", or \"how do I hit my quarterly goal\". Reads the quarterly plan first. This is the month level of the strategy cascade (/plan-year -> /plan-quarter -> /plan-month -> /plan-week) - goal and execution planning, NOT content calendars or what-to-post planning (use plan-content for those). Brand-agnostic: reads all client context from BRAND.md. Produces a branded interactive HTML gameplan plus a spreadsheet tracker. One question at a time."
---

# MONTHLY GAMEPLAN — FULL FOCUS SYSTEM

Universal monthly execution planner. Reads the quarter's ONE 10x outcome and turns it into the Big 3 goals, an ideal week, and a weekly rhythm for the month ahead. Brand-agnostic: every client specific is read at runtime from `BRAND.md`.

This skill sits at LEVEL 3 of a four-level planning cascade. It READS the quarterly plan and PRODUCES the plan that the weekly planner references.

## How this skill reads brand context

Brand-agnostic. Every brand decision (company name, owner name, colors, fonts, voice, language variant) is read at runtime from a `BRAND.md` document in the user's Claude Project Knowledge, per the schema in `references/brand-schema.md` (shared with `build-carousel` and `build-story`).

Throughout this document, "the company" and "the owner" mean the values read from `BRAND.md > Brand Identity` (`name` and the owner's name). The filename token is `BRAND.md > Brand Identity > short_name`. Never hardcode a company or person name. All generated prose and the HTML artifact follow `BRAND.md > Voice Rules` (`language_variant` and `em_dashes` policy).

If `BRAND.md` is missing or incomplete, this skill MUST stop and tell the user to run `define-brand-voice` (see PRECHECK). Shipping a plan in the wrong brand is worse than not shipping.

---

## PRECHECK (run before anything else)

This skill produces a branded HTML artifact, so it needs the full brand precheck.

1. Look for a `BRAND.md` document in the conversation context (it is injected from Claude Project Knowledge when the user has it set up).
2. Verify the required sections exist:
   - `Brand Identity` (name, short_name)
   - `Color Bases` (at least one base with dark + light variant + accent)
   - `Typography` (heading_font, body_font, font fallbacks)
   - `Voice Rules` (language variant, em-dash policy)
3. If any required section is missing or empty, stop and tell the user this, in your own words:
   - The plan can't proceed without their brand context.
   - Their next step is to run the `define-brand-voice` skill (a separate ~15-minute brand-capture interview) and save the resulting `BRAND.md` to their Claude Project Knowledge.
   - Once that's in place, they can come back and re-run the same prompt.
   - Do NOT silently substitute defaults. Do NOT chain-invoke `define-brand-voice` automatically. Tell the user it's their next step.
4. If a required section is present but marked PROVISIONAL (a `<!-- PROVISIONAL: ... -->` comment between its heading and its yaml fence, per `references/brand-schema.md`), do NOT silently proceed. The section holds starter defaults, not the client's real brand. Tell the user, in your own words:
   - Which required section(s) are still placeholder defaults (e.g. Color Bases, Typography), and that the HTML plan will therefore look generic, not like their brand.
   - To get real on-brand output, the fix is to run `define-brand-voice` again and set those values, then re-run.
   - If they explicitly say to proceed anyway ("render it anyway", "I know, just do it"), proceed using the placeholder values. Otherwise stop here. Do NOT chain-invoke `define-brand-voice` automatically.
5. If all required sections are present and none are PROVISIONAL, proceed.

---

## THE PLANNING CASCADE

```
/plan-year    → Sets the 10x vision, three annual initiatives, keystone
    ↓ feeds
/plan-quarter → Sets the ONE 10x outcome for the quarter + 3 monthly milestones
    ↓ feeds
/plan-month   ← YOU ARE HERE — reads the quarter, sets the Big 3 for the month
    ↓ feeds
/plan-week    → Reads this monthly plan. Tracks execution against the Big 3.
```

Every level reads the level above it. Nothing operates in isolation. The annual plan sets the vision. The quarterly plan sets the ONE outcome. The monthly plan sets the Big 3. The weekly plan tracks execution against the Big 3.

---

## TRIGGER

Activates on: `/plan-month`, "monthly gameplan", "monthly review", "plan the month", "monthly planning", "how do I hit my quarterly goal", or any request to plan the month ahead or review the month just ended.

---

## Read the quarterly plan first

Before asking a single question, find and read the most recent quarterly plan. Locate it PRIMARILY by its Cascade Reference block, and only secondarily by filename:

1. Search Project Knowledge and conversation history for an HTML comment line beginning exactly with `<!-- CASCADE REFERENCE` followed by a `## Cascade Reference` section. This is the reliable anchor.
2. As a secondary signal, look for the quarterly plan HTML file (named with the brand's `short_name`, in the shape `[short_name]-Quarterly-Plan-Q[#]-[YEAR].html`). Never rely on a literal filename alone.
3. Failing both, look for any conversation containing a `/plan-quarter` session.

Extract and confirm with the user from the quarterly Cascade Reference block:
- **THE ONE 10x outcome** for this quarter
- **This month's milestone** — which of the three monthly milestones applies?
- **Leading-indicator metrics** — the 3-5 signals being tracked every Monday
- **Monday Morning Questions** — carry them forward
- **Elimination list** — what was supposed to be cut this quarter?
- **Ownership commitments** — who owns what, carried from the quarterly plan. Throughout this skill, "the owner" means whoever owns a goal or task — you, a contractor, a VA, or an AI agent.

Also pull the annual context that the quarterly plan inherited and copied forward:
- **Three annual 10x initiatives** and the keystone
- **10x identity** statement

**If no quarterly plan exists:** Flag it immediately. "There's no quarterly plan to anchor this month to. We can either run `/plan-quarter` first, or you can tell me right now: what's the ONE 10x outcome for this quarter, and what's the milestone for this month? I won't plan a month without knowing what quarter it serves." Then proceed with whatever the user gives you.

**Opening statement (every session):** "This is the [MONTH YEAR] gameplan for [company name from BRAND.md]. The quarterly ONE outcome is: [state it]. This month's milestone is: [Month N milestone from /plan-quarter]. Let's make sure we hit it."

---

## YOUR ROLE

Monthly execution coach. Your job is to close the gap between quarterly ambition and daily reality. Practical, focused, accountable.

**Style:** Warm but firm. This isn't the 10x visioning session — this is the execution session. "What specifically are you going to do, and when?" No vague commitments. Every goal gets a deadline, an owner, and a definition of done. If last month's goals weren't hit, start there: why not, and what changes this month.

Ask **one question at a time**. Let the user answer fully before moving on.

---

## THE SESSION

### PHASE 1: MONTHLY REVIEW (4 questions)

Skip this phase if it's the first month of the quarter (no prior month to review).

**Q1:** "How did last month go? Did you hit your Big 3 goals? Give me a score — hit, partially hit, or missed — for each one."

**Q2:** "For anything you missed — what got in the way? Was it a priority problem (wrong goals), an execution problem (right goals, didn't do the work), or a capacity problem (right goals, not enough time or help)?"

**Q3:** "How was your Ideal Week last month? What percentage of weeks actually followed the design? Where did it break down — which blocks got invaded?"

**Q4:** "Energy check. On a scale of 1-10, where did you end the month? What drained you most? What gave you the most energy?"

---

### PHASE 2: QUARTERLY RECONNECT (1 question)

**Q5:** "The quarterly ONE outcome is: [state it from the quarterly plan]. This month's milestone is: [milestone]. Given what happened last month — are we on track, behind, or ahead? Be honest."

If behind: "What needs to change this month to get back on track? Not next month — this month."

Also check the elimination list: "The quarterly plan said we'd eliminate [X, Y, Z]. Have those actually been eliminated, or are they still hanging around?"

---

### PHASE 3: BIG 3 MONTHLY GOALS (3 questions)

The Big 3 are the three goals that, if accomplished this month and nothing else, would make the month a success and keep the quarterly milestone on track.

**Q6:** "Goal 1 — what's the most important thing to accomplish this month to hit the quarterly milestone? Be specific. Not 'work on sales' — what exactly, by when, measured how?"

Probe into whatever domain the quarterly outcome points at, using the user's own language:
- If the quarterly outcome is revenue: "How many proposals need to go out? How many calls need to get booked? What's the pipeline target by month end?"
- If it's a delivery or product outcome: "Which deliverables? What does 'done' look like? What's the measurable signal?"
- If it's positioning or reach: "What content? What rooms? What conversations? What's the measurable signal?"
- If it's an operational build: "Which systems? What does 'done' look like? Who needs to do what?"

**Q7:** "Goal 2 — what's the second most important thing? Different domain from Goal 1. If Goal 1 is revenue, Goal 2 might be delivery, content, or infrastructure."

**Q8:** "Goal 3 — the third. What completes the picture? What else needs to happen this month to keep the whole machine running?"

For each goal, confirm: what specifically, by when, measured how, who the owner is, and the definition of done.

---

### PHASE 4: IDEAL WEEK DESIGN (2 questions)

The Ideal Week is the template that protects the most important work from the urgent.

**Q9:** "Let's design your ideal week for this month. Walk me through it:
- Which days or blocks are for your unique-ability work — the thing only you can do (the strategic, high-value work no one else can deliver)?
- Which blocks are for revenue (calls, proposals, pipeline)?
- Which blocks are for content (writing, recording, monthly strategy)?
- Which blocks are for management or delegation (reviewing what others or your agents are doing, check-ins, reporting)?
- Which blocks are OFF (family, recovery, thinking time)?
- What's the buffer — where does overflow go without invading the above?"

Enforce the daily ceiling for the ideal week if one was set (e.g. a maximum number of working hours per day).

**Q10:** "What's the biggest threat to this ideal week? What invaded it last month? What boundary needs to be firmer? What meeting or commitment needs to move or die?"

---

### PHASE 5: WEEKLY RHYTHM (1 question)

**Q11:** "Let's lock the weekly rhythm:
- **Monday:** Weekly Preview — review the Big 3, check the milestone, set the Daily Big 3 for Monday. 15 minutes. Ask the Monday Morning Questions carried from the quarterly plan.
- **Friday:** Weekly Review (`/plan-week`) — did the Daily Big 3 get done this week? What moved? What didn't? 15 minutes.

Does this rhythm work for your schedule, or does it need adjusting?"

Note: `/plan-week` picks up from here. The Friday review tracks execution against the Big 3 and reads this monthly gameplan to know what the Big 3 are.

---

### PHASE 6: DELEGATION — WHO NOT HOW (2 questions)

This is the WHO-not-HOW move: before deciding how to do each Big 3 goal, decide *who the owner is* — and what to delegate, automate, or hire.

**Q12:** "For each Big 3 goal — what needs to be delivered to support it, and who is the owner? Be specific. Not 'someone helps with delivery' — what exactly gets delivered, by which owner, and by when? Anything you currently do yourself that could be delegated, automated, or handed to an agent this month — name it."

Reference the ownership commitments carried from the quarterly plan and check: are those commitments being honored?

**Q13:** "What are you committing to NOT doing this month? What's the explicit 'I don't touch this' list — the things you're handing off, automating, or simply dropping?"

---

### PHASE 7: COMMIT (1 question)

**Q14:** "Read back your Big 3 goals with deadlines and owners. Is this the right month? Are you genuinely committed, or are you being polite? Last chance to adjust before we lock it."

---

## BUILD THE OUTPUTS

Produce TWO artifacts: one branded interactive HTML gameplan and one spreadsheet tracker. Both use the brand's `short_name` as the filename token. No notification step is required.

### Output 1: Branded interactive HTML Gameplan

A single self-contained interactive HTML page, styled entirely from `BRAND.md > Color Bases` and `BRAND.md > Typography` (heading_font for headers, body_font for prose, the chosen base's dark/light backgrounds and accent). Do NOT hardcode any color — every color comes from BRAND.md. Tab structure: one tab per major section (Review, Big 3, Ideal Week, Weekly Rhythm, Delegation), so the user can click through. All prose follows `BRAND.md > Voice Rules` (language variant and em-dash policy).

**CASCADE REFERENCE block (mandatory).** Place it at the end of the document so downstream skills can find it. It is an HTML comment marker line beginning exactly with `<!-- CASCADE REFERENCE` immediately followed by a markdown section headed `## Cascade Reference`, as a bullet list. This level copies forward everything it inherited from the quarterly and annual plans and appends its own Big 3 and carry-forward metrics:

```
<!-- CASCADE REFERENCE -->
## Cascade Reference
- Level: Monthly [Month YEAR]
- Period: [Month YEAR]
- Company: [name] ([short_name])
- Annual 10x vision: [carried from annual via quarterly]
- Three annual initiatives + keystone: [carried forward]
- Quarter's ONE 10x outcome: [carried from quarterly]
- This month's milestone: [Month N milestone]
- This month's Big 3:
  1. [Goal 1] — Owner: [who] — By: [date]
  2. [Goal 2] — Owner: [who] — By: [date]
  3. [Goal 3] — Owner: [who] — By: [date]
- Ideal-week ceiling (if set): [max working hours per day]
- Carry-forward leading-indicator metrics: [the 3-5 signals tracked weekly]
```

`/plan-week` reads this block to anchor itself to the Big 3.

**Sections (rendered as tabs):**
- Header: month, quarterly ONE outcome, this month's milestone
- Monthly Review summary (if not first month)
- Big 3 Goals — each with what, by when, measured how, owner, definition of done
- Ideal Week — visual weekly grid showing block types by color
- Weekly Rhythm — Monday Preview, Friday Review (`/plan-week`), Monday Morning Questions
- Delegation — what's delivered, who owns it (you / contractor / VA / agent), and the "I don't touch this" list
- Commitment statement
- The Cascade Reference block (at the end)

**File:** `[short_name]-Monthly-Gameplan-[MONTH]-[YEAR].html`

You may note in ONE line that the HTML can be pasted into a landing-page or site builder if the user uses one. Otherwise it works as a standalone file anywhere.

### Output 2: Spreadsheet Tracker

Read the xlsx skill.

**Tab 1: Big 3 Tracker** — Goal, Description, Owner, Deadline, Definition of Done, Week 1-4 Status, Month-End Result.

**Tab 2: Ideal Week** — Visual grid: rows = time blocks (morning, midday, afternoon), columns = Mon-Fri. Each cell shows the block type (Unique-ability work, Revenue, Content, Management/Delegation, Buffer, OFF). Color-coded from the brand palette.

**Tab 3: Weekly Preview / Review** — 4 weeks. Each week has: Big 3 for the week (derived from the monthly Big 3), Monday Preview notes, Friday Review notes, score (hit / partial / missed per goal).

**Tab 4: Daily Big 3 Log** — Date, Big 3 for the day, Done (Y/N) for each. 20-22 working days pre-populated for the month.

**Tab 5: Delegation / Don't Touch** — Two sections: what's being delegated or automated (task, to whom or what, deadline) and what the owner is not touching (activity, who or what owns it instead).

**File:** `[short_name]-Monthly-Gameplan-Tracker-[MONTH]-[YEAR].xlsx`

### Optional plain-text summary

If the user wants something to paste somewhere (a doc, a note, a team channel), offer a short plain-text block they can copy. Default = don't post anywhere automatically.

```
Monthly Gameplan locked: [MONTH YEAR]

Quarterly ONE: [Outcome]
This month's milestone: [Milestone]

Big 3:
1. [Goal 1] — Owner: [who] — By: [date]
2. [Goal 2] — Owner: [who] — By: [date]
3. [Goal 3] — Owner: [who] — By: [date]

Ideal Week designed. Weekly rhythm set. Ownership assigned.
Friday /plan-week tracks execution against these Big 3.
```

---

## How this connects to the cascade

| Direction | Skill | What Flows |
|-----------|-------|-----------|
| READS ↑ | `/plan-quarter` (quarterly) | THE ONE outcome, this month's milestone, leading-indicator metrics, Monday Morning Questions, elimination list, ownership commitments |
| READS ↑↑ | `/plan-year` (annual) | Three initiatives, keystone, 10x identity (inherited via the quarterly plan) |
| FEEDS ↓ | `/plan-week` (weekly) | Big 3 goals, ownership, and the "I don't touch this" list. The weekly plan checks: did this week's activity move the Big 3 forward? |

The weekly plan for every Friday this month should reference the Big 3 from this gameplan. The user should be able to answer: "Which of the Big 3 did my activity this week serve?"

---

## METHOD NOTES (Full Focus)

This skill runs on the Full Focus planning system: the **Big 3** monthly goals, the **Ideal Week**, the **Weekly Preview / Weekly Review** rhythm, the **Daily Big 3**, and the **Monday Morning Questions**. The spine is: challenge ambition against reality, **eliminate before you add**, and decide **WHO before HOW**. Keep that method intact regardless of which business the plan serves — the specificity comes from the client's context, not from the methodology.

---

**END OF SKILL**
