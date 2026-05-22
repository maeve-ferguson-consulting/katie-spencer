---
name: build-proposal
description: "Build a brand-matched proposal for a qualified consulting prospect after a discovery call. Reads BRAND.md (voice, framework) and SERVICES.md (offer catalog) from Project Knowledge, ingests the discovery transcript, and produces three deliverables: a prospect-branded HTML artifact (rendered in the prospect's brand, not the consultant's), a structured scope YAML that build-agreement consumes verbatim so contracts never re-key the scope, and an internal positioning summary for the next sales call. Bundles first-run offer-catalog setup inline if SERVICES.md is missing - bootstraps from BRAND.md Offer Bank if present, otherwise runs a 5-10 min interview. Triggers on /proposal, /offer, /buildproposal, 'build the proposal', 'put together pricing', 'they're a good fit', 'make the offer', 'create the proposal', or any proposal/offer/pricing request for a specific prospect after discovery. NOT for cold pitches, generic pricing pages, or proposals before discovery."
---

# BUILD PROPOSAL

Universal proposal builder for consulting practices. Takes a discovery-call transcript plus the consultant's BRAND.md and SERVICES.md, and produces a complete, prospect-branded proposal package — every deal, every time.

The artifact is **prospect-branded**: rendered in the prospect's brand colors and typography so it reads as a gift to them, not as marketing collateral from the consultant. The consultant's brand appears as a small footer attribution. The voice inside, however, is the consultant's — specific, invitational, and shaped by their BRAND.md.

## How this skill reads consultant context

This skill is consultant-agnostic. Every consultant-specific decision (voice, framework, offers, pricing, roster, payment terms) is read at runtime from two documents in the consultant's Claude Project Knowledge:

- **`BRAND.md`** — voice rules, signature framework, signature phrases, testimonial bank, vision tethers. Required. Same schema as `build-carousel` / `build-story` consume.
- **`SERVICES.md`** — offer catalog: per-offer name, one-liner, audience, fit signals, deliverables template, duration, investment, payment terms, what it's NOT for. Required. Schema documented in `references/services-schema.md`.

If either doc is missing, the skill follows the **inline first-run** pattern below — it does not silently substitute defaults. Shipping a proposal in a different voice or with the wrong offers is worse than shipping nothing.

## SERVICES.md is a living document — help the consultant elaborate it

After every proposal, surface ONE concrete elaboration prompt the consultant could act on in 30 seconds — something specific they just saw in the output. Examples:

- "Your Board Ready offer has no `fit_signals` listed yet — I had to infer them from the discovery transcript. Want to add 3–5 signals so the next proposal recommendation is sharper?"
- "The prospect's budget came in below your Board Ready investment band. Want to add a lighter-touch offer to SERVICES.md, or are you holding the floor?"
- "I didn't find a 'NOT_for' note on the Strategic Planning offer. Want to add what disqualifies a prospect from it, so I don't recommend it for wrong-fit deals?"

This is not the same as the eval step. It's a single concrete editing prompt the consultant can act on. The skill should NEVER edit BRAND.md or SERVICES.md itself — it surfaces the suggestion and the consultant decides.

---

## PRECHECK (run before anything else)

1. **Look for `BRAND.md`** in the conversation context (injected from Project Knowledge).
   - If missing or marked `[PROVISIONAL]`: stop and tell the consultant, in your own words, that the build can't proceed without their brand context. The fix is to run `define-brand-voice` (a ~15-minute brand-capture interview) and save the result to Project Knowledge. Do NOT chain-invoke `define-brand-voice` automatically — tell the consultant it's their next step. Their discovery transcript will be preserved when they come back.

2. **Look for `SERVICES.md`** in the conversation context (injected from Project Knowledge).
   - If missing AND `BRAND.md > Offer Bank` exists: tell the consultant, in your own words, that you'll bootstrap a `SERVICES.md` from their Offer Bank as a one-time setup (~5 minutes), then continue into the proposal. Run the **First-Run Bootstrap** flow below.
   - If missing AND no Offer Bank in `BRAND.md`: tell the consultant you need ~10 minutes to capture their offer catalog before building any proposal — this only happens once. Run the **First-Run Interview** flow below.
   - If present and valid (passes the schema in `references/services-schema.md`): proceed.

