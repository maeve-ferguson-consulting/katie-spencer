# Proposal Scope YAML Schema

This is the **API contract** between `build-proposal` (this skill) and `build-agreement` (the contract-generation skill). `build-proposal` produces this YAML; `build-agreement` consumes it verbatim to fill the consultant's contract template — no re-keying of scope, no human translation of "what the proposal said" into "what the contract says."

If a field is unknown when the proposal is built, populate it with the literal string `[TO_BE_CONFIRMED]` rather than guessing or omitting. `build-agreement` will surface unconfirmed fields when it runs so the consultant can fill them in before signing.

## Where this YAML lives

`build-proposal` emits it two ways on every run:

1. **Embedded** at the bottom of the proposal HTML artifact, inside `<!-- proposal-scope ... -->` HTML comment delimiters so it travels with the artifact but doesn't render visually. Format:

   ```html
   <!-- proposal-scope
   proposal:
     id: ...
     prospect:
       org_name: ...
   ...
   -->
   ```

2. **Sidecar file** at `/mnt/user-data/outputs/<prospect-slug>-proposal-scope.yml`. This is the file `build-agreement` reads when it runs.

Both copies must be byte-identical. If the consultant edits one, they need to edit the other (or re-run `/proposal` to regenerate both from the same source of truth).

## Full schema

```yaml
proposal:
  id: <string>                       # required. kebab-case slug.
                                     # Format: <consultant-shortname>-<YYYY>-<MM>-<prospect-org-slug>
                                     # e.g., "ackerman-2026-05-acme-foundation"

  prospect:
    org_name: <string>               # required. As it appears in the proposal artifact.
    contact_name: <string>           # required. Full name of the primary prospect contact.
    contact_title: <string>          # required. Their role at the prospect org.
    contact_email: <string | null>   # optional. If known, lands in the agreement.
    url: <string>                    # required. The prospect org URL.
    brand_colors_hex:                # optional. Top 3 hex codes pulled from prospect site.
      - "#RRGGBB"                    # Used by build-agreement only if it generates a
      - "#RRGGBB"                    # branded contract artifact (most don't).
      - "#RRGGBB"

  consultant:
    name: <string>                   # required. From BRAND.md > brand_identity_primary
                                     # or BRAND.md > name. Verbatim.
    brand_name: <string>             # required. Consultant's business/firm name.
    legal_entity: <string>           # required. LLC name or registered entity name.
                                     # If not in BRAND.md, set to "[TO_BE_CONFIRMED]".
    signature_framework: <string>    # optional. From BRAND.md > signature_framework > name.
    contact_email: <string>          # required. Where the prospect should reply.
                                     # Set to "[TO_BE_CONFIRMED]" if not in BRAND.md.

  discovery_date: <ISO date>         # required. YYYY-MM-DD format. The date of the
                                     # discovery call the proposal is built from.

  scope:
    selected_offers:                 # required. At least one entry. Each entry
                                     # is one offer the consultant is proposing.
      - offer_name: <string>         # required. Verbatim from SERVICES.md > offers > name.
        one_liner: <string>          # required. Verbatim from SERVICES.md > offers > one_liner.
        audience: <string>           # optional. From SERVICES.md, build-proposal
                                     # extension — currently NOT consumed by
                                     # build-agreement. Safe to omit.

        deliverables:                # required. The actual deliverables for this deal.
          - <string>                 # Derived from SERVICES.md > offers > deliverables_template
          - <string>                 # PLUS transcript-specific additions.
                                     # Each item should be a complete sentence/phrase
                                     # describing what the prospect receives.

        duration: <string>           # required. E.g., "4 sessions over 8 weeks".
        start_window: <string>       # required. E.g., "Week of 2026-06-09" or
                                     # "Within 30 days of signature".
        investment_usd: <int>        # required. Single int, no formatting.
                                     # If the proposal showed a range, pick the
                                     # specific number agreed to in the discovery.
        payment_terms: <string>      # required. E.g., "50% on signature, 50% at
                                     # midpoint" or "PIF on signature".

    exclusions:                      # required. Explicit out-of-scope items.
      - <string>                     # The boundary that makes the in-scope
                                     # unambiguous. E.g., "Implementation support
                                     # post-engagement is not included."
                                     # NOTE: lives INSIDE scope (synced with build-agreement).

    custom_terms:                    # optional. Deal-specific terms surfaced in
                                     # discovery that need to land in the contract.
      - <string>                     # E.g., "Travel costs reimbursed at cost up to
                                     # $5,000 for in-person sessions."
                                     # NOTE: lives INSIDE scope (synced with build-agreement).

    optional_addons:                 # optional. Add-on offers presented in the
                                     # proposal but NOT in the base scope.
                                     # build-agreement does not include these by
                                     # default — they require a separate amendment.
                                     # NOTE: lives INSIDE scope (synced with build-agreement).
      - offer_name: <string>
        one_liner: <string>
        investment_usd: <int>

  total_investment_usd: <int>        # required. Sum of selected_offers > investment_usd.
                                     # Validated by eval — must equal the sum.

  payment_schedule:                  # required. Concrete milestones — what
                                     # triggers each payment and how much.
    - milestone: <string>            # E.g., "On signature", "Session 2 completion",
                                     # "On delivery of board roadmap"
      amount_usd: <int>              # The payment amount.
      trigger: <string>              # The specific event or date that triggers it.
                                     # E.g., "On signature" | "2026-07-15" |
                                     # "On delivery of board roadmap"

  next_step:                         # optional, build-proposal extension.
                                     # NOT consumed by build-agreement v1 — used
                                     # internally by build-proposal to phrase the
                                     # artifact's closing CTA. Safe to omit.
    action: <string>                 # E.g., "book the agreement call",
                                     # "e-sign and start", "paid discovery first"
    deadline: <ISO date | null>      # optional. If the offer has an expiry, set
                                     # this; otherwise null.
```

