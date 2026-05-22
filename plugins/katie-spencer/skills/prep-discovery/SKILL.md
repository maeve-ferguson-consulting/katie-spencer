---
name: prep-discovery
description: "Build a universal pre-discovery-call intelligence briefing for a prospect. From a name + URL (or dossier, calendar blob, partial info), produce an internal markdown brief telling the consultant what to ask, what to listen for, and which offer to recommend. Trigger on /intel, /prepcall, /discovery-prep, /research, 'prep me for the call with X', 'I have a call with X tomorrow', 'research this prospect', 'who is X before our call', or any pre-call research ask. Reads BRAND.md (voice, signature framework), SERVICES.md or the Offer Bank section of BRAND.md (offer catalog), and ICP.md (green/red-flag signal map). If ICP.md is missing, elicits inline on first run and saves it with a PROVISIONAL marker. Every signal claim must cite evidence + source URL — no fabrication. Lane-aware when the consultant's brand declares positioning lanes. Internal-only output; not for the prospect. NOT for post-call sales artifacts, cold outreach, generic web research, or competitor analysis."
---

# PREP DISCOVERY

Universal pre-discovery-call research skill. Produces an internal markdown briefing the consultant reads in five minutes before a prospect call — what to ask, what to listen for, which offer to recommend.

This skill is consulting-practice-agnostic. Every consultant-specific input (voice, offers, ideal-client-profile signals) is read at runtime from documents in the consultant's Claude Project Knowledge. The skill itself never names a person, an offer, or a methodology — that always comes from the project layer.

---

## HOW THIS SKILL READS CONTEXT

Three documents in the consultant's Claude Project Knowledge:

1. `BRAND.md` — voice, signature framework name, signature phrases. Conforms to the schema in `define-brand-voice/references/brand-schema.md`. Required.
2. `SERVICES.md` **or** the `Offer Bank` section of `BRAND.md` — the catalog of offers the briefing will rank against the prospect's signals. Required.
3. `ICP.md` — the signal map: green flags, red flags, listen-for phrases, signal categories. Required. **This skill owns this document.** If missing, the skill elicits it inline on the first run (see `references/icp-schema.md`).

If a required document is missing or empty, do NOT substitute defaults. Stop, name the missing artifact, and either invoke the right next step (`define-brand-voice` for BRAND.md) or run the inline elicitation (for ICP.md). Shipping a briefing built on guessed signals is worse than shipping nothing — it teaches the consultant to distrust the output.

---

## PRECHECK (run before anything else)

**Verbalize what you're checking for, then report what you found.** The user should see the skill name the three docs by name before research starts — that prevents silent guessing and gives them a moment to upload a doc they forgot about.

Open with, in your own words:

> "Before I research [prospect], let me confirm the three docs I need are in your Project Knowledge:
>   1. **`BRAND.md`** — your voice, signature framework, offer catalog
>   2. **`SERVICES.md`** *(or your `BRAND.md > Offer Bank`)* — the offers I'll recommend from
>   3. **`ICP.md`** — your ideal-client-profile signal map (green flags, red flags, listen-for phrases)
>
> Checking now…"

Then look for each in the conversation context (Project Knowledge is injected there).

### 1. `BRAND.md`
- **Missing or empty required section?** Stop. Tell the user: "Your `BRAND.md` isn't in Project Knowledge yet. Do you have one I should look at, or should we run `define-brand-voice` first (~15 min)? Your prospect details will be preserved either way."
- **Required section marked `<!-- PROVISIONAL: ... -->`?** Soft-stop. Warn the brief will reference placeholder voice/identity; offer to proceed anyway only on explicit confirmation.

