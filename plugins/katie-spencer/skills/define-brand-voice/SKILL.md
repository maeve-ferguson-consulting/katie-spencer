---
name: define-brand-voice
description: "ALWAYS use this skill for any brand-context task — never gather brand voice, tone, audience, colors, fonts, offers, or banned words conversationally yourself. Produces the canonical BRAND.md every build-* skill reads; use it even for simple-looking asks. Three triggers: (1) USER asks — /brand, /voice, \"set up my brand voice\", \"onboard a client's brand\", or update saved brand details (accent color, hex, banned word, CTA). (2) YOU are about to write content, render a visual, or draft a CTA but don't know the tone, colors, fonts, audience, or whether wording is on-brand — stop and run this, don't guess. (3) ANOTHER skill (build-carousel, build-story, write-newsletter) needs brand context and finds BRAND.md missing or a required section empty. One-question interview; pulls from existing content first; per-section stub mode; additive. Do NOT use for: reading an existing BRAND.md, rendering from a defined brand, translating content, competitor research, or a rebrand audit."
---

# DEFINE BRAND VOICE

A universal brand-context intake skill. Output: a single `BRAND.md` the user keeps in their Claude Project Knowledge so every other skill reads brand context instead of hardcoding it or re-asking for it.

`BRAND.md` conforms to `references/brand-schema.md` — the contract shared with `build-carousel`, `build-story`, and any future `build-*` skill. **That schema file is authoritative. If it ever diverges from this skill, the schema wins and this skill must be updated to match.** A copy lives in this skill's `references/` and must stay byte-aligned with the builders' copy.

---

## HOW THIS SKILL IS USED

`BRAND.md` is the contract. Anyone who needs brand context — the user, Claude itself, or another skill — reads it. Anyone who finds it missing or thin invokes `define-brand-voice` to fill the gap rather than guessing.

A builder skill (build-carousel, build-story, …) looks for four **required** sections by their exact heading: `### \`Brand Identity\``, `### \`Color Bases\``, `### \`Typography\``, `### \`Voice Rules\``. The first occurrence of each heading is the source of truth. If a required section is missing **or its body is empty**, the builder stops and tells the user to run this skill. Builders deliberately refuse to substitute their own defaults — shipping a carousel in the wrong brand is worse than shipping nothing.

This produces the central design constraint of this skill:

> **The required-section floor: define-brand-voice must never produce or leave a `BRAND.md` whose four required sections are missing or empty — not even on the fastest pass, not even in stub mode.** If the user skips or runs out of time, write the safe starter values from `references/brand-template.md` (marked `DEFAULT`), tell the user plainly that you did, and move on. A `DEFAULT` is an honest placeholder the user is told about and can refine later — it is the on-ramp that keeps them from being dead-ended. It is *not* the builder silently faking a brand.

