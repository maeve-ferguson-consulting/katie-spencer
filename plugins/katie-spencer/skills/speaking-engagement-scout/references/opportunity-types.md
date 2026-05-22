# Opportunity Types

Classification rules for speaking opportunities. Accurate classification is critical — speakers filter on Opportunity Type. Getting this wrong wastes the speaker's time.

**Scope:** this skill covers discrete speaking opportunities — conferences, summits, podcast guest appearances, panels, workshops, keynotes. It does **not** surface always-on media platforms (Featured.com, Qwoted, HARO replacements, journalist-source matching). Those are query-response tools, not speaking engagements; sub-agents should skip them.

---

## Opportunity Type Classification

### Paid

Evidence of speaker compensation must be present.

| Evidence Level | Examples                                                    |
|----------------|-------------------------------------------------------------|
| Confirmed paid | Explicit fee amount ("$5,000 honorarium"), speaker bureau listing, "speakers are paid" |
| Likely paid    | "Honorarium provided," "speaker fee available," "compensated speakers" |
| Possibly paid  | Speaker bureau listing without explicit fee mention, corporate event requesting proposals |

**Rule:** Classify as "Paid" only when there is at least "likely paid" evidence. "Possibly paid" should be classified as "Unknown."

### Free

No compensation offered, or explicitly stated as unpaid.

| Evidence Level | Examples                                                    |
|----------------|-------------------------------------------------------------|
| Confirmed free | "Unpaid," "volunteer speakers," "exposure opportunity," no compensation mentioned and event is a podcast or community summit |
| Likely free    | Podcast guest spots (most do not pay), community events, open calls for speakers with no mention of compensation |

**Rule:** Classify as "Free" when there is strong evidence of no payment OR when the opportunity type defaults to unpaid (e.g., most podcast guest appearances).

### Unknown

Cannot determine payment status from available information.

| When to Use   | Examples                                                    |
|----------------|-------------------------------------------------------------|
| No payment info | Conference with call for speakers that does not mention compensation either way |
| Mixed signals  | "Select speakers may receive honorariums" (some paid, some not) |
| Ambiguous      | Corporate event with no speaker compensation details        |

**Rule:** When in doubt, classify as "Unknown." Never guess "Paid" without evidence.

---

## Format Classification

| Format    | Definition                                                    |
|-----------|---------------------------------------------------------------|
| Virtual   | Entirely online — webinar, virtual summit, online podcast, livestream |
| In-Person | Physical attendance required — conference, retreat, workshop   |
| Hybrid    | Both virtual and in-person options available                   |
| Unknown   | Format not specified                                          |

---

## Action Categories

### Apply (A/B Grade)

Opportunities worth pursuing through the standard application path. The speaker should submit a proposal, pitch, or guest application.

- A grade: Pursue immediately — excellent fit across all dimensions, paid opportunity meets/exceeds Minimum Fee Floor (or floor is unset and fit is overwhelming)
- B grade: Strong candidate — worth applying, may have one weaker dimension

### Apply - Credential (A/B grade with paid fee below floor)

Paid opportunity with confirmed compensation **below** the speaker's Minimum Fee Floor (read from Project Knowledge). The fit is strong but the fee doesn't clear the bar — the speaker should evaluate whether the credential value (audience, platform prestige, portfolio piece) justifies taking the engagement at a discount.

- Required in Rationale: actual fee found AND the floor it falls under (e.g., "Confirmed $500 honorarium; speaker's virtual floor is $1,500")
- Triggers when: Project Knowledge specifies a Minimum Fee Floor AND the opportunity has confirmed paid compensation AND that compensation is below the floor. If Project Knowledge sets `Below-Floor Credential Value = N`, downgrade to Skip - Below Floor instead.
- Default: most speakers benefit from a credential pipeline; default to allowing this action unless explicitly opted out.
- **Not for $0 events.** If the opportunity has zero compensation (not just below-floor — actually unpaid), use Skip - No Stipend, Travel Required if travel is required, or treat as a Free opportunity scored on visibility.

### Apply - Direct Outreach (high-fit target with no public CFP)