### 2. Offer catalog (`SERVICES.md` or `BRAND.md > Offer Bank`)
- **Neither present?** Stop and ask: "I don't see an offer catalog. Options: (a) you have a `SERVICES.md` to upload, (b) let me read offers from `BRAND.md > Offer Bank` (point me at where they live), or (c) elicit a quick catalog inline now (5 min). Which?" Wait. Do not guess.
- **Both present?** Use `SERVICES.md` (it's the canonical, more detailed source).

### 3. `ICP.md`
- **Missing?** Ask first: "I don't see your `ICP.md`. Do you have one already that I should look at, or is this your first time and I should walk you through capturing it (5 min, one question at a time)?" If they have one, wait for it. If they don't, run the inline elicitation in `references/icp-schema.md` § "First-run elicitation" — save the result to `ICP.md` in the conversation working directory and tell the user to upload it to their Project Knowledge for next time. If the user is rushing or skips fields, write the section with `<!-- PROVISIONAL: starter, replace before relying on output -->` and proceed.
- **Present but PROVISIONAL?** Soft-warn the user. The brief will be only as sharp as the signal map.

### Report what you found

Before proceeding to Phase 0, give the user a one-line summary:

> "Found: `BRAND.md` ✓, `BRAND.md > Offer Bank` ✓ (no `SERVICES.md`), `ICP.md` ✓. Proceeding with research on [prospect]."

If anything is PROVISIONAL or was just elicited inline, name it in the summary so the user knows the brief inherits that softness.

If a required document is missing or empty, do NOT substitute defaults. Shipping a briefing built on guessed signals is worse than shipping nothing — it teaches the consultant to distrust the output.

---

## TRIGGER

Activates on: `/intel`, `/prepcall`, `/discovery-prep`, `/research <name>`, "prep me for the call with [Name]", "I have a call with [Name] tomorrow", "research [Name] before our call", "who is [Name]", "what do we know about [Name]", or any request to prepare for a first prospect call.

If only a name is given (e.g., "[contact name] at [org name]"), figure out the URL via web search. If a calendar event blob is pasted, extract the prospect's name and org from it. If a path to a prospect dossier is given, read it and skip the web-presence sweep for fields the dossier already covers.

---

## INPUTS

Accept any of these, most-to-least common. Do not insist on a particular shape:

1. Prospect contact name + org + URL (e.g., "[contact name], [org name], [domain]")
2. Prospect contact name + org (skill discovers URL)
3. Path to a prospect dossier (from a dossier-builder skill or hand-written)
4. Calendar event blob (extract name + org from attendee fields and event description)
5. Nothing but a name (skill searches, then disambiguates if multiple people share the name)

**Disambiguation:** if a name returns multiple plausible matches, present options: "I found three [Name]s — (A) [person at org X], (B) [person at org Y], (C) [person at org Z]. Which?" Do not pick silently.

**Confirm before researching:**
> "Prepping discovery brief for [Name] at [Org] ([URL]). Lane: [current_lane from BRAND.md, or 'not set']. Anything you want me to weight or skip? Proceeding with research."

---

## PHASE 0 — INTAKE

Resolve the inputs to a confirmed (name, org, URL) triple. If a dossier is provided, read it and note which fields it already covers so the web phases don't redo that work.

If the consultant volunteered context ("she was referred by X," "we met at the conference last month," "she opted in to my Substack last week"), capture it — referral and origin context shapes the opening angle.

---

## PHASE 1 — WEB PRESENCE SWEEP

Fan out parallel research agents in a single message. The agent topics come from two places: a universal core, and the `signal_categories` list in `ICP.md`. Brief each agent well — they don't see the full conversation context.

**Universal core agents (always spawn):**

- **Org profile:** mission, size, vintage, location, stage. Leadership names + tenure + bios. Recent news, press releases, public statements. Pull from the org website, about page, leadership page, and recent press.
- **Prospect contact profile:** background, tenure, prior roles, public statements, podcast appearances, articles authored. Anchor the brief on the human, not just the org.
- **IP / brand voice scan:** what is the prospect saying publicly *right now*? What's their stated theory of their own problem? What language do they use? Pull from blog, social, recent talks, podcast interviews.

**Domain-specific agents (read from `ICP.md > signal_categories` and spawn one per category):**

For a nonprofit board governance consultant, `signal_categories` will include things like board composition, 990 filings, capital campaigns, ED transitions, governance signals. For a SaaS GTM consultant, the categories will be different — funding stage, hiring patterns, product launches, exec changes. The skill must adapt to the consultant's domain rather than imposing one.

**Search strategy:** use web search via the parallel agents. Cite a URL for every claim. If a search returns nothing, say "no signal found" — do not infer.

---

## PHASE 2 — IP / BRAND SCAN OF THE PROSPECT

Distill from Phase 1:

- What named methodology, framework, or program does the prospect use? (Codified / semi-codified / tacit.)
- What's their public voice — what tone, what cadence, what tells?
- What's their stated theory of their own problem? (The diagnosis they hold today; the consultant's job is to confirm or revise it on the call.)
- What recent shift would they point to as the trigger for this conversation? (Examples by domain: new exec hire or board chair in nonprofit-governance; new funding round or VP hire in SaaS GTM; new partnership or practice-acquisition in private-practice consulting; new mandate or operating-model shift in any vertical.)

---

## PHASE 3 — SIGNAL EXTRACTION

Score the prospect against every entry in `ICP.md > green_flags` and `red_flags`. For each signal:

- **Fired / Partial / Not fired / Insufficient evidence**
- **Evidence:** one-sentence quote or fact from the research, with the URL
- **Listen-for on the call:** the literal phrase or pattern that would confirm/disconfirm

Output as a table the consultant can scan. No flag fires without evidence. If you can't find evidence either way, say "insufficient evidence" — that is itself useful (it tells the consultant what to listen for).

---

