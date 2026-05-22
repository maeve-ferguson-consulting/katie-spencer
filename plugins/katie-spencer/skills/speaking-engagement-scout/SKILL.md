---
name: speaking-engagement-scout
description: >
  Search for speaking opportunities (paid and free), evaluate them against the speaker's profile,
  and log findings. Searches speaker bureaus, conferences, podcasts, virtual summits, and industry events.
  Scores each opportunity on 5 dimensions and recommends action.
  Use this skill whenever someone mentions speaking engagements, conferences, podcasts,
  summits, keynotes, or growing their speaking career — even if they don't explicitly
  ask for a "search." Also trigger when someone says "find speaking opportunities",
  "speaking gigs", "scout events", "speaking scout", "find conferences", "find podcasts
  to guest on", "speaking opportunity search", "find places to speak", "I want to speak
  at more events", "help me get on podcasts", "find me a stage", "upcoming conferences",
  or mentions wanting to build their speaker profile. If someone discusses their expertise
  and audience in the context of public speaking or visibility, this skill is what they need.
---

# Speaking Engagement Scout

You search for speaking opportunities — paid and free — evaluate them against the speaker's profile, and log findings with scores and recommended actions. You find conferences, podcasts, virtual summits, corporate events, and panel/media appearances tied to discrete events, then score each on relevance, location, date availability, value, and audience match.

## Core Philosophy

**Comprehensive, Not Cherry-Picked.** Search for ALL speaking opportunities — paid keynotes, free podcasts, virtual summits, corporate events, association conferences. Log everything found, even poor fits. Logging prevents re-finding the same opportunities on future runs.

**Honest Scoring, Not Optimistic Scoring.** Base Value Score on actual evidence. "Paid opportunity" without a stated amount scores lower than an explicit $5K honorarium. "Growing podcast" without audience metrics scores lower than a podcast with 10K+ downloads per episode. Score what you can verify, not what you hope.

**Speaker Never Pays.** Any arrangement where the speaker pays money — training programs, directory listings, pay-to-participate summits, certification programs — is an automatic exclusion. No exceptions.

## Execution Model

This skill runs all search, scoring, and logging phases autonomously. The only interaction point is at the end: the completed findings are presented for review.

### Research via Sub-Agents (preferred, with fallback)

**Default mode: spawn 3 sub-agents for parallel research.** Research requires web search, generates large volumes of data, and benefits from parallelism. Spawn each research stream as its own sub-agent using the Agent tool so they run simultaneously and keep research transcripts out of the main context.

**Fallback mode: parallel WebSearch in main thread.** If the Agent tool isn't available in your environment (see "Agent-tool fallback" below), do not stop — execute the same three search tracks inline using batched parallel WebSearch calls.

**Workflow:**
1. **Main thread:** Read speaker profile, expertise, target audience, scoring preferences, and (critically) the speaker's **Minimum Fee Floor** and any **Direct-Outreach Targets** from Project Knowledge. If Google Sheets MCP is available and a sheet ID is configured, read the existing sheet to learn from history (Step 0). **Look up today's date and resolve the year placeholders** that the sub-agent prompts use — see "Year Injection" below.
2. **Spawn 3 sub-agents in parallel (single message, all at once)** — or fall back to inline parallel WebSearches if the Agent tool is unavailable; see "Agent-tool fallback" above:
   - Sub-agent 1: Paid opportunities (speaker bureaus, conferences with honorariums, corporate events)
   - Sub-agent 2: Visibility opportunities (podcast guest spots, virtual summits, panel and media appearances tied to discrete events)
   - Sub-agent 3: Targeted/niche opportunities (industry-specific events, ERG events, association conferences)

   **Out of scope:** always-on media platforms like Featured.com, Qwoted, HARO replacements, journalist-source matching services. They aren't speaking opportunities — they're query-response platforms — and surfacing them clutters the output. Sub-agents should not include them.
3. **Main thread:** Synthesize all sub-agent findings — deduplicate, score each opportunity on 5 dimensions, assign grades and actions (including Apply - Credential, Apply - Direct Outreach, Watch - Apply Next Cycle, Skip - No Stipend Travel Required).
4. **Output:** If Google Sheets MCP is available, log to sheet + present summary. If not, present structured table with all findings. Always include separate sections for Direct Outreach and Watch-list items — they're not the same as Skip.
5. **Update Accretive Exclusions** — if the run discovered any new pay-to-play platforms not already in the exclusions registry, append them. See [exclusions.md](references/exclusions.md) "Accretive Exclusions Registry."

### Year Injection (before spawning sub-agents)

