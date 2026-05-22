# Required Sections — Rationale

Every consulting services agreement should include these sections. If `AGREEMENT_TEMPLATE.md` is missing one, the skill warns the consultant with the one-line rationale below, and offers a generic boilerplate the consultant approves before insertion. Never silently inserted. Never silently omitted.

## The required twelve

### 1. Cover paragraph (default ON, suppressible)
**Why:** A clinical contract delivered cold is more friction than warmth. A 3-4 sentence cover paragraph in the consultant's voice signals "this is the agreement that turns what we talked about into something real" rather than "here's a legal document". Default ON; consultants can suppress with `--no-cover` or by setting `BRAND.md.voice_rules.cover_paragraph: false`.

### 2. Parties
**Why:** Identifies who is contracting with whom. Without this clause the agreement is unenforceable. Pulls from `consultant.legal_entity` + `prospect.org_name`.

### 3. Effective Date & Term
**Why:** When the obligations begin and end. The effective date is independent of work start; some consultants begin work on verbal yes and have the contract catch up. The term sets the engagement boundary.

### 4. Scope of Services
**Why:** What the consultant is committing to deliver. This is where the proposal's `selected_offers[].deliverables` land verbatim. The single largest source of contract disputes is scope ambiguity — never compress, never paraphrase.

### 5. Investment & Payment Terms
**Why:** What the client owes and when. Pulls `total_investment_usd` and `payment_schedule` from the proposal scope verbatim. Includes payment net (Net 15 / Net 30 etc.) and late-fee policy if any.

### 6. Timeline
**Why:** Distinguishes engagement timing from payment timing. Many proposals run sessions on a different cadence than invoices — this section makes the work calendar explicit. Pulls `start_window` and milestone `trigger` dates.

### 7. Exclusions
**Why:** What the engagement is explicitly NOT. Strong contracts say no clearly. The skill omits this section when `scope.exclusions` is empty — explicit nothing is acceptable. When present, exclusions are quoted verbatim.

### 8. Term & Termination
**Why:** How either party gets out. Most consulting agreements use 30 days written notice from either party. Some use 60. Some use for-cause-only. Whichever the consultant prefers — captured in `template.default_termination_clause`. If missing from the template, the skill warns and offers the 30-day default.

### 9. Confidentiality
**Why:** Both parties handle non-public information. Standard term: confidentiality survives termination for a defined period (2 years is common; some industries require 5+). The skill warns if `template.confidentiality_term_years` is missing.

### 10. IP / Work Product Ownership
**Why:** Who owns what the consultant produces. The standard consulting default is "consultant retains methodology IP, client owns the specific deliverables produced for them" — this lets the consultant reuse frameworks while the client owns their materials. Some engagements use work-made-for-hire (client owns everything); some use license-back (consultant owns, client gets perpetual license). The skill warns if `template.ip_ownership` is missing and offers the standard default.

### 11. Limitation of Liability
**Why:** Caps the consultant's exposure. Most consulting agreements cap liability at "aggregate fees paid under this Agreement". Without this clause the consultant has unlimited exposure for consequential damages — which is rarely what either side actually wants. The skill warns if missing and offers the standard cap.

### 12. Governing Law & Dispute Resolution
**Why:** Which state's law applies and how disputes get resolved. Many consultants prefer mediation-first dispute resolution (cheaper than litigation for the small dollar amounts typical in consulting). REQUIRED — the skill stops and asks rather than guessing.

### 13. Signatures
**Why:** Where the agreement becomes an agreement. Two-column signature block: consultant and counterparty. Pulls names from `signature_block` template config substituted against proposal scope. Standard fields: printed name, title, entity, signature line, date.

## Sections the skill NEVER auto-adds

The skill is a template-filler, not a clause library. It will WARN if any of the above is missing and OFFER a generic boilerplate, but the consultant approves the language before it goes in.

It will NEVER auto-add:
- **Revenue share clauses** — opt-in via `optional_clauses.revenue_share: true` AND a `custom_terms` reference in the proposal
- **Data partnership / data licensing clauses** — opt-in via `optional_clauses.data_partnership: true` AND a `custom_terms` reference
- **Performance / outcome-based compensation** — opt-in via `optional_clauses.performance_share: true`
- **Non-compete** — almost always unenforceable in consulting and rarely worth the legal exposure
- **Personal guarantee** — only if the consultant specifically requests; default off
- **Liquidated damages** — too jurisdiction-specific to template

## Sections the skill auto-suppresses

- **Exclusions** if `scope.exclusions` is empty.
- **Custom Terms** if `scope.custom_terms` is empty.
- **Optional Add-ons** if `scope.optional_addons` is empty (and clearly labeled as NOT included in total when rendered).

## Warning format

When a required section is missing from `AGREEMENT_TEMPLATE.md`, the skill surfaces it like:

```
⚠ Your template is missing: Limitation of Liability
  Rationale: Without this clause, your aggregate exposure is unlimited.
             Most consultants cap at "total fees paid under this Agreement."
  Offer:     Insert a standard cap clause for this deal?
             [yes / no / yes-and-update-template]
```

The third option (`yes-and-update-template`) tells the skill to also patch `AGREEMENT_TEMPLATE.md` so the warning stops appearing on future runs. This is the recommended path — the template should grow into the consultant's preferred shape over time.
