# Sub-Agent Research Prompts

How to spawn research sub-agents and structure their web search queries. Each sub-agent runs independently with web search and returns structured findings to the main thread.

---

## Spawning Sub-Agents

Spawn all 3 sub-agents in a single message so they run in parallel. Each sub-agent uses the Agent tool and must have web search access.

### Year Injection (do this BEFORE spawning)

The prompt templates below contain placeholder strings `{{CURRENT_YEAR}}` and `{{NEXT_YEAR}}`. Sub-agents do not have a reliable internal sense of "today" — if you leave the placeholders unresolved, the sub-agent will either ask you for the year or invent one, which silently corrupts the search scope.

Before each Agent call, look up today's actual date and substitute concrete values into the prompt text:

- `{{CURRENT_YEAR}}` → the current calendar year (4 digits, e.g., `2026`)
- `{{NEXT_YEAR}}` → the year after that (e.g., `2027`)

Substitute every occurrence in the prompt. Verify the rendered prompt has no remaining `{{...}}` markers before sending it. If today's date is past September, also consider whether to extend the horizon to `{{NEXT_YEAR + 1}}` since major conferences book 12–18 months ahead — most fall conferences for next year are already scoped by mid-summer.

### Profile Injection

Beyond year placeholders, fill these from the speaker's Project Knowledge before spawning:
1. The speaker's profile (name, title, location, preferred format)
2. The speaker's expertise areas and speaking angles
3. The speaker's target audience and industries
4. The speaker's **Minimum Fee Floor** (if set) — sub-agents should report exact compensation evidence when found, so the main thread can compare to the floor
5. Any **Direct-Outreach Targets** named in Project Knowledge (sub-agents should still note these even though they have no public CFP)
6. Specific search instructions for that sub-agent's category
7. The output format expected (structured list of opportunities)
8. The exclusion rules (pay-to-play detection — including the named registry from [exclusions.md](exclusions.md))

**What each sub-agent returns:**
A structured list of opportunities, each with:
- Opportunity name
- Location (city/country or "Virtual")
- Date (event dates or "Ongoing" or "Unknown")
- Application link (URL or "N/A")
- Opportunity type (Paid / Free / Unknown) with evidence
- Format (In-Person / Virtual / Hybrid / Unknown)
- Brief notes on audience, topic fit, and any payment evidence found

---

## Sub-Agent 1 — Paid Opportunities

### Prompt Template

```
You are a research assistant searching for PAID speaking opportunities. Your goal is to find conferences, corporate events, and speaker bureau listings that pay speakers an honorarium or fee.

SPEAKER PROFILE:
[Insert speaker profile from Project Knowledge]

EXPERTISE AND SPEAKING ANGLES:
[Insert expertise and speaking angles from Project Knowledge]

TARGET INDUSTRIES:
[Insert target industries from Project Knowledge]

MINIMUM FEE FLOOR (if set):
[Insert floor by format — used by main thread to classify Apply vs Apply - Credential. You don't filter by it; just report exact compensation evidence found.]

SEARCH INSTRUCTIONS:
Perform web searches to find paid speaking opportunities. Use the cascading refinement approach — each search builds on the previous results.

Search 1 — Broad paid search:
Search for: [speaker's primary topics] + "honorarium" OR "paid keynote" OR "speaker fee" + {{CURRENT_YEAR}} {{NEXT_YEAR}}

Search 2 — Refine based on Search 1:
- If Search 1 found promising leads, dig deeper into those platforms or event series
- If Search 1 was a dead end, try: corporate events + "speaker fee" + [speaker's industries]

Search 3 — Speaker bureaus and platforms:
Search for the speaker's topics on these platforms: eSpeakers, SpeakerHub, Innovation Women, BigSpeak, Washington Speakers Bureau, GDA Speakers, Women Speakers Association

PAY-TO-PLAY DETECTION:
Before including any opportunity, verify the speaker is NOT being asked to pay. Exclude:
- Speaker training programs
- Pay-to-be-in-directory schemes
- Pay-to-participate summits
- Speaker bureaus charging speakers for listings
- Certification programs
- Any arrangement where the speaker pays money
- The named pay-to-play registry: Forbes Councils (any variant), Newsweek Expert Forum, Rolling Stone Culture Council, Fast Company Executive Board, Inc. Editorial Council variants

OUTPUT FORMAT:
For each opportunity found, provide:
1. Opportunity Name
2. Location (city/country or "Virtual")
3. Date (event dates, "Ongoing", or "Unknown")
4. Application Link (URL or "N/A")
5. Opportunity Type: "Paid" — include the payment evidence (exact quote or description with source URL)
6. Format (In-Person / Virtual / Hybrid / Unknown)
7. Notes: audience info, topic match assessment, any other relevant details

Return ALL opportunities found, even marginal ones. The main thread will score and filter.
```

---

## Sub-Agent 2 — Visibility Opportunities

### Prompt Template

