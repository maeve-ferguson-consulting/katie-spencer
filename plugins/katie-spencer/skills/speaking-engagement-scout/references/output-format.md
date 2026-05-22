# Output Format

Sheet structure (15 columns) and summary format for logging and presenting speaking opportunity findings.

---

## Google Sheet Column Structure (15 Columns)

All opportunities are logged using this exact column order. This structure is universal across all speakers.

| #  | Column                 | Type   | Source            | Notes                                                    |
|----|------------------------|--------|-------------------|----------------------------------------------------------|
| 1  | Opportunity Name       | Text   | Search            | Event, podcast, or conference name                       |
| 2  | Location               | Text   | Search            | City/Country or "Virtual"                                |
| 3  | Date                   | Text   | Search            | Event date(s), "Ongoing" for podcasts, or "Unknown"      |
| 4  | Application Link       | URL    | Search            | URL to apply or submit, or "N/A" if none found           |
| 5  | Opportunity Type       | Text   | AI Classification | **Paid** / **Free** / **Unknown** — speaker filters on this |
| 6  | Format                 | Text   | Search            | In-Person / Virtual / Hybrid / Unknown                   |
| 7  | Relevance Score        | Number | AI Scoring        | 1-10 (0 if skipped)                                      |
| 8  | Location Score         | Number | AI Scoring        | 1-10 (0 if skipped)                                      |
| 9  | Date Availability Score| Number | AI Scoring        | 1-10 (0 if skipped). For Watch entries, scored against next cycle |
| 10 | Value Score            | Number | AI Scoring        | 1-10 (0 if skipped) — Compensation for Paid, Visibility for Free |
| 11 | Audience Match         | Number | AI Scoring        | 1-10 (0 if skipped)                                      |
| 12 | Overall Grade          | Text   | Calculated        | A / B / C / D / Skip                                     |
| 13 | Action                 | Text   | AI Recommendation | Apply / Apply - Credential / Apply - Direct Outreach / Watch - Apply Next Cycle [YEAR] / Consider / Skip - [Reason] (Skip variants: Not Relevant, Low Visibility, No Stipend Travel Required, Past Event, Application Closed, Pay to Play, Below Floor) |
| 14 | Rationale              | Text   | AI Generated      | Why this grade/action — include payment evidence (and how it compares to Minimum Fee Floor), visibility metrics, deadline info, recommended contact path for Direct Outreach, expected next-cycle date for Watch entries, travel-cost reasoning for No Stipend skips |
| 15 | Scouted                | Date   | System            | Date the opportunity was found (e.g., "2026-03-22")      |

### Column Rules

- **Column 5 (Opportunity Type):** This is the most critical classification field. The speaker uses this to filter the sheet. Must be exactly "Paid", "Free", or "Unknown" — no variations.
- **Columns 7-11 (Scores):** Use 0 for all scores when an opportunity is excluded (Action starts with "Skip"). Use 1-10 for all evaluated opportunities.
- **Column 12 (Overall Grade):** Calculated from the average of columns 7-11. Use "Skip" when the opportunity was excluded before scoring.
- **Column 14 (Rationale):** Must include specific evidence. Good: "Honorarium of $3,000 stated on CFP page. Audience is 500+ HR executives." Bad: "Looks like a good opportunity."
- **Column 15 (Scouted):** Today's date in YYYY-MM-DD format.

---

## Summary Format (Presented in Conversation)

After logging (or in place of logging if no Google Sheets), present this summary.

### Run Header

```
## Speaking Opportunity Scout — [Date]
```

### Run Statistics

```
### Run Stats
- **Total opportunities found:** [N]
- **New (not previously logged):** [N]
- **By grade:** A: [N] | B: [N] | C: [N] | D: [N] | Skip: [N]
- **By type:** Paid: [N] | Free: [N] | Unknown: [N]
- **By action:** Apply: [N] | Apply - Credential: [N] | Apply - Direct Outreach: [N] | Watch: [N] | Consider: [N] | Skip: [N total — break out by reason in the Skipped section below]
```