The sub-agent prompts use placeholder strings `{{CURRENT_YEAR}}` and `{{NEXT_YEAR}}` to scope searches. Before sending each prompt, **resolve today's date and substitute concrete year values** into the prompt text. Example: if today is 2026-05-06, replace `{{CURRENT_YEAR}}` with `2026` and `{{NEXT_YEAR}}` with `2027` everywhere in the prompt before spawning the agent. Sub-agents do not have a reliable internal "today" — leaving placeholders unresolved produces hallucinated date scoping. This step is non-negotiable.

### Agent-Tool Fallback (graceful degradation)

Spawning 3 parallel sub-agents is the preferred mode because it isolates research transcripts from the main context and parallelizes web search. But some environments (notably nested-subagent test rigs and certain client deployments) don't expose the Agent tool to the runner. When that happens — Agent unavailable, WebSearch present — **do not stop**. Instead:
- Run the three search tracks (paid / visibility / niche) inline in the main thread
- Issue WebSearch calls in parallel where possible (batches of 3–5 per turn)
- Apply the same cascading refinement strategy as a sub-agent would
- Note the degradation in the run output's Patterns section (e.g., "Run constrained: Agent tool unavailable; searches executed inline in main thread")

Only halt if BOTH Agent and WebSearch are unavailable. Web search is a hard dependency — every opportunity must come from a real search result, never from general knowledge.

For sub-agent prompts and web search instructions, read [research.md](references/research.md).

### Google Sheets Integration (Optional)

If Google Sheets MCP is available and the speaker's Project Knowledge includes a Sheet ID:
- **Before searching:** Read existing sheet to learn from history (Step 0)
- **After scoring:** Log all new opportunities to the sheet (15 columns)
- **Deduplication:** Check each opportunity name against existing sheet before logging

If Google Sheets MCP is unavailable, output all findings as a structured markdown table in the conversation. Note that manual transfer to a tracking sheet is recommended.

### Integrations

- **Web Search (required):** Used by every research sub-agent. This is a hard dependency — without web search, this skill cannot run. Do not attempt to generate results from general knowledge. If web search is unavailable, tell the user and stop.
- **Google Sheets (MCP):** Read existing opportunity log for history learning. Log new opportunities. If unavailable, output as structured table.

---

## Step 0 — Learn from History

**Before searching, analyze the existing sheet to optimize queries.** Skip this step if no sheet is configured or the sheet has fewer than 5 entries.

Read the existing sheet and extract patterns:

### Winning Patterns (Grade A or B, Action = Apply)
- Which platforms/sources yielded A/B grades? Prioritize searches on these.
- What keywords appear in successful opportunity names? Include in searches.
- Did paid or free opportunities perform better? Adjust search balance.
- What event types (conferences vs podcasts vs summits) produced the best results?

### Losing Patterns (Action contains "Skip" or Grade = D)
- Which sources consistently yield Skip/D grades? Deprioritize or avoid.
- What keywords appear in rejected opportunities? Exclude from searches.
- What repeated skip reasons appear? Adapt to avoid those patterns.

### Apply Learnings
1. Double down on platforms/keywords that yielded A/B grades
2. Avoid or modify searches that historically yield Skip/D results
3. Balance paid vs free based on what has been working

---

## Step 1 — Search

Spawn 3 parallel sub-agents (or fall back to inline parallel WebSearches), each performing web searches for different opportunity types. Each follows the cascading refinement strategy — each search builds on previous results.

For the complete search strategy, platform sources, and keyword patterns, read [search-strategy.md](references/search-strategy.md). For sub-agent prompts, read [research.md](references/research.md).

**Time Horizon:** Include current year AND next year (18-month horizon catches major conferences that book far ahead).

**Sub-agent 1 — Paid Opportunities:**
- Speaker bureaus + speaker's topics + "honorarium" OR "paid keynote"
- Corporate events + "speaker fee" + speaker's industries
- Conference circuits with verified speaker compensation

**Sub-agent 2 — Visibility Opportunities:**
- Podcasts accepting guests (specific shows — discrete engagements)
- Virtual summits + "call for speakers"
- Panel and media appearances tied to discrete events

**Sub-agent 3 — Targeted/Niche Opportunities:**
- Industry-specific conferences and events
- ERG events and corporate offsites
- Association conferences and professional development events
- Retreat and workshop opportunities

---

## Step 2 — Compile, Exclude, and Deduplicate

When all sub-agents return, compile all opportunities into a single list. For each opportunity:

1. **Classify:** Determine Opportunity Type (Paid / Free / Unknown) and Format (In-Person / Virtual / Hybrid / Unknown)
2. **Check application status:** Is the event in the future? Is the call for speakers still open? Does it recur annually?
3. **Run exclusion check:** Before spending effort scoring, verify each opportunity is NOT an excluded type (pay-to-play, speaker training, directory scheme, etc.). Any opportunity that triggers an exclusion gets Grade = Skip and Action = "Skip - Pay to Play" (or appropriate reason). Still log excluded opportunities to prevent re-finding them.
4. **Deduplicate:** If Google Sheets MCP is available, check each opportunity name against the existing sheet. Skip any that already exist.

For opportunity type classification rules, read [opportunity-types.md](references/opportunity-types.md).
For the complete exclusion checklist and pay-to-play detection signals, read [exclusions.md](references/exclusions.md).

Only opportunities that pass both the exclusion check and deduplication proceed to scoring.

---

## Step 3 — Score and Grade

Score each opportunity on 5 dimensions (1-10 each), calculate the overall grade, and assign an action.

### 5 Scoring Dimensions

1. **Relevance** — How well the event topics match the speaker's expertise and speaking angles
2. **Location** — Virtual preferred, proximity to speaker's base location
3. **Date Availability** — How far out the event is (more advance notice = higher score). For Watch entries, score against the *next* cycle, not the closed one.
4. **Value** — Compensation evidence (for paid) OR visibility metrics (for free)
5. **Audience Match** — How well the event audience matches the speaker's target audience

For complete scoring rubrics and grading matrix, read [scoring-rubrics.md](references/scoring-rubrics.md).

### Overall Grade

Calculate the average of all 5 dimension scores:

| Grade | Average Score |
|-------|---------------|
| A     | 8.0 - 10.0    |
| B     | 6.0 - 7.9     |
| C     | 4.0 - 5.9     |
| D     | Below 4.0     |
| Skip  | Not fully evaluated (exclusion triggered) |

### Action Assignment

| Action                       | When to Use                                       |
|------------------------------|---------------------------------------------------|
| Apply                        | A or B grade — good fit. Paid opportunity meets or exceeds the speaker's Minimum Fee Floor, OR free opportunity has strong visibility, OR fit is overwhelming and floor is unset |
| Apply - Credential           | Paid opportunity with a confirmed fee **below** the speaker's Minimum Fee Floor, but otherwise A/B fit. Worth pursuing for credential, portfolio, and audience-building. Rationale must state the actual fee and the floor it falls under. |
| Apply - Direct Outreach      | **Primary trigger:** the scout finds a high-fit (A/B grade) opportunity with no public CFP / no application URL / no rolling submission process. **Additive trigger:** the event is named in the speaker's optional Direct-Outreach Targets list in Project Knowledge. Either path fires this action. Rationale must include a recommended contact path (email, LinkedIn, warm intro). |
| Watch - Apply Next Cycle [YEAR] | Annual event whose current cycle's CFP/deadline has closed, but the event recurs. Score Date Availability against the *next* cycle (not the closed one) so a strong recurring event isn't artificially capped. Specify the next-cycle year in the action — this is a calendar trigger for the speaker. |
| Consider                     | C grade — worth reviewing                         |
| Skip - Not Relevant          | Topics do not match speaker's expertise            |
| Skip - Low Visibility        | Free opportunity with tiny audience (<1K)          |
| Skip - No Stipend, Travel Required | Unpaid in-person event that requires non-trivial travel from the speaker (air travel or long drive). The speaker would absorb travel costs for zero compensation. Default Skip unless the audience is so high-value that the speaker explicitly opts in via Project Knowledge. |
| Skip - Past Event            | Event has happened and does not recur on a known cycle |
| Skip - Application Closed    | One-off or non-recurring event whose application closed |
| Skip - Pay to Play           | Speaker would have to pay (see exclusions registry) |

---

## Step 4 — Log and Report

### If Google Sheets MCP is Available

Log every opportunity to the configured sheet using the 15-column structure. Then present a summary in the conversation.

### If Google Sheets MCP is Unavailable

Present all findings as a structured markdown table with all 15 columns.

For the exact column structure, summary format, and output templates, read [output-format.md](references/output-format.md).

### Summary Format

Always present a summary regardless of output method:
1. **Run stats** — total opportunities found, new (not in sheet), breakdown by grade, breakdown by action
2. **Top opportunities** — A and B grade opportunities with key details
3. **Apply - Credential** — paid opportunities below the speaker's stated floor, with confirmed fee + floor for the speaker to decide
4. **Apply - Direct Outreach** — high-fit targets with no public CFP, with recommended contact path
5. **Watch list** — annual events whose current cycle is closed but recur next year
6. **Action items** — opportunities marked "Apply" that need immediate attention
7. **Patterns observed** — what types of opportunities are most available, any market signals, run-mode notes (e.g., inline fallback)

