# Scoring Rubrics

5-dimension scoring system for evaluating speaking opportunities. Each dimension is scored 1-10. The overall grade is the average of all 5 scores.

---

## Dimension 1 — Relevance Score (1-10)

How well the event topics match the speaker's expertise and speaking angles. Use the speaker's Project Knowledge for their core expertise, speaking angles, and topic accept/reject criteria.

| Score | Fit Level                                                      |
|-------|----------------------------------------------------------------|
| 9-10  | Perfect match to core expertise — event is specifically about the speaker's primary topics |
| 7-8   | Strong match to speaking angles — event covers adjacent or overlapping topics |
| 5-6   | Moderate match — general topic area with some relevance to the speaker's expertise |
| 3-4   | Tangential — speaker could contribute but it is not their domain |
| 1-2   | Poor fit — topics fall into the speaker's reject criteria       |

### Scoring Notes
- Match against the speaker's specific speaking angles, not just broad expertise areas
- An event about "leadership" scores lower than an event about the speaker's specific approach to leadership
- Events covering the speaker's reject topics score 1-2 regardless of other factors

---

## Dimension 2 — Location Score (1-10)

Format preference and proximity to the speaker's home base. Use the speaker's Project Knowledge for their location and format preferences.

| Score | Format/Location                                                |
|-------|----------------------------------------------------------------|
| 9-10  | Virtual/online — no travel required                            |
| 7-8   | Hybrid with virtual option, or speaker's home region in-person |
| 5-6   | In-person, same coast or nearby region                         |
| 4-5   | In-person, domestic but distant                                |
| 2-3   | International in-person                                        |
| 1     | Remote location with difficult logistics                       |

### Scoring Notes
- Virtual events always score highest unless the speaker's Project Knowledge indicates a preference for in-person
- Adjust the location tiers based on the speaker's actual home base — "same coast" is relative
- If location is unknown, default to 5

---

## Dimension 3 — Date Availability Score (1-10)

How much advance notice the opportunity provides. More lead time = higher score, because it allows the speaker to plan and prepare.

| Score | Advance Notice                                                |
|-------|---------------------------------------------------------------|
| 10    | 12-18 months out (major conferences) or "Ongoing" (podcasts) |
| 9     | 6-12 months out                                               |
| 7-8   | 3-6 months out                                                |
| 5-6   | 1-3 months out                                                |
| 3-4   | 2-4 weeks out                                                 |
| 1-2   | Less than 2 weeks out or date already passed                  |