## build-proposal extensions (not consumed by build-agreement v1)

Several fields above are emitted by `build-proposal` for its own internal use or future-proofing. `build-agreement` v1 ignores them; they are safe to include (and harmless to omit). They are documented here so future skills can opt in:

- `consultant.signature_framework` — the consultant's signature methodology name (whatever they call their process — pulled verbatim from `BRAND.md > signature_framework > name`). Used by `build-proposal` for the "Path" section; future cross-sells (a build-onboarding skill, a build-recap skill) can read it.
- `consultant.contact_email` — where prospect should reply. Future skills (build-onboarding, follow-up-sequences) can use this.
- `scope.selected_offers[].audience` — used by `build-proposal` for fit-scoring, kept in the YAML for future agreement-personalization features.
- `next_step` — build-proposal's CTA phrasing, used internally; future skills may consume it.

When `build-agreement` v2 ships, this section becomes the changelog of what it added support for.

## Validation rules

The paired `eval-build-proposal` skill checks these rules. If `build-proposal` emits a YAML that fails any of them, the eval fails and the proposal is not delivered.

1. **All required fields present.** Fields marked "required" above must exist and be non-empty (empty string, empty list, and `null` all fail unless explicitly noted as nullable).
2. **`total_investment_usd` matches the sum of selected offers.** No off-by-rounding errors.
3. **`payment_schedule` amounts sum to `total_investment_usd`.** Within ±$1 for rounding tolerance.
4. **`proposal.id` is kebab-case** and matches the regex `^[a-z0-9]+(-[a-z0-9]+)+$`.
5. **`discovery_date` is a valid ISO date** (YYYY-MM-DD) and is not in the future.
6. **`selected_offers[].offer_name` exists in the consultant's `SERVICES.md`.** If `build-proposal` invents an offer that isn't in the catalog, the eval flags it as a hallucination.
7. **`scope.exclusions`, `scope.custom_terms`, `scope.optional_addons` placement.** These three live INSIDE the `scope` block, not at the `proposal` top level. (Synchronized with `build-agreement/references/proposal-scope-schema.md`.) Note that `00-shared-context.md` from the original skill-plans batch placed them at the top level — this schema and `build-agreement` both moved them inside `scope`. If `00-shared-context.md` needs to be updated to match, do it separately.
8. **No `[TO_BE_CONFIRMED]` in any field whose value should be derivable** from the discovery transcript or `BRAND.md`. Acceptable `[TO_BE_CONFIRMED]` values: `consultant.legal_entity` (only if missing from BRAND.md), `consultant.contact_email` (same), `scope.optional_addons[].*` (if the consultant declined to specify add-on details). Anything else with `[TO_BE_CONFIRMED]` is a soft warning.

## Versioning

This schema is **v1**. If a future revision needs to add a field, prefer adding it as an optional field. If a breaking change is needed, version the entire schema (`proposal.schema_version: 2`) and update both `build-proposal` and `build-agreement` in lockstep. `build-agreement` will refuse to process a YAML with an unknown `schema_version`.