```
You are a research assistant searching for high-visibility speaking opportunities — podcast guest appearances, virtual summits seeking speakers, and panel/media appearances tied to discrete events. **Out of scope:** always-on media platforms (Featured.com, Qwoted, HARO replacements, journalist-source matching services). They aren't speaking engagements — they're query-response platforms. Do not include them.

SPEAKER PROFILE:
[Insert speaker profile from Project Knowledge]

EXPERTISE AND SPEAKING ANGLES:
[Insert expertise and speaking angles from Project Knowledge]

TARGET AUDIENCE:
[Insert target audience from Project Knowledge]

SEARCH INSTRUCTIONS:
Perform web searches to find visibility-focused speaking opportunities. Use the cascading refinement approach.

Search 1 — Podcast guest opportunities (specific shows accepting guests):
Search for: podcast + [speaker's primary topics] + "accepting guests" OR "guest application" OR "be a guest"

Search 2 — Virtual summits and online events:
Search for: virtual summit + "call for speakers" + [speaker's topics] + {{CURRENT_YEAR}} {{NEXT_YEAR}}

Search 3 — Discrete-event guest expert / panel slots:
Search for: [speaker's topics] + "guest expert" OR "featured speaker" + "event" OR "summit" OR "conference"
Podcast-discovery only: Podchaser, MatchMaker.fm, PodcastGuests.com (these surface specific shows accepting guests — that's a discrete engagement, fine to include).
Skip: HARO, Featured.com, Qwoted, and any journalist-source matching service.

PAY-TO-PLAY DETECTION:
Before including any opportunity, verify the speaker is NOT being asked to pay. Exclude any opportunity where the speaker pays money to participate. Also exclude the named pay-to-play registry (see exclusions.md).

OUTPUT FORMAT:
For each opportunity found, provide:
1. Opportunity Name
2. Location: "Virtual" for all online opportunities, or city/country for in-person
3. Date: event dates, "Ongoing" for podcasts accepting rolling applications, or "Unknown"
4. Application Link (URL or "N/A")
5. Opportunity Type: "Free" or "Unknown" — note any audience size or download metrics found
6. Format (Virtual / In-Person / Hybrid / Unknown)
7. Notes: audience size if found, platform reputation, content repurposing potential, topic match assessment

Return ALL opportunities found, even marginal ones. The main thread will score and filter.
```

---

## Sub-Agent 3 — Targeted/Niche Opportunities

### Prompt Template

```
You are a research assistant searching for niche and industry-specific speaking opportunities. Your goal is to find events that serve the speaker's specific target audience and industries.

SPEAKER PROFILE:
[Insert speaker profile from Project Knowledge]

EXPERTISE AND SPEAKING ANGLES:
[Insert expertise and speaking angles from Project Knowledge]

TARGET AUDIENCE:
[Insert target audience tiers from Project Knowledge — primary, secondary, poor fit]

TARGET INDUSTRIES:
[Insert target industries from Project Knowledge — Priority 1 and Priority 2]

SEARCH INSTRUCTIONS:
Perform web searches to find industry-specific and audience-specific speaking opportunities. These are the most targeted searches — use specific industry names, audience descriptors, and event types.

Search 1 — Industry conferences:
Search for: [Priority 1 industry] + conference + "call for speakers" OR "speaker application" + {{CURRENT_YEAR}} {{NEXT_YEAR}}

Search 2 — Audience-specific events:
Search for: [primary audience descriptor] + summit OR retreat OR conference + speaker + {{CURRENT_YEAR}}

Search 3 — Niche and specialized:
Search for: [Priority 2 industry] + events + speaker + {{CURRENT_YEAR}}
Also search for: ERG events, association conferences, corporate offsite speakers, professional development events in the speaker's target industries

PAY-TO-PLAY DETECTION:
Before including any opportunity, verify the speaker is NOT being asked to pay. Exclude any opportunity where the speaker pays money to participate. Also exclude the named pay-to-play registry (see exclusions.md).

OUTPUT FORMAT:
For each opportunity found, provide:
1. Opportunity Name
2. Location (city/country or "Virtual")
3. Date (event dates, "Ongoing", or "Unknown")
4. Application Link (URL or "N/A")
5. Opportunity Type: "Paid" / "Free" / "Unknown" — include any payment evidence
6. Format (In-Person / Virtual / Hybrid / Unknown)
7. Notes: specific audience details, industry alignment, why this fits the speaker's niche, any payment evidence

Return ALL opportunities found, even marginal ones. The main thread will score and filter.
```

---

## Main Thread Synthesis

After all 3 sub-agents return, the main thread:

1. **Combines** all opportunity lists into a single master list
2. **Deduplicates** — same opportunity found by multiple sub-agents gets merged (keep the most detailed entry)
3. **Checks existing sheet** (if available) — skip any opportunity already logged
4. **Scores** each opportunity on 5 dimensions using the rubrics in [scoring-rubrics.md](scoring-rubrics.md)
5. **Runs exclusion check** using the rules in [exclusions.md](exclusions.md)
6. **Assigns grade and action** using the decision sequence in scoring-rubrics.md (which handles Watch routing, floor checks, direct-outreach detection, no-stipend-travel skips)
7. **Logs** to Google Sheet (if available) or presents as structured table
8. **Presents summary** with top picks, consider list, watch list, direct-outreach list, credential list, skip counts, and observed patterns

### Deduplication Rules

- Match on opportunity name (case-insensitive, fuzzy match for minor variations)
- If two sub-agents found the same opportunity with different details, merge them — use the most complete information
- If an opportunity appears in the existing sheet, skip it entirely (already logged)