### Scoring Notes
- Podcasts with rolling guest applications score 10 (recorded on speaker's schedule)
- "Date unknown" defaults to 5 unless other signals suggest timing
- Past events score 1 and get Action = "Skip - Past Event"
- **Watch exception**: when an opportunity is being routed to "Watch - Apply Next Cycle [YEAR]", score Date against the *next* cycle's expected date — not the closed one. See Grade Override Rules below.

---

## Dimension 4 — Value Score (1-10)

What the speaker gets from the opportunity. Scoring criteria differ based on Opportunity Type.

### For PAID Opportunities (Opportunity Type = Paid)

Score based on compensation evidence:

| Score | Evidence                                                      |
|-------|---------------------------------------------------------------|
| 9-10  | Explicit fee amount stated ($5K+)                             |
| 7-8   | "Honorarium provided" or speaker bureau listing with implied fee |
| 5-6   | "Paid opportunity" stated but no amount specified             |
| 3-4   | Payment implied but not confirmed (e.g., "speakers are compensated") |

### Floor-Aware Scoring (when Minimum Fee Floor is set in Project Knowledge)

If the speaker's Project Knowledge specifies a **Minimum Fee Floor** by format (e.g., Virtual: $1,500 · Driving: $2,500 · Air-travel: $5,000+), use these rules **after** computing the raw Value Score:

1. Find the relevant floor for this opportunity's format and travel requirement.
2. If a confirmed fee is below the floor, the Value Score still reflects compensation evidence (it might still be 7-8 if explicit, e.g., "$500 honorarium clearly stated"). Don't artificially deflate the score — the score reflects evidence quality.
3. **The action shifts**: if the fee is confirmed below the floor and the opportunity is otherwise A/B grade, the Action becomes "Apply - Credential" instead of "Apply." Rationale must state the actual fee AND the floor it falls under, so the speaker can decide.
4. If Project Knowledge sets `Below-Floor Credential Value = N` (the speaker has opted out of credential plays), the Action becomes "Skip - Below Floor" instead.
5. If the fee is *unknown* (no amount stated), do not assume below-floor. Action stays Apply (or whatever the grade indicates) and Rationale notes "compensation amount not specified — verify with organizer."

### For FREE Opportunities (Opportunity Type = Free)

Score based on visibility and exposure value:

| Score | Visibility Value                                              |
|-------|---------------------------------------------------------------|
| 9-10  | Large audience (10K+ attendees/downloads), high-profile platform, content repurposing potential |
| 7-8   | Good audience (1K-10K), established platform with track record |
| 5-6   | Moderate audience, growing platform                           |
| 3-4   | Small but targeted audience (relevant niche)                  |
| 1-2   | Minimal audience (<1K) — Action = "Skip - Low Visibility"    |

### For UNKNOWN Opportunities (Opportunity Type = Unknown)

Score based on whatever evidence is available. Default to 4 if no signals exist.

### Scoring Notes
- Never inflate Value Score without evidence. "Paid opportunity" is NOT the same as "$10K honorarium"
- For free opportunities, audience quality matters as much as audience size — 500 ideal-fit attendees can score higher than 5,000 general audience
- Content repurposing potential (video recording, transcript provided) adds 1-2 points to free opportunity scores

---

## Dimension 5 — Audience Match (1-10)

How well the event's audience matches the speaker's target audience. Use the speaker's Project Knowledge for primary, secondary, and poor-fit audience definitions.

| Score | Audience Fit                                                  |
|-------|---------------------------------------------------------------|
| 9-10  | Primary audience — event audience is exactly the speaker's ideal listener/buyer |
| 7-8   | Secondary audience — strong overlap with the speaker's target market |
| 5-6   | Moderate fit — some audience members are relevant, others are not |
| 3-4   | Weak fit — mostly the wrong audience with a few relevant attendees |
| 1-2   | Poor fit — audience is in the speaker's "poor fit" category   |

### Scoring Notes
- Match against the speaker's specific audience tiers from Project Knowledge
- Industry alignment matters — an event in the speaker's target industry scores higher even if the specific audience descriptor does not match perfectly
- Events with "general professional" audiences default to 5-6 unless specific audience details suggest otherwise

---

## Overall Grade Calculation

Average all 5 dimension scores:

| Grade | Average Score Range | Meaning                                    |
|-------|--------------------|--------------------------------------------|
| A     | 8.0 - 10.0         | Excellent fit — pursue actively             |
| B     | 6.0 - 7.9          | Good fit — worth applying                   |
| C     | 4.0 - 5.9          | Moderate fit — consider if capacity allows  |
| D     | Below 4.0          | Poor fit — likely not worth the time        |
| Skip  | N/A                | Not fully evaluated due to exclusion trigger |

### Grade Override Rules

- If **any single dimension scores 1-2**, the overall grade cannot be higher than C regardless of the average. A critical weakness in one dimension disqualifies an otherwise strong opportunity.
- If **Relevance scores 1-2**, the Action should be "Skip - Not Relevant" regardless of other scores.
- If **Value scores 1-2 and Opportunity Type = Free**, the Action should be "Skip - Low Visibility."
- **Watch exception:** when an opportunity is being routed to "Watch - Apply Next Cycle [YEAR]" via the action-assignment decision sequence (step 5), the Date Availability score is computed against the *next* cycle, not the closed one. This means the Date=1 cap does not apply, because the opportunity isn't actually past — the speaker is being told to apply when the next CFP opens. A strong recurring event whose 2026 deadline closed should still surface as B/A so the speaker calendars it.

---

## Action Assignment

The Overall Grade alone does not determine the Action — several modifiers from Project Knowledge and search evidence reshape it. Apply this decision sequence in order:

1. **Exclusion check** — if Skip - Pay to Play, Skip - Not Relevant, or Skip - Low Visibility applies, stop here.
2. **No-stipend-travel check** — if the opportunity is in-person, unpaid (Type = Free, no stipend, no travel coverage), and requires non-trivial travel from the speaker's home base (air travel, or a drive that the location-scoring profile penalizes 5 or below): Skip - No Stipend, Travel Required. The math doesn't work — the speaker would pay to attend a free gig.
3. **Past-event check** — if event date has passed and the event does not recur on a known annual cycle: Skip - Past Event. If it recurs annually: route to Watch (see step 5).
4. **CFP-closed check** — if the application deadline has passed:
   - One-off / non-recurring event: Skip - Application Closed
   - Annual recurring event: route to Watch (step 5)
5. **Watch routing** — if the opportunity recurs annually and the current cycle is past or closed: Action = "Watch - Apply Next Cycle [YEAR]". **When this fires, re-score Date Availability against the next cycle's expected date, not the closed one.** This prevents the Date=1 cap from artificially demoting a strong recurring event whose only sin is timing — the speaker's grade should reflect fit, not when the calendar lands.
6. **Direct-outreach check** — if Grade is A or B AND no public CFP / application URL / rolling submission is findable (the discovery-driven primary trigger), OR the event is named in Direct-Outreach Targets in Project Knowledge (the additive trigger): Apply - Direct Outreach (with contact path in Rationale).
7. **Floor check (paid opportunities only)** — if Grade is A or B AND opportunity is paid AND confirmed fee is below the speaker's Minimum Fee Floor:
   - Default: Apply - Credential (with actual fee + floor in Rationale)
   - If `Below-Floor Credential Value = N`: Skip - Below Floor
8. **Default** — Grade A/B → Apply · Grade C → Consider · Grade D → no action (logged for history only)

| Action                          | Criteria                                              |
|---------------------------------|-------------------------------------------------------|
| Apply                           | Grade A/B, paid above floor (or floor unset), public CFP |
| Apply - Credential              | Grade A/B, paid below floor, speaker accepts credential plays |
| Apply - Direct Outreach         | Grade A/B, no public CFP (primary), or named in Direct-Outreach Targets (additive) |
| Watch - Apply Next Cycle [YEAR] | Annual event whose current cycle is past/closed; score Date against next cycle |
| Consider                        | Grade C                                               |
| Skip - Not Relevant             | Relevance score 1-2, or topics in speaker's reject list |
| Skip - Low Visibility           | Free opportunity with Value score 1-2                 |
| Skip - No Stipend, Travel Required | Unpaid in-person event requiring non-trivial travel  |
| Skip - Past Event               | Non-recurring past event                              |
| Skip - Application Closed       | One-off / non-recurring CFP closed                    |
| Skip - Pay to Play              | Exclusion triggered (see [exclusions.md](exclusions.md)) |
| Skip - Below Floor              | Paid below floor AND speaker opted out of credential plays |
