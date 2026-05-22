# SERVICES.md Schema

`SERVICES.md` is the consultant's **offer catalog**. It lives in their Claude Project Knowledge alongside `BRAND.md`. The `build-proposal` skill reads it on every run; the `build-agreement` skill reads it indirectly via the scope YAML produced by `build-proposal`.

The file is YAML — the whole file can be a single YAML document, or YAML fenced inside markdown (same pattern as `BRAND.md`). The skill accepts either.

---

## Full schema

```yaml
# Top-level fields
revenue_share_enabled: false        # bool, default false. If true, build-proposal asks
                                    # partnership questions when an offer is sold as
                                    # rev-share rather than flat-fee.
default_currency: USD               # ISO currency code. v1 is USD-only; multi-currency
                                    # is future work — flag if a different code appears.
default_payment_terms: "50/50"      # string, fallback if an individual offer doesn't
                                    # specify payment_terms_default. Common values:
                                    # "50/50" (50% signature, 50% midpoint),
                                    # "PIF" (paid in full),
                                    # "thirds" (33/33/33 across the engagement).

# The offer catalog — required, must have at least one entry
offers:
  - name: <string>                  # verbatim name as it appears in the proposal
                                    # (e.g., "Flagship Program", "Strategy Sprint")
    one_liner: <string>             # one-line description; appears verbatim in artifact
    audience: <string>              # who this is for, in one line
                                    # (e.g., "<role> at <company stage>" — be specific)
    fit_signals:                    # 3-5 things heard on a discovery call that say
                                    # this is the right offer. Used by Phase 3 scoring.
      - <string>
      - <string>
    NOT_for:                        # 2-3 disqualifiers — language or signals that
                                    # mean this offer does NOT fit. Used as a hard
                                    # filter in Phase 3 scoring.
      - <string>
      - <string>
    deliverables_template:          # typical deliverables for this offer; the artifact
                                    # adds transcript-specific deliverables on top.
      - <string>
      - <string>
    duration: <string>              # e.g., "4 sessions over 8 weeks" or "6 months"
    investment_usd: <int | string>  # 10000  OR  "10000-15000"  for a range
    payment_terms_default: <string> # overrides default_payment_terms for this offer
    lane: <string | null>           # optional, for consultants with multiple positioning
                                    # lanes (e.g., "A", "B", "A_or_B"). Matches the
                                    # current_lane field in BRAND.md.
    url: <string | null>            # optional, public URL for the offer
    revenue_share_terms: <object | null>
                                    # optional, if revenue_share_enabled is true AND
                                    # this offer can be sold as rev-share. Structure:
                                    #   rate_recurring_pct: <int>
                                    #   rate_onetime_pct: <int>
                                    #   basis: "gross" | "net"
                                    #   attribution: "direct" | "multi-touch" | <string>
                                    #   duration_months: <int>
                                    #   buyout: <object | null>
                                    #   exclusions: [<string>, ...]
                                    #   key_person_clause: <bool>
```

## Required vs optional fields per offer

**Required** (build-proposal will refuse to recommend an offer without these):
- `name`
- `one_liner`
- `audience`
- `fit_signals` (at least 1; 3–5 strongly recommended)
- `investment_usd`

**Strongly recommended** (skill works without but surfaces an elaboration prompt):
- `NOT_for` — without this, Phase 3 can't filter out wrong-fit prospects, only rank by positive signals
- `deliverables_template` — without this, the artifact's "What it delivers" section is fully transcript-derived (less stable across deals)
- `payment_terms_default` — falls back to top-level `default_payment_terms`
- `duration` — falls back to "to be confirmed"

**Optional**:
- `lane` — only meaningful if `BRAND.md` declares positioning lanes
- `url` — for hyperlinks in the artifact and email
- `revenue_share_terms` — only if `revenue_share_enabled: true`

## Example — three-offer catalog (generic illustration)

The example below is illustrative only — the real `SERVICES.md` lives in the consultant's Project Knowledge and carries the consultant's actual offers. Use this as a structural template, not as defaults.

```yaml
revenue_share_enabled: false
default_currency: USD
default_payment_terms: "50/50"

offers:
  # Example A — a multi-session signature program
  - name: "Flagship Program"
    one_liner: "<one-line description of the program in the consultant's voice>"
    audience: "<who this is for, in one line>"
    fit_signals:
      - "<3-5 things heard on a discovery call that say this offer fits>"
      - "<each phrased the way prospects actually talk, not how consultants describe it>"
    NOT_for:
      - "<2-3 disqualifiers — language or signals that mean this offer is wrong>"
      - "<e.g., 'they want a one-off, not a program'>"
    deliverables_template:
      - "<typical deliverable 1>"
      - "<typical deliverable 2>"
    duration: "<e.g., '4 sessions over 8 weeks' or '12 weeks'>"
    investment_usd: <int>
    payment_terms_default: "<e.g., '50% on signature, 50% at midpoint'>"
    lane: <optional, e.g., A | B>
    url: null

  # Example B — a longer, larger intensive
  - name: "Strategic Intensive"
    one_liner: "<one-line description>"
    audience: "<who this is for>"
    fit_signals:
      - "<signal phrased in prospect language>"
      - "<signal phrased in prospect language>"
    NOT_for:
      - "<disqualifier>"
    deliverables_template:
      - "<diagnostic phase output>"
      - "<facilitation phase output>"
      - "<final document or deliverable>"
    duration: "<e.g., '3-4 months'>"
    investment_usd: "<int or range, e.g., '20000-35000'>"
    payment_terms_default: "thirds"
    lane: <optional>

  # Example C — a single-event keynote / speaking offer
  - name: "Signature Keynote"
    one_liner: "<one-line description of the talk>"
    audience: "<conference / association / event audience>"
    fit_signals:
      - "<event-type signal>"
    NOT_for:
      - "<wrong-fit signal>"
    deliverables_template:
      - "60-90 minute keynote, customized to host"
      - "Slide deck branded to host"
      - "Optional follow-up Q&A breakout"
    duration: "Single event"
    investment_usd: "<int or range, e.g., '1500-15000' for virtual-floor to in-person ceiling>"
    payment_terms_default: "PIF on contract"
    lane: <optional>
```

## Migration from `BRAND.md > Offer Bank`

If `BRAND.md` has an `Offer Bank` section (a common pattern in `BRAND.md` docs produced by `define-brand-voice`), `build-proposal` will bootstrap `SERVICES.md` from it on first run. The bootstrap maps:

| BRAND.md Offer Bank field | SERVICES.md field |
|---|---|
| `name` | `name` |
| `one_liner` | `one_liner` |
| `price` or `fee_floor` | `investment_usd` (parse to int or range string) |
| `lane` | `lane` |
| `url` | `url` |

The bootstrap **adds** `audience`, `fit_signals`, `NOT_for`, `deliverables_template`, `duration`, and `payment_terms_default` via a quick 3-question interview per offer. These fields don't typically exist in Offer Bank format.

After the bootstrap, the consultant uploads the new `SERVICES.md` to Project Knowledge alongside `BRAND.md`. The Offer Bank in `BRAND.md` can stay as-is for the carousel/story skills that read it; `SERVICES.md` is the canonical source for proposal-building.