The opportunity is a high-fit target but has no public application process — typically a flagship event in the speaker's niche that books speakers via direct invitation or relationship. Recommend the speaker reach out via email / LinkedIn / a warm intro.

- Required in Rationale: the recommended contact path (email address, LinkedIn handle, or "via [warm intro through X]")
- **Two trigger paths:**
  - **Primary (discovery-driven):** opportunity scores A or B AND no public CFP, no application URL, no rolling submission process is findable. This is the most common trigger and fires automatically whenever the orchestrator can't locate a standard way for the speaker to apply.
  - **Additive (speaker-named):** the event is named in the speaker's optional Direct-Outreach Targets list in Project Knowledge. The scout surfaces it regardless of whether the discovery path also fires.
- The speaker-named list is **optional**. A speaker who hasn't filled it in still gets Direct Outreach recommendations whenever the discovery path fires.

### Watch - Apply Next Cycle [YEAR] (annual events with closed current cycle)

The current cycle's CFP/deadline has closed, but the event recurs annually. Score the opportunity normally — it's a good fit; the speaker just can't apply *right now*. The Action specifies the next cycle year so this becomes a calendar trigger.

- Required in Rationale: the closed deadline date AND the expected next-cycle date or season (e.g., "2026 CFP closed Mar 27; expect 2027 CFP to open in early 2026")
- Triggers when: the event has documented prior years of recurrence (annual conference, annual summit) AND the current cycle's CFP/deadline is closed AND the opportunity otherwise scored A/B/C
- Distinct from Skip - Application Closed, which is reserved for one-off or non-recurring events
- **Score Date Availability against the next cycle, not the closed one.** A strong recurring event whose 2026 deadline closed should still surface as B/A so the speaker calendars it.

### Consider (C Grade)

Opportunities that merit review but are not automatic applies. The speaker should assess whether capacity and strategic priorities make this worth pursuing.

### Skip Categories

All skip actions still get logged to prevent re-finding.

| Skip Action              | Trigger                                                    |
|--------------------------|------------------------------------------------------------|
| Skip - Not Relevant      | Topics do not match speaker's expertise. Relevance score 1-2. |
| Skip - Low Visibility    | Free opportunity with minimal audience (<1K). Value score 1-2 for free opportunities. |
| Skip - No Stipend, Travel Required | Unpaid in-person event that requires non-trivial travel (air travel, or a long drive that the speaker's location-scoring profile penalizes). The speaker would absorb travel costs for zero compensation. Use this when an opportunity is otherwise topic-relevant but the math doesn't work. Distinct from Skip - Low Visibility (which is about audience size). Default Skip unless the opportunity has overwhelming audience prestige AND the speaker has flagged willingness to absorb travel for visibility plays. |
| Skip - Past Event        | Event has happened and does not recur. Annual events that recur use Watch instead. |
| Skip - Application Closed | One-off or non-recurring event whose CFP has passed. Annual recurring events use Watch instead. |
| Skip - Pay to Play       | Speaker would have to pay money. Exclusion triggered. See [exclusions.md](exclusions.md). |
| Skip - Below Floor       | Paid opportunity below speaker's Minimum Fee Floor AND speaker has explicitly opted out of credential plays (Below-Floor Credential Value = N in Project Knowledge). Use rarely — most speakers default to Apply - Credential. |

---

## Application Status Verification

Before logging any opportunity, verify:

1. **Is the event in the future?**
   - If event date has passed AND the event does not recur: Action = "Skip - Past Event"
   - If event date has passed AND event recurs annually: Action = "Watch - Apply Next Cycle [YEAR]"
   - Exception: Podcasts with "Ongoing" dates (rolling guest applications) — score normally as Apply

2. **Is the call for speakers/guests still open?**
   - Look for: application deadline dates, "Call for speakers closed" notices, "Applications now open" vs "Applications closed," and for podcasts: "Currently accepting guests" vs "Not accepting guests"
   - If deadline has passed AND the event recurs annually: Watch - Apply Next Cycle [YEAR]
   - If deadline has passed AND it's a one-off: Skip - Application Closed

3. **Include deadline info in Rationale** if found (e.g., "CFP deadline: Feb 15, 2026")
