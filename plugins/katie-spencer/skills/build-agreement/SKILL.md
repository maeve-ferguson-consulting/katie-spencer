---
name: build-agreement
description: "Generate a client-ready service agreement or engagement letter from an accepted proposal. Triggers on /agreement, /contract, /engagement-letter, 'build the agreement', 'send the contract', 'draft the engagement letter', 'turn the proposal into a contract', or any request to convert a verbal yes into signed paperwork. Reads the proposal scope YAML produced by build-proposal, the consultant's BRAND.md, and AGREEMENT_TEMPLATE.md (legal entity, governing law, standard clauses, placeholder-driven sections). Outputs a branded .docx with scope pulled verbatim - selected offers, fees, payment schedule, timeline, exclusions, custom terms - plus the required sections every consulting agreement needs. Optional cover paragraph in the consultant's voice. Universal: works for any consulting practice with a discovery to proposal to agreement flow. NOT a legal drafter - fills the consultant's existing template. Elicits AGREEMENT_TEMPLATE.md inline on first run if missing."
---

# BUILD AGREEMENT

Universal agreement-builder. Takes an accepted proposal's scope YAML and a consultant's standard agreement template, and produces a branded .docx ready for e-sign or hand-off to the prospect.

The skill is a **template-filler, not a legal drafter.** Scope comes verbatim from the proposal. Legal clauses come verbatim from the consultant's `AGREEMENT_TEMPLATE.md`. The skill walks sections, substitutes `{{placeholders}}`, applies optional clauses based on signals in the scope, and renders to .docx in the consultant's brand.

## How this skill reads context

Two project-knowledge documents are read at runtime from the consultant's Claude Project:

- `BRAND.md` — consultant identity, voice, typography, accent color. Required. Same schema as `build-carousel` / `build-story` use (see `references/brand-schema.md` in those skills).
- `AGREEMENT_TEMPLATE.md` — consultant's standard agreement: legal entity, state, governing law, default clauses, sectioned template with handlebars-style placeholders. Required. Elicited inline on first run if missing.

One artifact is read per run:

- **Proposal scope YAML** — produced by `build-proposal`. Either pasted, a file path, or read as a top-level YAML block from a proposal `.html` artifact, or as a sidecar `proposal-scope.yml`. Schema in `references/proposal-scope-schema.md`.

## What this skill never does

