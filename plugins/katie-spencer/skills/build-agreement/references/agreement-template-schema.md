# AGREEMENT_TEMPLATE.md Schema

This is the per-consultant template the skill fills with proposal scope. Lives in the consultant's Claude Project Knowledge alongside `BRAND.md` and `SERVICES.md`.

If `AGREEMENT_TEMPLATE.md` is missing, `build-agreement` elicits it via the Phase 2 first-run interview and saves the result in this shape.

## File structure

The file is a single YAML document with top-level metadata followed by a `sections` array containing handlebars-style templates. The skill walks `sections` in order, substituting placeholders against the proposal scope YAML.

```yaml
# AGREEMENT_TEMPLATE.md
legal_entity: string                          # REQUIRED — your registered legal entity name
state_of_incorporation: string                # REQUIRED — the US state (or equivalent jurisdiction)
governing_law: string                         # REQUIRED — e.g., "State of <your state>"
dispute_resolution: string                    # REQUIRED — your standard dispute-resolution clause (mediation venue, arbitration, etc.)
default_payment_net: string                   # REQUIRED — e.g., "Net 15"
late_fee_pct_per_month: number | null         # optional — e.g., 1.5; null if no late fee policy
default_termination_clause: string            # REQUIRED — e.g., "Either party may terminate with 30 days written notice"
ip_ownership: string                          # REQUIRED — the consultant's IP / work-product split, as a sentence or short paragraph
confidentiality_term_years: integer           # REQUIRED — e.g., 2
default_warranty_disclaimer: bool             # REQUIRED — most consulting agreements disclaim warranties; default true
indemnification_mutual: bool                  # REQUIRED — default true; otherwise consultant-only or client-only

optional_clauses:
  revenue_share: bool                         # default false — flips on rev-share clause inclusion
  data_partnership: bool                      # default false
  performance_share: bool                     # default false
  non_solicitation_months: integer | null     # null if not used
  travel_expenses_passthrough: bool           # default false — billed to client at cost
  liability_cap_basis: string                 # e.g., "total fees paid under this Agreement" — default if missing

signature_block:
  consultant:
    name_template: string                     # e.g., "{{consultant.name}}" — usually just substitutes from scope
    title: string                             # e.g., "Founder" or "Principal Consultant"
    entity: string                            # usually `{{legal_entity}}`
  counterparty:
    name_template: string                     # e.g., "{{prospect.contact_name}}"
    title_template: string                    # e.g., "{{prospect.contact_title}}"
    entity_template: string                   # e.g., "{{prospect.org_name}}"

sections:                                     # ordered array — walked top to bottom
  - id: string                                # stable identifier, e.g., "scope_of_services"
    title: string                             # rendered as section heading, e.g., "Scope of Services"
    required: bool                            # if true, skill never skips this section
    template: |                               # multi-line markdown with {{placeholders}}
      <markdown body with handlebars>
```

## Placeholder syntax

The skill supports a minimal handlebars subset. Implement exactly:

### Variable substitution
```
{{path.to.value}}
```
Dot-notation lookup against the proposal scope YAML. Top-level keys: `scope`, `prospect`, `consultant`, `discovery_date`, `total_investment_usd`, `payment_schedule`, plus the template's own metadata (`legal_entity`, `governing_law`, etc., available as `template.legal_entity`).

If the path doesn't resolve, the skill stops and asks the user — never silently leaves the literal `{{...}}` in the output.

### Iteration
```
{{#each scope.selected_offers}}
**{{offer_name}}** — {{one_liner}}

Deliverables:
{{#each deliverables}}
- {{this}}
{{/each}}

Duration: {{duration}}
Start: {{start_window}}
Investment: ${{investment_usd}}
{{/each}}
```

Inside an `{{#each}}` block, the current item's fields are accessible without prefix. `{{this}}` references the current scalar (for arrays of strings). Outer scope still accessible via `{{../field}}` if needed.

### Conditional
```
{{#if scope.exclusions}}
**Exclusions**

The following are explicitly outside the scope of this Agreement:

{{#each scope.exclusions}}
- {{this}}
{{/each}}
{{/if}}
```

Renders only if the value is truthy / non-empty. Use for sections that may or may not apply (exclusions, optional addons, custom terms).

### Formatting helpers

Two helpers, both for cases where the raw value isn't presentable as-is:

- `{{currency scope.total_investment_usd}}` → renders `$13,000` (USD with thousands separators)
- `{{date discovery_date}}` → renders the ISO date in the consultant's preferred format (default: "May 12, 2026"; honor `BRAND.md.date_format` if set)

That's the full helper set. Anything else a consultant might reach for (uppercase a label, truncate a string) should just be written directly in the template — typing `SCOPE OF SERVICES` is shorter than `{{upper "Scope of Services"}}` and easier to read. Keeping the helper surface this small reduces parser bugs and consultant confusion.