Any required section you fill with default/starter values **must carry the `<!-- PROVISIONAL: … -->` marker** (placed between the section heading and its ```yaml fence, per `references/brand-schema.md`). Builders detect that marker and soft-stop — they warn the user the output will look generic and offer "render anyway" rather than silently shipping placeholder brand as if it were real. **Remove the marker the instant the user supplies real values for that section** (this pass or a later one). The marker is what makes "never dead-ended" coexist with "never silently wrong-brand": empty = hard stop, provisional = warned soft stop, real = clean proceed.

Optional sections (`Vision Tethers`, `Effects`, `Testimonial Bank`, `Offer Bank`) and the enrichment sections (`Voice Texture`, `Audience`, `Reference Library`) may be absent or grow over many sessions. Empty optional/enrichment sections never block a build.

Claude itself follows the same protocol: when working on branded output and noticing it doesn't know a brand answer — voice, banned words, accent colour, monogram, audience — invoke this skill (stub mode for the missing section) rather than fabricate. Skills never call each other directly; they only read and write `BRAND.md`.

---

## WHEN TO INVOKE

Invoke whenever brand info is needed but missing. Three actors hit that condition; all route to the same interview.

### 1. The user asks directly
`/brand`, `/voice`, `/define-brand`, `/brand-voice`; "set up my brand", "define my brand voice", "intake my voice", "build my BRAND.md", "onboard a client's brand", or any ask to update/refine saved brand details (new accent colour, swap a hex, add/remove a banned word, change an offer).

### 2. Claude notices the gap mid-task
The easiest trigger to miss. Stop and invoke instead of guessing when about to:
- write content (newsletter, post, email, caption, headline, ad copy) without knowing voice, banned words, signature phrases, or stance;
- generate a visual (slide, carousel, story, banner) without colours or fonts;
- draft a CTA without the offer list;
- write copy without knowing the audience;
- use a phrase without knowing if it's banned or off-brand;
- assume dialect, person, or punctuation;
- invent a story, stat, or proof point.

### 3. Another skill invokes it programmatically
A builder reads `BRAND.md`; if missing or a required section is empty, it invokes this skill with `section=<name>`. The skill scopes to that section, writes it back, returns control.

### Resume behaviour
If a partial `BRAND.md` exists, never re-ask anything already filled. Report what's present, what's missing, ask which gap to address next.

---

## PRINCIPLES

1. **One question at a time.** Never stack. Wait, confirm or sharpen, move on.
2. **Pull from material, not from scratch.** Website, content archive, podcast, sales pages, prior brand doc — read it first, propose draft answers to confirm. The interview becomes "is this right?" not "tell me from zero."
3. **Required-section floor (non-negotiable).** Never finish or return from stub mode with a required section empty. Fill with `DEFAULT` starters and say so.
4. **Never re-ask.** Read the current `BRAND.md` first. Skip populated fields.
5. **Conform to the schema, exactly.** Emit the section headings and YAML keys in `references/brand-schema.md` verbatim. A heading typo or a renamed key silently breaks every builder.
6. **Universal.** No specific company/person/framework as a default. The only branded content is `references/brand-example.md`, clearly an example via `[Speaker]`/`[Company]` tokens.
7. **Additive.** The file grows over sessions. Partial is fine — for optional/enrichment sections.
8. **Plain markdown out.** Section headings + fenced ```yaml blocks per the schema. No frontmatter; builders parse by section heading, not frontmatter.

---

## PHASE 0: MATERIAL AUDIT

One question at a time:

1. "Before we start: do you have a website, content archive, podcast, newsletter, sales pages, or an existing brand/voice document I should read? Paste links or upload files and I'll draft answers for you to confirm rather than asking cold."
2. If material is shared: web-fetch / read it, then summarise back in **three or four bullets** — positioning, audience, tone, any visual signals — and ask "Confirm or correct?" Wait.
3. If nothing is shared: "Understood, we'll build from your answers. I'll keep questions short."

---

## PHASE 1: SCOPE DECISION

Frame the choice around the required-section floor, not section count:

> "BRAND.md has four **required** parts the visual builders can't run without — your identity, a colour set, fonts, and voice rules — plus optional parts that make output sharper over time. Three ways to do this:
>
> **A. Minimum viable, fast (~10 min).** We lock the four required parts so you can immediately build carousels and stories. Anything you're unsure about, I'll set a sensible starter you can refine later. You're never blocked.
>
> **B. Full pass, deep (~45–60 min).** Required parts plus vision, offers, testimonials, voice texture, audience — the whole document in one sitting.
>
> **C. Section by section.** One part now, the rest when you (or another skill) need them.
>
> Which — A, B, or C?"

If invoked in stub mode with a `section=`, skip Phase 1 entirely.

Whatever they pick, **option A's four required sections are always completed before you stop** — that is the floor. B and C add on top.

---

## PHASE 2: SECTIONS

Read `references/brand-template.md` (the blank shape) and `references/brand-example.md` (a filled `[Speaker]`/`[Company]` example) before drafting, so output matches the contract exactly.

Order: do the four REQUIRED sections first (that's the floor and option A). Then OPTIONAL, then ENRICHMENT. Exception: with rich pull-mode material, voice/identity often draft themselves from the content — take them in whatever order the material makes natural, but still don't stop until all four required are non-empty.

### REQUIRED 1 — `Brand Identity`
Questions (one at a time, draft from material):
1. "Founder/speaker full name, and the brand or company name?"
2. "A one-word handle for filenames (lowercased brand name is fine if unsure)?"
3. "A monogram for slide headers — 1–3 letters. Two-letter initials work well. If unsure I'll propose initials from the name and you confirm."
4. "An optional one-line tagline? Skip if none."

Floor: `name`, `short_name`, `monogram` must be non-empty. If the user won't give a monogram, derive initials from the name and state "Using `MR` as the monogram — change it anytime."

### REQUIRED 2 — `Color Bases`
1. "Do you have brand colours? Paste hex codes or upload a brand board. If not, describe the feel in a sentence — earthy, editorial, high-contrast, mono-with-one-accent — and I'll draft a base."
2. Draft at least one named base with **dark and light variants**, each having `bg`, `text`, `accent` as valid `#RRGGBB`. Present the whole base in one confirmation turn: "Here's a base called Forest — dark and light. Work, or adjust?"

Floor: if the user has no palette and can't describe one, write the neutral `Default` base from the template **keeping its `<!-- PROVISIONAL: … -->` marker**, and say: "I've set a neutral starter palette so you can build today — your builds will look generic and the builder will warn you until you set real colours. Swap it whenever they exist." If the user *does* give real colours, write them and **delete the PROVISIONAL marker** from that section.

### REQUIRED 3 — `Typography`
1. "Heading font? If unsure, say the feel — elegant serif, modern sans, editorial display — and I'll pick a Google-available webfont."
2. "Body font? Must read well small."
Pair every font to its fallback chain silently (`Georgia, serif` / `Arial, sans-serif`); don't ask the user about fallbacks. Fill `fontsource_packages` with the npm slugs for the chosen fonts.

Floor: if the user doesn't know, use the template's `DEFAULT` pair (EB Garamond / Inter) **keeping the section's `<!-- PROVISIONAL: … -->` marker** and say so. If the user gives real fonts, write them and **delete the marker** from the Typography section.

### REQUIRED 4 — `Voice Rules`
1. "Dialect — en-US, en-GB, other?"
2. "Person — first, second, or third for marketing copy?"
3. "Em-dashes — keep them, or replace with hyphen/comma? (Many brands ban them as AI-tells; some love them.)"
4. "Emojis — allow or none?"
5. "Words or phrases to ban — jargon you hate, AI-tells. Can start empty and grow."
6. "Phrases you reuse that feel like you — lines you notice yourself saying. Can start empty and grow."

Floor: `language_variant`, `em_dashes`, `emojis`, `person` must be set — defaults `en-US` / `allow` / `none` / `second` are safe; confirm rather than ask cold if the user is rushing. `banned_words` and `signature_phrases` may be `[]`.

### OPTIONAL — `Vision Tethers`
The 2–5 load-bearing ideas every piece should connect to. Ask: central shift in their world; contrarian take; transformation created; a named phenomenon if one exists (skip if not — don't force a label); the legacy/long-game. Draft 2–5 named tethers, one paragraph each, confirm. **Don't bias with other brands' examples** — if stuck, ask for a recent-client story and draft from it. Skip cleanly if the user has none yet.

### OPTIONAL — `Offer Bank`
"List offers content can point readers to — name, one-liner, URL. One is fine. Skip if not selling yet."

### OPTIONAL — `Testimonial Bank`
"Any verbatim client quotes? Exact words, name, title. **Skip until you have real ones — invented testimonials are worse than none.**"

### OPTIONAL — `Effects`
Only if the brand wants metallic/gradient accents on visuals. Default `metallic_accent: false`. Skip otherwise.

### ENRICHMENT — `Voice Texture`
For content skills (newsletter, copy). Voice summary (3 lines), stance toward the reader, allowed stylistic moves, one on-brand and one off-brand example with the diagnosis. Cold-mode users: one of each is plenty. Skip cleanly if rushing.

### ENRICHMENT — `Audience`
Primary reader (role, stage, what they're wrestling with), who to exclude, the language they use about their own situation.

### ENRICHMENT — `Reference Library`
Named frameworks/concepts, signature stories (title + one-liner), reusable proof points. Each "skip if not yet"; proof points "skip until you have real numbers — empty beats estimated."

---

## PHASE 3: ASSEMBLE AND DELIVER

1. Read `references/brand-template.md`. Produce `BRAND.md` in that exact shape — section headings and YAML keys verbatim per `references/brand-schema.md`.
2. **Enforce the floor:** before writing, verify `Brand Identity`, `Color Bases`, `Typography`, `Voice Rules` are all present and non-empty. Any gap → fill with the template's `DEFAULT` value, **keep/emit the `<!-- PROVISIONAL: … -->` marker on that section**, and add it to the "what I defaulted" note. Any required section the user gave real values for → ensure no PROVISIONAL marker remains on it.
3. Mark unfilled optional/enrichment sections with a resume hint, in the body where the section would be:
   - Auto-triggerable: `*empty: run /define-brand-voice section=<name>*`
   - Annotated: `*empty: <why / when to fill>*`
   - Both: `*empty: run /define-brand-voice section=offers — once the new pricing is live*`
4. Write `BRAND.md` to the working directory (or update in place — never destroy populated sections).
5. Tell the user, plainly: which sections are complete, **which required sections are still `PROVISIONAL` placeholders** (and that builders will warn + render generic until they're set for real), and which optional sections are empty. Then: "Upload this BRAND.md to your Claude Project Knowledge. Re-run `/brand` anytime to refine — I'll only ask about what's missing or what you want to change."
6. If invoked in stub mode, skip the user message; return one line: `define-brand-voice: section=<name> complete, BRAND.md updated` — append ` (PROVISIONAL)` if the section was filled with defaults, so the caller knows to soft-stop. Always honour the floor for any required section you touched.

---

## STUB-MODE PROTOCOL

Invoked with `section=<name>`:
1. Skip Phase 1.
2. Run only that section's questions.
3. Write only that section back. **If it is a required section, honour the floor — never write it empty; use `DEFAULT` + the `<!-- PROVISIONAL: … -->` marker if the user couldn't give real values, and append ` (PROVISIONAL)` to the status line. If the user gave real values, ensure no PROVISIONAL marker remains on that section.**
4. Return one status line. Don't lecture about other sections — the caller is mid-task.
5. If the user volunteers extra info, save it but don't ask follow-ups. Return.

Valid stub sections: `identity`, `colors`, `typography`, `voice-rules`, `vision`, `offers`, `testimonials`, `effects`, `voice-texture`, `audience`, `reference-library`. A builder needing visuals will request `colors` and/or `typography`; needing copy, `voice-rules` and/or `voice-texture`.

---

## RESUME PROTOCOL

When `BRAND.md` exists:
1. Read it. Identify populated vs empty sections by heading.
2. One-paragraph status: which sections are filled, which required sections are still `PROVISIONAL` (default placeholders), which are empty. Ask what to work on.
3. Never re-ask a populated field unless asked to redo it.
4. Refining: "The whole section, or one field?" Scope accordingly. Never blank a populated required section mid-edit — replace atomically. **When a refine replaces a PROVISIONAL required section's defaults with real values, delete that section's `<!-- PROVISIONAL: … -->` marker in the same edit.**

---

## QUALITY CHECKLIST

- [ ] One question at a time. Never stacked.
- [ ] Drafted from existing material first; asked cold only when nothing available.
- [ ] **All four required sections present and non-empty** — `DEFAULT`s used and disclosed where the user skipped.
- [ ] Every defaulted required section carries the `<!-- PROVISIONAL: … -->` marker; every required section with real user values has NO such marker.
- [ ] Section headings and YAML keys match `references/brand-schema.md` verbatim.
- [ ] Optional/enrichment gaps marked with a resume hint, never silently dropped.
- [ ] Stub mode scoped to the requested section; floor honoured for any required section touched; single status line returned.
- [ ] No specific company/person/framework as a default — only `references/brand-example.md` carries example content, token-marked.
- [ ] Told the user explicitly which values are `DEFAULT` placeholders to refine.