- Author legal clauses from scratch. If `AGREEMENT_TEMPLATE.md` is missing a section the skill considers required (see Required Sections below), it warns and offers a generic boilerplate the consultant approves before insertion — never silently fabricated.
- Invent scope. If the proposal scope is ambiguous (e.g., the `payment_schedule` doesn't reconcile with `total_investment_usd`), the skill stops and asks. It does not paper over with defaults.
- Modify the proposal scope. The scope is the contract between sales and delivery; the agreement reflects it, not the other way around.
- Edit `AGREEMENT_TEMPLATE.md`. Substantive legal changes belong upstream in the template, not in the per-deal output.
- Skip the universality check. No consultant-specific identifiers, offer names, or workflow assumptions live in the source — everything client-specific is read from `BRAND.md` and `AGREEMENT_TEMPLATE.md`.

---

## PRECHECK (run before anything else)

1. **Find the proposal scope YAML.** Ask the user if not supplied: "Which proposal? Paste the scope YAML, give me the path to the proposal artifact, or paste a link." Accept any of:
   - A pasted YAML block
   - A path to `proposal-scope.yml`
   - A path to a proposal `.html` artifact (the skill extracts the YAML block from it — see `references/proposal-scope-schema.md` for where to look)
2. **Validate the scope against the schema in `references/proposal-scope-schema.md`.** Required fields:
   - `proposal.id`, `proposal.prospect.org_name`, `proposal.prospect.contact_name`, `proposal.prospect.contact_title`
   - `proposal.consultant.name`, `proposal.consultant.brand_name`
   - `proposal.discovery_date`
   - `proposal.scope.selected_offers` (≥1) with `offer_name`, `one_liner`, `deliverables`, `duration`, `investment_usd`, `payment_terms`
   - `proposal.total_investment_usd`
   - `proposal.payment_schedule` (≥1 milestone)
   If a required field is missing, stop and ask the user to fix the proposal scope. Do NOT pick defaults. Do NOT proceed with placeholder content that could be mistaken for final terms.
3. **Reconcile the scope.** Cross-check: `sum(payment_schedule[].amount_usd)` must equal `total_investment_usd`. If they disagree, stop and surface the discrepancy. Cross-check: every `selected_offers[].investment_usd` should roll up to `total_investment_usd` (allow for explicit `optional_addons` separately). If they don't, surface it.
4. **Find `BRAND.md`.** It will be injected from Claude Project Knowledge when the user has it set up. Verify required sections per the `build-carousel` brand schema: `Brand Identity` (name, monogram), `Typography` (heading_font, body_font), `Voice Rules`. If missing, tell the user — in your own words — that the agreement can't render in their brand without it, and their next step is to run `define-brand-voice` (a separate ~15-minute brand-capture skill) and add the resulting `BRAND.md` to their Project Knowledge. Do not chain-invoke. Preserve the scope YAML so they don't re-paste.
5. **Find `AGREEMENT_TEMPLATE.md`.** If present, validate against `references/agreement-template-schema.md`. If missing, enter the first-run elicitation flow (Phase 2 below). The consultant can also opt to elicit even if a template is present (e.g., "let's improve my existing one") — accept a paste or upload of their existing agreement and walk through it together.

---

## TRIGGER

Activates on: `/agreement`, `/contract`, `/engagement-letter`, "build the agreement", "draft the contract", "send the engagement letter", "turn the proposal into a contract", "they signed verbal — let's get the agreement out", or any request to convert an accepted proposal into a signed agreement.

---

## PHASE 1: INPUT GATHERING

### Step 1: Load the proposal scope YAML

Per Precheck. Present a short summary back to the user before generating:

```
Found:
  Prospect: <prospect.contact_name>, <prospect.contact_title>, <prospect.org_name>
  Offers:   <selected_offers[].offer_name>, total $<total_investment_usd>
  Schedule: <payment_schedule milestones, one line each>
  Start:    <scope.selected_offers[0].start_window>

Generate? (y / edit field / cancel)
```

If the user catches an error in the scope, send them back to fix the proposal first — don't edit scope in this skill.

### Step 2: Resolve consultant identity

From `BRAND.md`:
- `name` and `brand_identity_primary` (or `name` if no separate brand)
- `tagline` (optional, for the cover paragraph)
- `signature_phrases` (optional, for the cover paragraph voice)
- `Typography` block (heading_font, body_font with fallbacks)
- Primary brand color (first `Color Bases[].dark.bg` or `Color Bases[].light.accent` per consultant preference)

From `AGREEMENT_TEMPLATE.md`:
- `legal_entity` (e.g., "Your Practice LLC")
- `state_of_incorporation`, `governing_law`
- Signatory fields (consultant signature block)

If the proposal scope's `consultant.legal_entity` disagrees with `AGREEMENT_TEMPLATE.md.legal_entity`, surface the disagreement and ask which wins. Default to `AGREEMENT_TEMPLATE.md` unless the user overrides.

### Step 3: Resolve counterparty identity

From the proposal scope's `prospect` block. If `contact_title` is empty, ask. If the signer on the prospect side will be different from the discovery contact (sometimes the ED leads discovery but the board chair signs), prompt: "Who's signing on <org_name>'s side? Default is <contact_name>, <contact_title>."

### Step 4: Resolve effective date

Default: today. The consultant can override (`--effective-date 2026-06-15`). The agreement's effective date is independent of the engagement's `start_window` — surface both clearly.

### Step 5: Resolve optional clauses

Walk through `AGREEMENT_TEMPLATE.md.optional_clauses` and any scope-derived signals:

- **Travel-expenses pass-through:** include if `optional_clauses.travel_expenses_passthrough` is true AND the scope indicates in-person components (look for keywords like "in-person", "on-site", "site visit" in `selected_offers[].deliverables` or `custom_terms`).
- **Late-fee clause:** include if `optional_clauses.late_fee_pct_per_month` is set AND `payment_schedule` has any milestone beyond 60 days from effective date.
- **Non-solicitation:** include if `optional_clauses.non_solicitation_months` is set.
- **Revenue share / Data partnership / Performance share:** include only if the proposal scope's `custom_terms` references them AND `AGREEMENT_TEMPLATE.md.optional_clauses` enables them. If the proposal references rev share but the template doesn't enable it, stop and ask the consultant whether to add the clause this deal only or update the template.

Surface every optional clause being applied to the user before rendering. Let them flip any of them with `--no-<flag>` (e.g., `--no-non-solicitation`).

---

## PHASE 2: TEMPLATE ELICITATION (first run only, or on request)

Triggered when `AGREEMENT_TEMPLATE.md` is missing, OR when the user explicitly asks ("let me update my template", "improve my existing agreement").

### Step 1: Ask the framing question

> "Do you have an existing agreement to base this on? Paste it, upload a .docx, or give me a path — I'll improve it and save the result as your template. If you don't, that's fine too — we'll build one from scratch in about ten minutes."

### Step 2a: If existing agreement provided

Read it. Identify which of the required sections (see Required Sections below) are present, which are missing, which use ambiguous language. Present a diff-style summary:

```
Found in your agreement:
  ✓ Scope of Services
  ✓ Payment Terms
  ✗ Limitation of Liability (most consulting agreements have this — want me to add a standard clause?)
  ! Term & Termination (present but says "60 days" — most consultants use 30. Keep 60?)
```

Walk each gap/ambiguity with the user. Save the result as `AGREEMENT_TEMPLATE.md` per the schema in `references/agreement-template-schema.md`. Save to a path the user specifies, defaulting to alongside their `BRAND.md`.

### Step 2b: If no existing agreement

Guided interview. Capture in this order:

1. **Legal entity** — "What's your legal entity name (e.g., 'Your Practice LLC')? And state of incorporation?"
2. **Governing law / dispute resolution** — "Which state's law governs your agreements? Most consulting agreements add a mediation-first dispute resolution clause — want one?"
3. **Default payment terms** — "What's your default net? (Net 15, Net 30…) Late fee per month if any?"
4. **Termination** — "How long is your default termination notice? (Most consultants use 30 days written notice from either party.)"
5. **IP / work product** — "Standard default: you retain methodology IP, client owns the specific deliverables produced for them. Sound right, or do you want a different split?"
6. **Confidentiality term** — "How many years after the engagement ends does confidentiality survive? (2 is common.)"
7. **Liability cap** — "Do you want a limitation of liability clause? Standard is 'aggregate liability capped at total fees paid'."
8. **Optional clauses** — walk through travel-expenses pass-through, non-solicitation (length), revenue share (if applicable), data partnership (if applicable), warranty disclaimer.
9. **Signature block format** — what name/title goes on your side?

Render the interview output as a populated `AGREEMENT_TEMPLATE.md` per schema. Save it. Then continue into Phase 3.

The skill MUST flag, in writing, at the top of any newly-elicited template: "This template was generated from a guided interview. It is NOT legal advice. Have your attorney review it before using it in production."

---

## PHASE 3: RENDERING

### Step 1: Read the docx generation skill

If the runtime exposes a generic docx-generation skill at `/mnt/skills/public/docx/SKILL.md`, read it. Otherwise fall back to direct `python-docx` usage. Both work; the docx skill is preferred because it handles Google Drive compatibility quirks.

### Step 2: Walk template sections

For each `section` in `AGREEMENT_TEMPLATE.md.sections`:

1. Render the section's `title` as a top-level heading in the consultant's `heading_font`.
2. Walk the section's `template` (markdown) and substitute every `{{placeholder}}` reference against the proposal scope YAML. Use dot-notation paths (e.g., `{{scope.total_investment_usd}}` → look up `proposal.scope.total_investment_usd`).
3. Handle iteration constructs: `{{#each scope.selected_offers}}…{{/each}}` iterates the array, rendering the inner block for each offer.
4. Handle conditional constructs: `{{#if scope.exclusions}}…{{/if}}` renders only if the value is truthy / non-empty.
5. If a placeholder can't be resolved, do NOT silently leave the literal `{{placeholder}}` in the document. Stop and ask the user. (Unresolved placeholders in a shipped contract are a category of bug we never accept.)

### Step 3: Apply optional clauses

Per Phase 1 Step 5, append optional clause sections in the order they appear in `AGREEMENT_TEMPLATE.md.optional_clauses`.

### Step 4: Insert the cover paragraph (default ON; suppress with `--no-cover`)

A short paragraph at the very top of the document (above the agreement title), in the consultant's voice. Pulls from `BRAND.md.signature_phrases` and the proposal scope's prospect details. Example structure:

> "<contact_first_name> — <vision opener echoing the proposal's first paragraph, one sentence>. The agreement below reflects what we landed on <discovery_date>. Counter-sign at your convenience.
>
> <consultant_first_name>"

Voice posture for the cover paragraph: warm but professional, never marketing-flavored, never hedging. Honor `BRAND.md.voice_rules.em_dashes` and `language_variant`. The body of the agreement (everything below the cover) remains clinical regardless of brand voice.

### Step 5: Build the signature block

Two-column table:

| Consultant | Counterparty |
|---|---|
| <consultant.name>, <consultant.title> | <prospect.contact_name>, <prospect.contact_title> |
| <consultant.legal_entity> | <prospect.org_name> |
| Signature: ______________ | Signature: ______________ |
| Date: ______________ | Date: ______________ |

Use DXA widths (not percentages) for Google Docs compatibility.

### Step 6: Insert the standard footer

Every page footer carries:
- Page number, centered
- Consultant legal entity, right-aligned, small
- Document ID (derived from `proposal.id` + effective date), left-aligned, small

After the signature block, append one final paragraph in italic, smaller font:

> "*This agreement was generated from <consultant.legal_entity>'s template plus the accepted proposal scope dated <discovery_date>. Review before sending; substantive legal changes belong in the underlying template, not in the per-deal output.*"

This footer is non-negotiable — every agreement carries it. It protects the consultant from accidentally signing something the skill misrendered.

---

## PHASE 4: BRANDING THE .DOCX

Visual styling — pulled entirely from `BRAND.md`:

- **Page size:** Letter (8.5x11) by default; A4 if `BRAND.md.location` is non-US OR if the consultant overrides.
- **Margins:** 1 inch all sides.
- **Header (top of page 1 only, or every page per template preference):** consultant logo if available, brand_identity name in `heading_font`.
- **Body font:** `BRAND.md.body_font` with `body_fallback` for unavailable fonts.
- **Heading font:** `BRAND.md.heading_font` with `heading_fallback`.
- **Accent color:** first `Color Bases[].dark.accent` or consultant override. Applied to: section heading rules, signature block borders, page number color.
- **Footer:** consultant `legal_entity` right-aligned, page number centered, document ID left-aligned. Set page number font to `body_font` at 8pt.

The agreement is **NOT prospect-branded** (unlike the proposal artifact). This is the consultant's document, sent to the prospect for signature. Prospect-branding here would be a category error.

Critical for Google Drive / Word compatibility:
- All table widths in DXA, not percentages.
- `ShadingType.CLEAR` for table cell shading, never `SOLID`.
- Standard fonts only; if `BRAND.md` lists exotic fonts, fall back to `body_fallback` / `heading_fallback` and tell the user.
- No unicode bullets; use the docx skill's `LevelFormat.BULLET` if listing.

---

## REQUIRED SECTIONS

Every consulting agreement should include these sections. If `AGREEMENT_TEMPLATE.md` is missing one, the skill warns the user with a one-line rationale and a generic boilerplate option — never silently inserted, never silently omitted.

| Section | Drawn from | If missing |
|---|---|---|
| **Cover paragraph** | BRAND.md voice + scope prospect block | Skip if `--no-cover` or if consultant prefers a clinical opener |
| **Parties** | scope.consultant + scope.prospect | Required — stop and ask if either side is incomplete |
| **Scope of Services** | scope.selected_offers + custom_terms | Required — stop |
| **Investment & Payment Terms** | scope.total_investment_usd + payment_schedule | Required — stop |
| **Timeline** | scope.start_window + scope.payment_schedule.trigger dates | Required — stop |
| **Exclusions** | scope.exclusions | If empty, omit section silently (don't warn — explicit nothing is fine) |
| **Term & Termination** | template optional_clauses.default_termination_clause | Warn if missing from template; offer 30-day-notice default |
| **Confidentiality** | template optional_clauses.confidentiality_term_years | Warn if missing; offer 2-year default |
| **IP / Work Product Ownership** | template optional_clauses.ip_ownership | Warn if missing; offer "consultant retains methodology IP, client owns specific deliverables" default |
| **Limitation of Liability** | template optional_clauses or generic | Warn if missing; offer "aggregate liability capped at total fees paid" default |
| **Governing Law & Dispute Resolution** | template.governing_law + dispute_resolution | Required — stop and ask if missing |
| **Signatures** | scope.consultant + scope.prospect | Required — stop |

See `references/required-sections.md` for full rationale on each.

---

## VOICE POSTURE

The agreement is a legal document. Default tone for the body: clinical, plain English, no marketing voice, no hedging, no consultant signature phrases.

Two exceptions where the consultant's voice surfaces:
1. **Cover paragraph** (default ON) — warm, prospect-named, future-state-flavored, ≤4 sentences. See Phase 3 Step 4.
2. **Scope of Services prose** — if a `selected_offer.deliverables` line came from the proposal's vision section verbatim, preserve it. The consultant's voice in scope language is what they actually sold; preserving it protects expectations.

Body language follows `BRAND.md.voice_rules`:
- `language_variant: en-US` → "organization", "color", "license" as verb/noun handled consistently
- `language_variant: en-GB` → "organisation", "colour", "licence" (noun) / "license" (verb)
- `em_dashes: allow | replace_with_hyphen | replace_with_comma` — apply across the whole document

Never include the consultant's signature phrases in legal clauses. "Clarity fosters confidence" doesn't belong in the Limitation of Liability section.

---

## OUTPUT

1. **File path:** `~/Dropbox/vault/<area>/clients/<client-short-name>/deliverables/agreements/<prospect-slug>-<YYYY-MM-DD>.docx`
   - Fall back to the consultant's preferred path if specified
   - `<prospect-slug>` derived from `prospect.org_name` (lowercase, dashes for spaces, ASCII-only)
2. **Confirmation message to the user:**
   ```
   Built: <filename>.docx
   Prospect: <contact_name>, <org_name>
   Offers: <selected_offers[].offer_name>, total $<total_investment_usd>
   Effective: <effective_date>
   Cover paragraph: <on|off>
   Optional clauses applied: <list, e.g., 'travel pass-through, non-solicitation 12mo'>
   Optional clauses skipped: <list>
   Warnings: <any required-section warnings from above>
   ```
3. **Open the file** in the consultant's default .docx viewer (or surface it via `present_files` / equivalent) so they can review immediately.
4. **Do not e-mail, do not e-sign, do not "send"** — the consultant routes the document through whatever signing flow they use (DocuSign, HelloSign, scan-and-sign). E-signature integration is explicitly out of scope.

---

## QUALITY CHECKLIST (run before delivering)

### Scope integrity
- [ ] Every required field from the proposal scope YAML resolved to a real value
- [ ] No literal `{{placeholders}}` remain anywhere in the document
- [ ] `sum(payment_schedule[].amount_usd) == total_investment_usd`
- [ ] `selected_offers[].offer_name` appears verbatim in Scope of Services
- [ ] `selected_offers[].deliverables` items all present in Scope of Services
- [ ] `exclusions` items all present if section rendered
- [ ] `custom_terms` items all present
- [ ] `optional_addons` present if scope has them, clearly labeled as optional (NOT included in `total_investment_usd`)

### Template integrity
- [ ] Every required section present OR a documented warning explaining why it isn't
- [ ] Governing law / dispute resolution clause matches `AGREEMENT_TEMPLATE.md` (not invented)
- [ ] Late-fee / termination / confidentiality terms match `AGREEMENT_TEMPLATE.md` defaults
- [ ] Optional clauses applied match the user-confirmed list from Phase 1 Step 5

### Brand & format
- [ ] `BRAND.md.body_font` and `BRAND.md.heading_font` resolved (or fallback documented to user)
- [ ] Accent color applied to section rules and signature block border
- [ ] Header carries consultant brand identity, not prospect's
- [ ] Cover paragraph present (default) unless `--no-cover`, in consultant voice
- [ ] Voice rules respected (language variant, em-dash policy)
- [ ] Tables use DXA widths
- [ ] No unicode bullets
- [ ] Page footer present on every page (page number + legal entity + doc ID)
- [ ] Standard footer disclaimer present after signature block

### Universality (the source-skill check; never ships without)
- [ ] No consultant-specific names appear in the rendered output unless they came from `BRAND.md` or `AGREEMENT_TEMPLATE.md`
- [ ] No offer names appear in the rendered output unless they came from the proposal scope's `selected_offers[].offer_name`
- [ ] No revenue-share or data-partnership clauses appear unless the proposal scope's `custom_terms` references them AND `AGREEMENT_TEMPLATE.md.optional_clauses` enables them
- [ ] No workflow-assumption language naming a specific team member or ticketing system ("[role] raises…", "[role] sends…", "[ticketing system] populated by…") anywhere in the rendered output

---

## EDGE CASES

**Proposal scope says rev share but template doesn't enable it.** Stop and ask: "Add this clause for this deal only, or update your template?" Never silently skip; never silently add.

**Multiple selected offers with different payment terms.** Render each offer's payment terms in its own sub-section under Investment & Payment Terms. The top-level `payment_schedule` reflects the consolidated schedule across all offers.

**Signer different from discovery contact.** Surface in Phase 1 Step 3. The signature block uses the signer; the document body may still reference the discovery contact ("As we discussed with <contact_name>…").

**Optional add-ons accepted in the agreement.** If the prospect verbally accepts an add-on during the close call, the consultant should update the proposal scope first (re-running build-proposal with the addon promoted to `selected_offers`), then re-run build-agreement. Don't promote add-ons inside this skill — the proposal is the source of truth.

**Effective date in the past.** Allow with a warning. Sometimes work has already started.

**Non-USD currency.** Out of scope for v1. The skill assumes `total_investment_usd` and renders USD throughout. If the consultant operates in another currency, surface the limitation and offer to render with the explicit currency label they paste.

**Brand fonts unavailable on the rendering host.** Fall back to `body_fallback` / `heading_fallback` and tell the user in the confirmation message. The .docx still references the brand font name in its style definitions — Word / Google Docs will substitute on the recipient's side if they have the font.

**Consultant has multiple legal entities.** Use the one in `AGREEMENT_TEMPLATE.md.legal_entity`. If the consultant needs to sign as a different entity for this engagement, override with `--legal-entity "Alternate Entity LLC"`. Don't elicit on every run.

**The user wants a PDF.** Render .docx. They can export to PDF on their end (File → Download → PDF in Google Docs, or Save As PDF in Word). The skill does not render PDFs directly — keeping the output editable matters more than locking it.

---

**END OF SKILL**