### Top Opportunities (A and B Grade)

For each A or B grade opportunity, present:

```
### [Grade] — [Opportunity Name]
- **Type:** Paid/Free | **Format:** Virtual/In-Person/Hybrid
- **Date:** [date] | **Location:** [location]
- **Scores:** Relevance [N] | Location [N] | Date [N] | Value [N] | Audience [N] → Average [N.N]
- **Action:** Apply
- **Why:** [1-2 sentence rationale with specific evidence]
- **Link:** [URL or N/A]
```

### Direct Outreach List

For Apply - Direct Outreach items, present as a compact table — these are high-fit targets that need direct contact rather than a CFP submission:

```
### Apply - Direct Outreach

| Opportunity | Grade | Why High-Fit | Recommended Contact Path |
|-------------|-------|--------------|--------------------------|
| [name]      | A     | [one line]   | [email / LinkedIn / warm intro] |
```

### Apply - Credential List

For Apply - Credential items (paid below speaker's floor), present as a compact table so the speaker can quickly decide whether the credential value is worth taking each one:

```
### Apply - Credential (Below Stated Floor)

| Opportunity | Confirmed Fee | Floor | Why Worth Considering |
|-------------|---------------|-------|------------------------|
| [name]      | $500          | $1,500 (virtual) | [credential value — audience size, platform prestige, ladder potential] |
```

### Watch List (Apply Next Cycle)

For Watch items, present as a compact table — these are calendar triggers, not action items for now:

```
### Watch — Apply Next Cycle

| Opportunity | Next Cycle Year | Last CFP Closed | Why Worth Tracking |
|-------------|-----------------|------------------|---------------------|
| [name]      | 2027            | 2026-04-02       | [grade-A fit; expected CFP open date] |
```

### Consider List (C Grade)

Present as a compact table:

```
### Worth Considering

| Opportunity | Type | Format | Grade | Key Factor |
|-------------|------|--------|-------|------------|
| [name]      | Paid | Virtual| C     | [one-line reason] |
```

### Skipped (Summary Only)

```
### Skipped ([N] opportunities)
- Not Relevant: [N]
- Low Visibility: [N]
- No Stipend, Travel Required: [N]
- Past Event: [N]
- Application Closed: [N]
- Pay to Play: [N]
- Below Floor: [N]
```

### Patterns Observed

```
### Patterns
- [Observation about what types of opportunities are most available]
- [Any market signals — e.g., "Many conferences in [industry] are actively seeking speakers for Q3"]
- [Run-mode notes — e.g., "Run constrained: Agent tool unavailable; searches executed inline in main thread"]
- [Suggestions for next run — e.g., "Consider searching [specific platform] next time"]
```

---

## Markdown Table Format (When No Google Sheets)

When Google Sheets MCP is unavailable, present all findings as a markdown table. Use the same 15 columns but split into two tables for readability.

### Table 1 — Opportunity Details

```
| # | Opportunity Name | Location | Date | Link | Type | Format |
|---|-----------------|----------|------|------|------|--------|
```

### Table 2 — Scoring and Action

```
| # | Relevance | Location | Date Avail | Value | Audience | Grade | Action | Rationale |
|---|-----------|----------|------------|-------|----------|-------|--------|-----------|
```

Match rows by the # column. Include the Scouted date in the summary header rather than repeating it per row.

---

## Notification Format (If Slack or Other Messaging Is Configured)

If the speaker's Project Knowledge includes a notification channel:

```
Speaking Scout — [Date]

Found [N] new opportunities ([A count] A-grade, [B count] B-grade)

Top picks:
1. [A/B] [Opportunity Name] — [Paid/Free] [Virtual/In-Person] — [1-line reason]
2. [A/B] [Opportunity Name] — [Paid/Free] [Virtual/In-Person] — [1-line reason]

[Link to Google Sheet]
```