3. **Confirm the discovery transcript** is provided (paste, file path, or upload). If not, ask: "Paste the discovery-call transcript (or upload it as a file). If you don't have one, I can work from your notes — but the more specific the source material, the more the proposal will land as an invitation rather than a quote."

4. **Confirm the prospect URL** is provided. If not, ask: "What's the prospect organization's URL? I'll match the artifact to their brand."

If all four pass, proceed to Phase 0.

---

## Voice & Posture — read this first

This skill writes **invitations, not quotes**. A proposal lists scope and price. An invitation paints a vision of what becomes possible — and presents the engagement as the natural next step toward it. The prospect should finish the artifact thinking *"I want to be doing this work with these people"* before they look at the investment.

Three voice principles govern every line. If a line fails any one, rewrite.

**1. Vision before mechanics.** Open with what becomes possible — the future state, the inflection point, the moment this engagement creates. Mechanics (scope, deliverables, payment) come later. Never lead with "we propose" or "this engagement includes." Lead with what the prospect's organization looks like on the other side of saying yes.

**2. Specificity over generality.** Lines must be unable to apply to any other consultancy with any other prospect. Reference the prospect's name, their organization, what they said on the call, what they're trying to do this year. "The first board retreat lands on your desk in week 6" beats "regular touchpoints." If a line could describe any consultancy, rewrite it.

**3. Invitation, not quote.** The closer reads as a continuation of the conversation, not a follow-up. Never "looking forward to hearing from you." Closer to: *"The work is here when you're ready; the next conversation is a continuation, not a follow-up."*

**Voice vs. posture.** Voice (warm, direct, intense, witty, formal) comes from the consultant's `BRAND.md` and is personal. The three principles above are posture — universal across every output. A warm voice and an authoritative voice both produce invitations under these principles; they just sound different.

---

## TRIGGER

Activates on: `/proposal`, `/offer`, `/buildproposal`, "build the proposal for [prospect]", "put together pricing for [company]", "create the proposal", "they're a good fit", "make the offer", or any request to build pricing, a proposal, or an offer for a specific qualified prospect after a discovery call.

---

## First-Run Bootstrap (BRAND.md has Offer Bank, SERVICES.md missing)

Tell the consultant, in your own words, that you'll lift the offers from their `BRAND.md > Offer Bank` into a proper `SERVICES.md`. This is the one-time setup; future proposals skip it. The bootstrap adds the structured fields the proposal engine needs (fit signals, NOT_for, payment terms default, lane assignment) that the Offer Bank doesn't usually carry.

For each offer in the Offer Bank, ask three quick questions in a single prompt (operator pace, acknowledge tersely, move on):

> "For **[Offer Name]** — three quick fields, then I'll move to the next offer:
> 1. **Audience** — who is this for, in one line? (e.g., 'ED + board chair of mid-size nonprofit')
> 2. **Fit signals** — list 3–5 things you hear on a discovery call that say this is the right offer (e.g., 'post-strategic-plan drift', 'capital campaign approaching', 'ED-board tension')
> 3. **NOT for** — list 2–3 things that disqualify a prospect from this offer (e.g., 'they say fundraising is the real problem', 'they want a one-off keynote, not a program')"

Also confirm: investment, payment terms default, duration, deliverables template. If any of these are already in the Offer Bank entry, present them and ask "confirm or adjust?" rather than re-asking.

After the bootstrap, save `SERVICES.md` to `/mnt/user-data/outputs/SERVICES.md` using the schema in `references/services-schema.md`, present it to the consultant, and tell them to upload it to Project Knowledge so future proposals skip this step. Then continue into Phase 0 with the freshly-built catalog held in context.

## First-Run Interview (no Offer Bank either)

