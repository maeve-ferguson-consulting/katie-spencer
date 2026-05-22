# Proposal Scope YAML Schema

This is the contract between `build-proposal` (producer) and `build-agreement` (consumer). Both skills implement this schema identically. Treat it as a versioned API — if a field changes, version it.

The schema lives upstream in the cross-session shared context (see the consultant-pipeline skill plans that introduced this skill batch). Mirrored here so this skill can be read standalone.

## Where the YAML lives

`build-proposal` emits the YAML in one of two locations. `build-agreement` accepts either:

1. **Sidecar:** `proposal-scope.yml` dropped next to the proposal HTML artifact. Preferred — easier to validate and re-render.
2. **Embedded:** A top-level fenced YAML block at the very bottom of the proposal HTML artifact, wrapped in an HTML comment so it doesn't render visually:

   ```html
   <!--
   ```yaml
   proposal:
     id: ...
   ```
   -->
   ```

   `build-agreement` extracts the block between the HTML comment markers, strips the fence, and parses.

## Schema

```yaml
proposal:
  # Stable identifier. Format: <consultant-short>-<YYYY-MM>-<prospect-slug>
  # Used as the doc ID in the agreement footer and as the agreements/ filename prefix.
  id: string                                 # REQUIRED

  prospect:
    org_name: string                         # REQUIRED — the legal/operating name of the prospect organization
    contact_name: string                     # REQUIRED — discovery-call contact, also default signer
    contact_title: string                    # REQUIRED — e.g., "Executive Director", "Board Chair"
    url: string                              # optional — used by build-proposal for brand matching, ignored here
    brand_colors_hex: [string, ...]          # optional — ignored by build-agreement (agreement is consultant-branded)

  consultant:
    name: string                             # REQUIRED — consultant's name as they sign
    brand_name: string                       # REQUIRED — public-facing brand (may equal name for solo consultants)
    legal_entity: string                     # optional — if set, must match AGREEMENT_TEMPLATE.md.legal_entity or skill prompts

  discovery_date: string (ISO date)          # REQUIRED — when the discovery call happened; appears in cover paragraph

  scope:
    selected_offers:                         # REQUIRED — array, ≥1
      - offer_name: string                   # REQUIRED — verbatim from SERVICES.md
        one_liner: string                    # REQUIRED — verbatim from SERVICES.md
        deliverables: [string, ...]          # REQUIRED — ≥1 — appears in Scope of Services
        duration: string                     # REQUIRED — human-readable, e.g., "4 sessions over 8 weeks"
        start_window: string                 # REQUIRED — e.g., "Week of 2026-06-09"
        investment_usd: integer              # REQUIRED — sums into total_investment_usd
        payment_terms: string                # REQUIRED — e.g., "50% on signature, 50% at midpoint"

    exclusions: [string, ...]                # optional — explicit out-of-scope items; section omitted if empty

    custom_terms: [string, ...]              # optional — deal-specific terms surfaced in discovery
                                             # if any item references rev share / data partnership / performance share,
                                             # build-agreement cross-checks against AGREEMENT_TEMPLATE.md.optional_clauses

    optional_addons:                         # optional — surfaced but NOT included in total_investment_usd
      - offer_name: string
        one_liner: string
        investment_usd: integer

  total_investment_usd: integer              # REQUIRED — must equal sum(scope.selected_offers[].investment_usd)
                                             # and sum(payment_schedule[].amount_usd)

  payment_schedule:                          # REQUIRED — array, ≥1 milestone
    - milestone: string                      # REQUIRED — e.g., "On signature", "Midpoint", "Final deliverable"
      amount_usd: integer                    # REQUIRED
      trigger: string                        # REQUIRED — e.g., "On signature" | "2026-07-15" | "On delivery of board roadmap"
```

## Validation rules

Run all of these before rendering the agreement. Fail loudly on any violation — do not paper over with defaults:

1. **All REQUIRED fields present and non-empty.** Missing field → stop and ask user to fix the proposal.
2. **`sum(payment_schedule[].amount_usd) == total_investment_usd`.** If they disagree, the proposal is malformed.
3. **`sum(selected_offers[].investment_usd) == total_investment_usd`.** Optional add-ons must NOT roll into this sum.
4. **`selected_offers` has ≥1 entry.** A proposal with zero offers shouldn't reach this skill.
5. **`payment_schedule` has ≥1 milestone.**
6. **`prospect.contact_title` non-empty.** "Executive Director" or "Board Chair" is fine; empty string is not.
7. **`discovery_date` parses as an ISO date.** YYYY-MM-DD.
8. **If `custom_terms` contains rev-share / data-partnership keywords:** cross-check `AGREEMENT_TEMPLATE.md.optional_clauses` — see SKILL.md Phase 1 Step 5.

## Example (fictional consultant — for illustration only)

```yaml
proposal:
  id: acme-2026-05-lighthouse-arts-foundation
  prospect:
    org_name: Lighthouse Arts Foundation
    contact_name: Jordan Lee
    contact_title: Executive Director
    url: https://example.org
    brand_colors_hex: ["#1a1a1a", "#c89b3c", "#f5f0e1"]
  consultant:
    name: Sam Rivera
    brand_name: Acme Governance Group
    legal_entity: Acme Governance Group LLC
  discovery_date: 2026-05-12
  scope:
    selected_offers:
      - offer_name: Board Effectiveness Sprint
        one_liner: "A 4-session program helping nonprofit executive leaders and board chairs systematically reset and build the board they need."
        deliverables:
          - Four 90-minute virtual working sessions with the ED and the board chair
          - Board capability matrix (Session 1 output)
          - Governance roadmap aligned to the upcoming succession window (Session 2 output)
          - Board meeting redesign + agenda template (Session 3 output)
          - 12-month measurement plan (Session 4 output)
        duration: "4 sessions over 8 weeks"
        start_window: "Week of 2026-06-09"
        investment_usd: 10000
        payment_terms: "50% on signature, 50% at midpoint (week 4)"
      - offer_name: Succession Readiness
        one_liner: "Prepare boards and teams for leadership transitions, planned or unexpected."
        deliverables:
          - Succession-readiness assessment for the ED's role
          - Board's role in the transition documented
          - 18-month transition timeline aligned to the next fiscal-year board calendar
        duration: "Embedded across the 8 weeks; one dedicated session in week 6"
        start_window: "Week of 2026-06-09"
        investment_usd: 3000
        payment_terms: "Bundled with Board Effectiveness Sprint payment schedule"
    exclusions:
      - "Executive search for the ED's successor — recommend an external referral partner"
      - "Funder-facing board materials beyond the governance roadmap"
    custom_terms:
      - "Sessions recorded; the prospect retains recordings; the consultant does not"
      - "Board chair attends all four sessions"
    optional_addons:
      - offer_name: Workshop - Building a Board Culture of Accountability
        one_liner: "Reframes accountability as a shared value rooted in clarity, commitment, and care."
        investment_usd: 2500
  total_investment_usd: 13000
  payment_schedule:
    - milestone: "On signature"
      amount_usd: 6500
      trigger: "On signature"
    - milestone: "Midpoint (week 4)"
      amount_usd: 6500
      trigger: "2026-07-07"
```

This example is illustrative only. Acme Governance Group LLC, Sam Rivera, and Lighthouse Arts Foundation are fictional placeholders. Real test cases live in each consultant's own eval setup, outside this universal skill source.

## Version history

- **v1** (current) — initial schema for the consultant-pipeline skill batch (`prep-discovery` → `build-proposal` → `build-agreement` → `craft-outreach`).