If a helper isn't recognized, render as a no-op and warn (don't fail).

### Escaping substituted values

Every value substituted via `{{path.to.value}}` is rendered into a .docx, not into HTML or markdown. The skill should pass substituted values through unchanged at the .docx layer — no HTML-entity encoding, no markdown escaping.

But because templates are authored in markdown and the skill walks them, characters in substituted values that look like markdown control characters (asterisks, brackets, backticks, leading hyphens that read as bullets) can subtly distort the output. The rule:

1. The skill MUST NOT interpret substituted values as markdown. A `selected_offers[].deliverables[]` line like `"Roadmap *with* milestones"` should appear in the .docx with literal asterisks, not as bold text.
2. The skill MAY warn (not fail) when a substituted value contains a backtick, an unescaped underscore-pair, or a leading `-` or `*` that could be mistaken for a list marker. Surface the value and the section it landed in so the consultant can decide whether to clean the upstream scope.
3. For the unusual case where the consultant DOES want markdown rendering in a substituted value (e.g., a deliverable line that should bold a word), the consultant should write the bolding into the template, not into the proposal scope. Scope values are treated as plain prose.

## Section conventions

The skill renders `sections` top-to-bottom in the order defined. Common ordering — adjust to taste:

1. `cover` (the warm cover paragraph — `required: false`, on by default, suppressed with `--no-cover`)
2. `parties` (who's contracting with whom)
3. `effective_date_and_term`
4. `scope_of_services` (iterates `selected_offers`)
5. `investment_and_payment_terms`
6. `timeline`
7. `exclusions` (`{{#if scope.exclusions}}`)
8. `custom_terms` (`{{#if scope.custom_terms}}`)
9. `confidentiality`
10. `ip_and_work_product`
11. `limitation_of_liability`
12. `indemnification`
13. `termination`
14. `governing_law`
15. `dispute_resolution`
16. `signatures`

Optional appendices (only if the relevant `optional_clauses` flag is on AND the scope's `custom_terms` references the topic):
- `revenue_share_addendum`
- `data_partnership_addendum`
- `non_solicitation`
- `travel_expenses_addendum`

## Example fragment

```yaml
sections:
  - id: scope_of_services
    title: Scope of Services
    required: true
    template: |
      The Consultant shall provide the following services to the Client:

      {{#each scope.selected_offers}}
      **{{offer_name}}** — {{one_liner}}

      Deliverables under this engagement:
      {{#each deliverables}}
      - {{this}}
      {{/each}}

      Duration: {{duration}}.
      Engagement start: {{start_window}}.
      Investment for this component: ${{investment_usd}}.

      {{/each}}
      {{#if scope.custom_terms}}
      The following deal-specific terms also apply to the engagement:

      {{#each scope.custom_terms}}
      - {{this}}
      {{/each}}
      {{/if}}

  - id: investment_and_payment_terms
    title: Investment and Payment Terms
    required: true
    template: |
      The total investment for the services described in Schedule of Services is **{{currency total_investment_usd}}**.

      Payment shall be made on the following schedule:

      {{#each payment_schedule}}
      - **{{milestone}}** — {{currency amount_usd}} — {{trigger}}
      {{/each}}

      Standard payment terms are {{template.default_payment_net}}. Invoices issued at each milestone trigger.
      {{#if template.late_fee_pct_per_month}}
      A late fee of {{template.late_fee_pct_per_month}}% per month shall accrue on any amount unpaid past the invoice date.
      {{/if}}

  - id: confidentiality
    title: Confidentiality
    required: true
    template: |
      Both parties agree to hold in confidence all non-public information disclosed during the course of this Agreement.
      Confidentiality obligations under this Agreement survive termination for a period of {{template.confidentiality_term_years}} years.

  - id: governing_law
    title: Governing Law
    required: true
    template: |
      This Agreement shall be governed by and construed in accordance with the laws of the {{template.governing_law}},
      without regard to its conflict-of-laws provisions. {{template.dispute_resolution}}.
```

## Validation rules

Before rendering, the skill validates the template:

1. All REQUIRED top-level fields present and non-empty.
2. `sections` is an array with ≥1 entry.
3. Every section has `id`, `title`, `template`.
4. Every `{{#each}}` has a matching `{{/each}}`. Every `{{#if}}` has a matching `{{/if}}`.
5. Every required-by-the-skill section ID (see SKILL.md Required Sections table) is either present here, or a warning is surfaced with an offer to insert a default boilerplate clause.

## What this schema is NOT

- Not a substitute for legal review. The schema captures structure; the legal language inside `template` is the consultant's own.
- Not a clause library. Consultants supply their own clauses; the skill never fabricates legal language.
- Not multi-language. v1 is single-language (the consultant's). Multi-language localization is future work.