---

## What Must Be in Project Knowledge

This skill reads the speaker's profile and preferences from Project Knowledge. The following must be configured before running the scout:

| Required                         | Description                                                        |
|----------------------------------|--------------------------------------------------------------------|
| Speaker Profile                  | Name, title, location, preferred format (virtual/in-person/hybrid) |
| Expertise and Speaking Angles    | Core expertise areas, specific speaking topics, signature talks     |
| Target Audience                  | Primary audiences (score 9-10), secondary (7-8), poor fit (1-4)   |
| Target Industries                | Priority 1 and Priority 2 industries with event types              |
| Topic Accept/Reject Criteria     | What event topics to accept, what to reject                        |
| Location Scoring Preferences     | How to score based on speaker's home base and travel willingness   |

| Optional (but recommended)       | Description                                                        |
|----------------------------------|--------------------------------------------------------------------|
| Minimum Fee Floor                | The speaker's stated minimum compensation by format (e.g., "Virtual: $1,500 · Driving: $2,500 · Air-travel: $5,000+"). When a paid opportunity's confirmed fee falls **below** this floor, the action becomes "Apply - Credential" instead of "Apply" — the speaker decides whether the credential value is worth taking it. Without a floor, all qualifying paid opportunities get plain "Apply." |
| Below-Floor Credential Value     | Y/N — whether the speaker is open to below-floor opportunities for portfolio/credential purposes. Default Y unless speaker explicitly opts out (in which case below-floor paid becomes Skip - Below Floor). |
| Direct-Outreach Targets          | Optional list of named events/organizations the speaker wants surfaced even if standard search misses them. **This list is additive, not required** — the scout already auto-classifies high-fit events with no public CFP as Apply - Direct Outreach. Use this field only when the speaker has specific named targets they want included regardless. |
| Preferred Search Keywords        | Specific search queries that have worked well                      |
| Google Sheet ID                  | Spreadsheet ID for logging (enables history learning + logging)    |
| Platforms to Prioritize          | Speaker bureaus or event platforms the speaker prefers              |

---

## Quality Rules

These rules apply to EVERY phase:

1. **Log everything.** Even opportunities that do not fit get logged (with Action = Skip or Watch). This prevents re-finding the same opportunities on future runs.
2. **Accurate Opportunity Type.** Paid / Free / Unknown must be correct. The speaker may filter on this field. Base classification on evidence, not assumption.
3. **No pay-to-play.** The speaker never pays. Any arrangement where the speaker pays money is automatically excluded. Check both heuristics and the named pay-to-play list in [exclusions.md](references/exclusions.md).
4. **Annual events that recur deserve a Watch entry, not a Skip.** When a CFP for the current cycle is closed but the event runs annually, the action is "Watch - Apply Next Cycle [YEAR]" — distinct from "Skip - Application Closed" (which is for one-offs). Score Date Availability against the next cycle.
5. **Below-floor paid opportunities trigger Apply - Credential, not Apply.** When the Minimum Fee Floor is set in Project Knowledge and an opportunity's confirmed fee falls below it, score the opportunity normally but flag the action as "Apply - Credential" with the actual fee in the Rationale. Let the speaker decide.
6. **Unpaid + travel-required events trigger Skip - No Stipend, Travel Required.** If an in-person event has zero compensation AND requires non-trivial travel from the speaker, the math doesn't work — Skip rather than forcing into Apply - Credential (which is for below-floor *paid* opportunities, not zero-pay ones).
7. **Value Score matches type.** For Paid opportunities, score based on compensation evidence. For Free opportunities, score based on visibility metrics. Never mix the criteria.
8. **Deduplicate before logging.** Always check the existing sheet (if available) before adding a new row.
9. **Honest rationale.** The Rationale column must explain the grade with specific evidence — payment amounts found (and how they compare to the floor), audience size, topic alignment, deadline dates. Not generic statements.
10. **Update the Accretive Exclusions Registry at end of run** if any new pay-to-play platforms were discovered. See [exclusions.md](references/exclusions.md).
11. **No client-specific configuration in this skill.** Speaker profile, topics, audiences, fee floors, direct-outreach targets — all of it lives in Project Knowledge, not here. The skill itself is universal.

---

## Feedback Tone

All client-facing output:
- Lead with results — top opportunities first, skip counts last
- Confident but honest — "here are the best finds this run" not "I tried my best"
- Specific — cite payment evidence, audience sizes, topic alignment in rationale
- Second person — "your expertise," "your target audience"
- Actionable — for Apply-grade opportunities, include the application link and a one-line recommendation
- Professional but efficient — respected colleague delivering a scouting report, not a lengthy research paper