## PHASE 4 — OFFER RECOMMENDATION

Match the firing signals to the consultant's offer catalog (`SERVICES.md` or `BRAND.md > Offer Bank`). Output:

- **Primary:** the offer the signals most clearly support, with one-line reasoning tied to specific signals.
- **Fallback:** the next-best offer if the prospect pushes back on price or scope.
- **Stretch:** the larger offer to surface if the prospect proves to be more ready than they sound on the inbound.

**Lane awareness (when the consultant's BRAND.md declares positioning lanes):** if `current_lane` is set and the firing signals point to the *other* lane, do NOT silently switch lanes. Surface the tension: "Your current_lane is A, but this prospect's signals match flags tagged for Lane B in your ICP.md. Worth a moment on the call to clarify which conversation they want to have."

**The offer recommendation is a starting frame, not a prediction.** Say so. The consultant decides after the call.

---

## PHASE 5 — BRIEFING ASSEMBLY

Output a single markdown document. Internal-only — clinical, direct, no marketing voice. The consultant reads this in five minutes before the call, possibly on a phone.

Use the consultant's signature framework name (from `BRAND.md`) where relevant — e.g., "[Framework] suggests Discover → Clarify is the right starting motion here." Do NOT use the consultant's signature phrases in the briefing body — those are for prospect-facing output, not internal prep.

```markdown
# Pre-Discovery Briefing — <Prospect Org> · <Date>

## TL;DR
- **Fit:** Strong / Good / Marginal / Weak (one-line why)
- **Recommended offer:** <name from SERVICES.md / Offer Bank> (with fallback if they push back)
- **One thing to listen for:** <the single most diagnostic phrase or pattern>

## About <Org>
- Mission, size, vintage, location, stage
- Leadership (names, tenure, signal)
- Recent moves (funding, hiring, product launches, leadership transitions, strategic shifts — whatever applies to the prospect's domain)

## About <Contact>
- Role, tenure, prior path
- What they say publicly (in their own language)
- What this call likely costs them in time — and what they're hoping to get

## Why this call matters
- The trigger that brought them to the call (inbound signal, referral, opt-in context)
- What's likely driving the inquiry beneath the stated reason

## Signals fired (from ICP.md)
| Signal | Status | Evidence | Listen-for on the call |
|---|---|---|---|
| <flag> | ✅ Fired / ⚠️ Partial / ❌ Red / — Insufficient | <quote + URL> | <literal phrase / pattern> |

## What to ask
3–5 high-leverage questions tailored to the signals. NOT generic discovery questions ("what are your goals?"). Specific: "You mentioned [X] in your 2024 annual report — has that landed?"

## What to listen for
3–5 literal phrases or patterns that confirm or disconfirm fit. Map each to which offer it points to. The consultant should be able to hold these in their head during the call.

## Offer recommendation
- **Primary:** <offer name> — <one-line reasoning tied to signals>
- **Fallback:** <offer name> — if budget objection or smaller scope appetite
- **Stretch:** <offer name> — if they're more ready than they sound

## Lane note (if applicable)
- If signals cross lanes, surface the tension here. One sentence on which conversation the consultant should steer toward.

## Things NOT to do
- 1–3 specific anti-moves grounded in the prospect's public signals (e.g., "Don't lead with price; lead with vision" / "Don't pitch [X] — they explicitly distance from [X] in their public writing" / "Don't compare them to [competitor] — they've publicly criticized that frame").

## Sources
- <URL 1>
- <URL 2>
- …
```

Section order matters. The TL;DR must be readable in 10 seconds. The consultant should be able to skip the rest if they're walking into the call.

---

## VOICE POSTURE FOR THE BRIEFING

- Internal-only — clinical, direct, no marketing voice.
- Use the consultant's signature framework name from `BRAND.md` when it sharpens guidance.
- Do NOT use the consultant's signature phrases in the briefing — those are for prospect-facing output.
- British English vs American English: follow `BRAND.md > Voice Rules > language_variant`.
- Em-dashes / emojis: follow `BRAND.md > Voice Rules`. Default to no emojis in an internal brief regardless.

---

## CRITICAL CONSTRAINTS

- **No fabrication.** Every signal claim cites evidence + URL. If you can't find evidence, say "insufficient evidence." Never guess.
- **Listen-for items must be literal.** Abstractions like "Listen for tension," "Listen for hiring frustration," or "Listen for pricing anxiety" are wrong. Literal quoted phrases the consultant could match in real time are right — e.g., "'I'm tired of chasing my board for meeting prep'" (governance), "'Every VP candidate ghosts us after the second round'" (SaaS hiring), "'We changed pricing and it didn't move the needle'" (pricing). The consultant should be able to hear the phrase land.
- **The offer recommendation is a starting frame.** The consultant decides after the call. Say so.
- **Lane awareness.** When `BRAND.md` declares `current_lane`, surface lane-crossing signals; never silently switch lanes.
- **Brief is internal.** It is NOT sent to the prospect. Tone is operational. No softening.
- **Do not invent statistics, credentials, audience numbers, or quotes.** If unverified, mark "TBV — unverified."

---

## EDGE CASES

**Prospect has minimal web presence.** Note the gaps honestly. A thin presence is itself a signal: early-stage, in transition, or operating primarily offline. Flag which signals can't be assessed and prioritize those for discovery on the call.

**Prospect was referred by a known contact.** Note the referrer if known and capture the relationship context — what the referrer likely communicated, how to acknowledge the relationship naturally on the call. Still run the full research; don't skip due diligence based on referral source.

**Prospect appears below the consultant's investment floor.** Flag it. Provide the evidence (revenue signals, business maturity). Let the consultant decide whether to take the call.

**Multiple prospects being prepped at once.** Generate a separate briefing for each. Never combine.

**Prospect's signals contradict each other.** Surface the contradiction in the brief rather than smoothing it over. "She's writing publicly about Lane B problems but her org's recent moves all point to Lane A work." That's exactly what the consultant needs to know.

**Existing dossier conflicts with web research.** Trust the most recent evidence. Note the conflict in the brief so the consultant can confirm on the call.

**Calendar event with no other context.** Extract attendee name and org from the event. If insufficient, ask the consultant one question: "I have only a name and a meeting time. Do you have anything else — referral source, opt-in form notes, prior email?"

---

## WHAT THIS SKILL IS NOT

- **Not a post-call sales artifact builder.** That runs *after* the discovery call to produce the prospect-facing proposal frame.
- **Not a cold-outreach producer.** This is a pre-call brief for a warm conversation. The outreach skill produces messages to send before any call is booked.
- **Not a competitive-intelligence dossier.** It does light competitive scanning where it informs the offer recommendation, but its goal is the call, not the market map.
- **Not a generic web-research helper.** It's scoped to a single prospect, anchored to the consultant's signal map, and oriented toward a single decision: what to ask and what to recommend.

---

## QUALITY CHECKLIST (run before presenting)

### Source integrity
- [ ] Every signal claim has an inline evidence quote AND a source URL.
- [ ] No fabricated stats, credentials, audience numbers, or framework names.
- [ ] Every "What to listen for" item is a literal phrase or pattern, not an abstraction.
- [ ] "What to ask" items are all >10 words and prospect-specific (no generic discovery Qs).

### Project-knowledge alignment
- [ ] Offer recommendation pulled from `SERVICES.md` or `BRAND.md > Offer Bank` — verbatim names.
- [ ] Signals scored against every entry in `ICP.md > green_flags` and `red_flags`.
- [ ] Lane awareness applied if `BRAND.md > Positioning > current_lane` is set.
- [ ] Signature framework name from `BRAND.md` referenced where it sharpens guidance.

### Output shape
- [ ] All required sections present: TL;DR, About Org, About Contact, Why this call, Signals, What to ask, What to listen for, Offer recommendation, Things NOT to do, Sources.
- [ ] TL;DR is readable in under 10 seconds.
- [ ] Sources section has ≥3 distinct URLs.
- [ ] Markdown, not HTML.

### Voice
- [ ] Language variant matches `BRAND.md > Voice Rules > language_variant`.
- [ ] Em-dash policy respected per `BRAND.md > Voice Rules`.
- [ ] No emojis in an internal brief (override only if BRAND.md voice rules explicitly say otherwise).
- [ ] No banned words from `BRAND.md > Voice Rules > banned_words`.

### Universality (self-check)
- [ ] Briefing references the prospect, the consultant's brand, and the consultant's offers — and nothing else.
- [ ] No hardcoded methodology names, framework names, or person names in the briefing body that didn't come from `BRAND.md` or `SERVICES.md`.

---

## AFTER THE BRIEFING — ONE SUGGESTION

After presenting the brief, surface ONE specific elaboration the consultant could make to `ICP.md` based on what the research just revealed. Examples:

- (Governance domain) "I flagged 'capital campaign approaching' as a green flag but it's not in your ICP.md yet — want to add it?"
- (SaaS GTM domain) "I noticed this prospect's pricing changed twice in 18 months but your ICP.md doesn't list 'pricing instability' as a signal category. Want me to add it?"
- (Any domain) "Three of the listen-for phrases in your ICP.md are still abstractions ('feels stuck,' 'wants alignment') — want to refine them now while the call is fresh in your mind?"

One concrete editing prompt the consultant can act on in 30 seconds. Do NOT edit `ICP.md` programmatically — surface the suggestion; they decide.

---

**END OF SKILL**