Tell the consultant this is a ~10-minute one-time setup. One question at a time, operator pace. Cover only the minimum the proposal engine needs:

1. How many distinct offers do you sell? (1 to 5)
2. For each offer, ask in one compact prompt:
   - Name?
   - One-line description of what's included (rough is fine)?
   - Audience (who this is for, one line)?
   - Typical duration?
   - Investment (in USD — multi-currency is future work; flag if needed)?
   - Payment terms default (e.g., "50% on signature, 50% at midpoint")?
   - 3–5 fit signals you hear on a discovery call that say this is the right offer?
   - 2–3 disqualifiers (NOT_for)?

After the interview, save `SERVICES.md` and continue into Phase 0. Tell the consultant the file is ready to upload to Project Knowledge so the next proposal skips this step.

The first-run flows above are deliberately tighter than a full setup interview. The consultant can refine `SERVICES.md` between proposals (rev share, multiple lanes, deliverables templates, etc.) — the schema documented in `references/services-schema.md` shows the full surface area.

---

## Phase 0 — Read the consultant's context

Hold in context throughout the run:
- `BRAND.md`: voice rules, signature framework (the named process), signature phrases, testimonial bank, vision tethers, positioning lanes (if multi-lane), banned words, em-dash policy, person/pronoun, sign-off
- `SERVICES.md`: every offer with all fields (name, one-liner, audience, fit signals, deliverables template, duration, investment, payment terms, NOT_for, optional lane, revenue_share_enabled flag)

Do not re-ask anything that's in either document.

## Phase 1 — Deal intake interview

One question at a time, operator pace. Acknowledge tersely between answers ("Got it.") and move on. Bundle related questions into a single prompt where natural.

1. **Prospect name + role:** First name, last name, role at their org.
2. **Prospect organization:** Name.
3. **Prospect URL** (if not already provided): For brand matching.
4. **Discovery transcript** (if not already provided): Paste, file path, or upload.
5. **Discovery date:** ISO date if known, otherwise "this week" / "two weeks ago".
6. **Offer selection** — single prompt:

   > "From your SERVICES.md, here are the offers that fit what surfaced on the call: [list 1–3 ranked recommendations, with the signal that fired for each — e.g., '<Offer Name> — fit signal that fired: <signal text from SERVICES.md>']. Confirm, swap, or add an offer? You can also let me pick — I've already scored each offer against the transcript."

   If the consultant pre-selected offers via the trigger phrase, confirm rather than re-ask.

7. **Custom terms:** "Anything surfaced on the call that needs to land in the proposal? Discount, custom scope, timeline constraint, a specific deliverable they asked for?"

8. **Prior material:** "Have they seen anything from you already — a one-pager, a previous proposal, a follow-up email? The proposal should read as continuous with it."

9. **Next-step preference:** "What's the next step you want the proposal to invite? Book the agreement call, e-sign and start, paid discovery first? Be specific — the artifact closes on this single action."

If `SERVICES.md > revenue_share_enabled: true` AND the consultant indicates this is a partnership-style deal, ask the partnership questions (rate structure, projections) following the source skill's pattern. For most consultants this is skipped — flat-fee is the default.

## Phase 2 — Brand-match the prospect site

The artifact appears in the prospect's brand. Steps:

1. **WebFetch the prospect URL.** Look at the site — describe what you see (palette, type treatment, tone) so the consultant can confirm or correct.
2. **Extract palette.** Pull the dominant 3 hex codes. If the site is on a closed platform (Squarespace, Wix) where exact hex isn't in the page source, present a best-guess palette and flag it in an HTML comment at the top of the artifact: `<!-- Brand palette inferred from [URL]. Confirm or paste exact hex codes. -->`
3. **Extract typography.** Pull heading font family and body font family if visible in CSS. Fall back to web-safe pairings (serif heading + sans body, or vice versa, matched to the site's register).
4. **Confirm with the consultant.** Single prompt: "Brand pulled from [prospect URL]: primary `#XXX`, accent `#XXX`, background `#XXX`; heading `[Font]`, body `[Font]`. Confirm, adjust, or paste exact hex codes from their brand guide if you have one."
5. **If brand extraction fails entirely** (404, JS-only site, blocked): fall back to a neutral editorial palette (deep navy / warm cream / muted accent) and note the fallback in the internal positioning summary AND in an HTML comment at the top of the artifact.

**NEVER use the prospect's logo as if it's their own asset.** The artifact features the prospect; it isn't authored by them.

## Phase 3 — Score and select offers (if not already selected)

For each offer in `SERVICES.md`, score against the discovery transcript:

- **Fit signal match** — count how many `fit_signals` from the offer appear in the transcript (in the prospect's own language or as paraphrases).
- **NOT_for match** — count how many `NOT_for` disqualifiers appear. Any match here drops the offer.
- **Lane match** (if multi-lane) — if `BRAND.md > current_lane` is set or the transcript clearly belongs to one lane, deprioritize offers from the other lane.
- **Budget/timeline signals** — if the transcript surfaces an explicit budget or timeline, exclude offers that don't fit.

Present the top 1–3 ranked offers to the consultant in Phase 1 step 6 with the firing signal called out. If the top offer scores below 2 signals, surface it as low-confidence and ask: "The transcript didn't fire strongly against any offer. Want to talk through the call, or pick an offer manually?"

## Phase 4 — Build the proposal artifact (HTML)

Render the artifact as a **Claude artifact** in the right-hand panel (HTML artifact type, `text/html` MIME) AND save the same HTML to `/mnt/user-data/outputs/[prospect-slug]-proposal.html`. The artifact enables one-click publishing; the file enables external hosting.

### Sections, in order

1. **Cover** — Prospect's organization name prominent. Title is not "Proposal"; reach for something that names the work or the moment, e.g., "[Prospect Org] × [Consultant Brand] — A Partnership for [Specific Outcome]" or "The [Year] [Engagement Theme]". One-line subtitle referencing the specific outcome the prospect lit up about on the call. Date. Small footer: "Prepared by [Consultant Brand], [Consultant URL]".

2. **The Vision** — First content section. 2–3 paragraphs, present-tense or near-future. Opens with the specific moment from the discovery transcript as the pivot. Names the inflection point. Closes with a line that frames the rest: *"The pages that follow are how we get there."* Avoid generic future-state language ("you'll have clarity"). Be specific to the prospect's actual organization and what they actually want.

3. **What We Heard** — 3–5 specific things from the transcript, in the prospect's own words where possible. Written as a confirmation of understanding: *"Here is what we heard you say. If this isn't right, tell us before we go further."*

4. **The Path** — The consultant's signature framework (from `BRAND.md > signature_framework`) applied to this prospect's situation. Each step named, each tied to a specific thing that happens for this prospect.

5. **The Offer(s)** — For each selected offer (verbatim from `SERVICES.md`):
   - Offer name + one-liner
   - What it delivers (deliverables template + transcript-specific additions)
   - Cadence + duration
   - Who's involved (consultant team if applicable; for solo consultants, just the consultant)
   - Investment + payment terms

6. **Optional Add-Ons** — only if surfaced in discovery. Brief.

7. **Timeline** — start window, key milestones. Phrased per the consultant's `BRAND.md > Voice Rules` (hard dates / indicative rhythm / flexible framing).

8. **What's Not in Scope** — explicit exclusions. Brief, factual. This is the boundary that lets the in-scope work be unambiguous.

9. **Who We've Built This With** — 2–4 testimonial entries pulled from `BRAND.md > Testimonial Bank`, prioritized by: same problem in transcript > same audience > most recognizable name. Visually styled so the eye scans names and outcomes first, quotes second. If the bank has fewer than 2 entries, surface as a soft elaboration prompt at the end of the run — don't fabricate.

10. **The Next Conversation** — Closing. Addressed to the prospect by name. Not "we look forward to your decision." Closer to: *"We're not in a hurry, and you shouldn't be either. When you're ready, the next conversation is [the named next step from Phase 1, step 9]."* Contact info. Small consultant-brand footer attribution.

### HTML technical requirements

- Inline styles only. Self-contained single file.
- Google Fonts `@import` for non-system typography.
- Prospect's brand palette throughout (background, accents, dividers). The consultant's brand appears only in the footer attribution.
- If colors or fonts were inferred (not extracted from the consultant or paste), include an HTML comment at the top: `<!-- Brand palette inferred from [URL]. Override if wrong. -->`
- Mobile-responsive.
- Print-friendly.
- Editorial register — closer to a hand-bound proposal book than a SaaS landing page.
- Render at the very bottom of the file: the **scope YAML block** (Phase 5 below) inside an HTML comment so it travels with the artifact but doesn't display.

## Phase 5 — Produce the scope YAML

This is the API contract with the `build-agreement` skill. Match the schema in `references/proposal-scope-schema.md` exactly. Output it two ways:

1. **Embedded** at the bottom of the proposal HTML, inside `<!-- proposal-scope ... -->` comment delimiters so it travels with the artifact.
2. **Sidecar file** at `/mnt/user-data/outputs/[prospect-slug]-proposal-scope.yml` so `build-agreement` can read it directly.

If a required field is unknown (e.g., the consultant didn't specify a `legal_entity` in `BRAND.md` and `AGREEMENT_TEMPLATE.md` is missing), populate the field with `[TO_BE_CONFIRMED]` rather than guessing or omitting. The `build-agreement` skill will surface unconfirmed fields when it runs.

## Phase 6 — Build the internal positioning summary

Brief markdown, consultant-only. Save to `/mnt/user-data/outputs/[prospect-slug]-internal-summary.md`.

```markdown
# Internal Positioning — [Prospect Org]

**Prospect contact:** [Name, role]
**Discovery date:** [Date]
**Selected offer(s):** [Names + total investment]
**Brand pulled from:** [Prospect URL — extracted | inferred | fallback]

## Why These Offers
[Signal-by-signal mapping: which fit_signals fired in the transcript, which offers ranked, why this combination]

## Tier Choice Rationale
[If multiple offers were possible, why this combination at this price. Note any low-confidence inferences.]

## What to Expect on the Close Call
[Likely objections from transcript signals; language to use; fallback positioning if they push on price or timeline]

## Risk Flags
[Anything in the transcript that suggests this prospect won't sign, won't deliver well, or has unspoken blockers — note for the consultant, not for the prospect]

## Reminders
[Personal details, specific concerns, anything not to forget on the next call]
```

## Phase 7 — Optional: payment options email

Only if requested by the consultant in Phase 1 step 7, or if `SERVICES.md > email_template_enabled: true` (a future field — default off). When generated, follow the invitational voice posture: opens with the specific moment from the call, references the proposal URL placeholder `[PROPOSAL_URL]`, presents payment options as logistics not headline, and closes as the next conversation in a sequence — not a sales follow-up.

Save to `/mnt/user-data/outputs/[prospect-slug]-email.md`.

## Phase 8 — Deliver

Use `present_files` to surface the email (if generated), the internal summary, the sidecar scope YAML, and the proposal HTML file. The Claude artifact panel already shows the rendered proposal.

Walk the consultant through publishing if they ask, but don't presume a publishing path — they may already have one. If they do ask, the lightest paths are:

- **Claude Publish** — click Publish at the top of the artifact panel, copy the public URL. 60 seconds. May be restricted on Team/Enterprise accounts.
- **Netlify Drop** — go to `app.netlify.com/drop`, drag the HTML file, copy the URL. 30 seconds, no account needed.
- **Their own host** — give them the file and trust them.

Then surface ONE concrete elaboration prompt for `SERVICES.md` based on what just happened (see the top of this skill).

---

## Posture audit — run before delivery

Read the artifact top-to-bottom and audit against these five checks. Rewrite anything that fails.

1. **Vision before mechanics.** Does the artifact open with what becomes possible, or with "we propose" / "this engagement includes"? If mechanics-first, rewrite.
2. **Specificity over generality.** Could this artifact have been sent to any other prospect with just a name swap? Quote three sentences and test: are they unmistakably about this prospect, this organization, this moment? If a sentence could sit in any consultancy's deck, rewrite it.
3. **Invitation, not quote.** Does the price feel like an invitation or a quote? Does the close read as continuation or pursuit? If pursuit ("looking forward to hearing from you"), rewrite.
4. **Restraint over adjectives.** Cut "world-class," "cutting-edge," "bespoke," "transformative." Confident things don't need to be explained. Replace with the specific thing the adjective was pointing at.
5. **Proof by proximity, not pitching.** Are testimonials woven through (named clients, named outcomes), or rallied into a generic "social proof" silo? Surface the specific match — "the same approach we used with [client] to [outcome]."

If the artifact fails the audit twice and still reads generic, stop and tell the consultant: "The draft isn't clearing the posture audit. Either `BRAND.md` is too thin, the discovery transcript is too sparse, or the offers selected don't fire strongly against what surfaced. Which would you like to strengthen?"

---

## Edge cases

- **`SERVICES.md` present but no offer scores above 1 fit signal:** Surface as low-confidence in Phase 3. Don't auto-pick a weak fit — ask the consultant.
- **Multiple positioning lanes in `BRAND.md`, transcript spans both:** Surface the lane question to the consultant: "The transcript touches both Lane A (Org Health) and Lane B (Board Governance) signals. Which lane is this prospect for?" Default to whichever lane scored more fit signals; let the consultant override.
- **Prospect URL fetch fails:** Fall back to neutral editorial palette. Flag in HTML comment AND internal summary.
- **Testimonial bank empty in `BRAND.md`:** Render the section with a single line like *"Recent partnerships available on request"* OR skip the section entirely; surface as elaboration prompt at the end. Never fabricate.
- **Signature framework empty in `BRAND.md`:** Drop the "The Path" section. Surface as elaboration prompt.
- **Discovery transcript is two lines of notes, not a real transcript:** Tell the consultant the proposal will be less specific and ask if they want to expand the notes first or proceed as-is. If proceeding, flag in the internal summary which sections leaned on inference.
- **Prospect has no clear next-step preference:** Default to "book the agreement call" but call it out in the internal summary so the consultant can confirm before sending.
- **Revenue share enabled in `SERVICES.md`, this deal is flat-fee:** Build all sections normally; skip Partnership Economics. Note flat-fee status in the internal summary.
- **Anything in `BRAND.md` or `SERVICES.md` is marked `[TO_BE_CONFIRMED]` or `[NOT YET CONFIGURED]`:** Surface in the internal summary so the consultant knows which inferences were forced.

---

## Universality check (CRITICAL)

This skill ships in the mfc-skill-bank and is used by multiple consulting practices. The source MUST be free of consultant-specific identifiers. Before delivery, the skill itself should be greppable for none of:

- Specific consultant names (e.g., proprietary brand names, individual people's names tied to a single consultancy)
- Specific offer names baked into the source (offers come from `SERVICES.md` at runtime)
- Specific project-management tool integrations (Asana ticket pulls, etc.)
- Specific positioning hooks ("Category of One," named content-IP from one consultancy)

If any of these surface during a run, they came from `BRAND.md` or `SERVICES.md` — which is correct. If they appear in the skill source itself, that's a bug.

---

## Output file naming

- `[prospect-slug]-proposal.html` — the artifact (also rendered in the Claude artifact panel)
- `[prospect-slug]-proposal-scope.yml` — sidecar scope YAML (API contract for `build-agreement`)
- `[prospect-slug]-internal-summary.md` — consultant-only positioning summary
- `[prospect-slug]-email.md` — optional, only if requested in Phase 1

Where `prospect-slug` is `kebab-case(prospect-org-name)` — e.g., `acme-foundation`, `north-star-museum`.

---

**END OF SKILL**
