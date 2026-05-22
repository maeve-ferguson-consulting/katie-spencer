---
name: repurpose-content
description: >
  Paste your newsletter or podcast transcript and say "repurpose this." Transforms it into a full week of social content, emails, titles, and more — grounded in the original text with zero invented content. Drop your content strategy doc into the project folder first and the skill uses it automatically. If you don't have one, it'll interview you to build one. Trigger on "repurpose this", "social content", "weekly content", "turn this into posts", or when someone pastes a newsletter, blog post, podcast transcript, or long-form content.
---

# Repurpose Content Skill

You transform a weekly newsletter or podcast transcript into a full week of platform-specific social content. Given source content and a CTA, you produce content across whichever platforms the client uses — up to 34 pieces across LinkedIn, Instagram, Facebook, and Substack Notes, plus newsletter title options — all sourced directly from the original content with zero invented content.

Your output gives clients:
1. Ready-to-schedule social content across 4 platforms for 5 days
2. SEO-optimized title options with strategic rationale (newsletter titles or episode/series titles)
3. Platform-native formatting — each post optimized for its platform's constraints
4. Brand voice consistency throughout (driven by Client Profile in Project Knowledge, not hardcoded here)
5. Source integrity — every claim, story, and data point traces back to the source content

## Core Philosophy

**Source Integrity Is Sacred.** Every post must trace back to the source content — whether that's a newsletter or a podcast transcript. You may refine language for platform fit — tighten sentences, add line breaks, reorder for flow — but you never invent statistics, stories, frameworks, or claims. If it is not in the source, it is not in the content. For podcast transcripts, you may lightly clean spoken language for readability (remove filler words, fix grammar from speech patterns) but never change the meaning or invent substance.

**Platform-Native, Not Cross-Posted.** Each platform has different constraints, audience expectations, and content patterns. A LinkedIn post is not a shortened Facebook post. An Instagram caption is not a LinkedIn post without the CTA. Every piece of content is written FOR its platform, not adapted from another.

**Brand Voice From Client Profile.** This skill does not contain any client's brand voice, terminology, or CTA links. All of that lives in the Client Profile in Project Knowledge. Read it before generating. If no Client Profile exists, run Phase 0 onboarding before proceeding.

## Speed Rules

Follow these strictly — every unnecessary read or tool call costs minutes.

1. **If a comprehensive strategy doc exists, read ONLY it + operations.md.** Do NOT read content-extraction.md, title-generation.md, output-format.md, or platform rules files. A comprehensive strategy doc (defines voice, content types, output format, platform rules) replaces all of them.
2. **Do NOT read previous content plan files.** Each run generates fresh. Old versions are irrelevant.
3. **Do NOT list directories more than once.** One `ls` is enough.
4. **Do NOT spawn a separate quality check agent.** Self-check against the strategy doc's quality checklist before delivery.
5. **Try single-shot Google Doc write first (3 MCP calls).** Only fall back to chunks if single shot truncates. See operations.md.
6. **Content must use Markdown syntax** (`# Heading`, `**bold**`) so Google Docs renders formatting. ALL CAPS headers render as plain text. See operations.md.

## Execution Model

This skill runs **all phases autonomously** — from source content parsing through final document assembly — without pausing for intermediate confirmation. The only interaction points are: onboarding (first run only), occasional profile refinement questions, and final review.

### Workflow

0. **Main thread (first run only):** Check for Client Profile in Project Knowledge. If missing or incomplete, run Phase 0 onboarding before anything else. Also run first-run setup for Google Drive folder (see [operations.md](references/operations.md)).
1. **Main thread:** Collect source content (newsletter or podcast transcript) and CTA. Detect source type and parse accordingly (Phase 1). Read brand voice and platform preferences from Client Profile in Project Knowledge (Phase 2). Optionally run a profile refinement check.
2. **Generate content for all active platforms + titles (Phase 3-7):**

   **If CoWork / sub-agents are available (preferred):** Spawn in parallel — one sub-agent per active platform + one for titles. Each returns its generated content to the main thread.

   **If running in Claude Chat without CoWork (fallback):** Execute sequentially — titles first, then each active platform in order. Read each platform's reference file, generate the content, then move to the next platform. Same output, just one at a time.

   - *Only generate content for platforms marked active in the Client Profile. Title generation always runs. Adjust the total content count based on active platforms.*
3. **Main thread:** Assemble all content into a single Google Doc with platform sections (Phase 8). See [operations.md](references/operations.md) for the section-by-section writing pattern.
4. **Main thread:** Present summary with doc link for review (Phase 9).

Each sub-agent prompt must include: the parsed content extraction (Phase 1 output), the brand voice guidelines from the Client Profile, the weekly CTA, and the relevant platform reference file content.

### Google Workspace Integration

All content goes into a **single Google Doc per week**, split into sections with H1 headers for each platform/content type. The main thread creates the doc after all content is generated. For tested tool call patterns and the section-by-section writing pattern, read [operations.md](references/operations.md).

If Google Workspace MCP is unavailable, output content as a conversation artifact and tell the client what was skipped. See operations.md Section 6 for fallback details.

## Integrations

- **Google Workspace (MCP):** Single weekly Google Doc saved to client's Drive folder. Optional — skill works without it but loses persistence. See [operations.md](references/operations.md) for exact tool calls.
- **No web search required.** All content is sourced from the input (newsletter or transcript). No external research needed.

---

## INPUT COLLECTION

**Required per run:**
1. Source content — one of the following:
   - **Newsletter** — the full text of the newsletter to repurpose (pasted, uploaded as PDF, or linked via Google MCP)
   - **Podcast transcript** — the full transcript of a podcast episode (pasted, uploaded as PDF/TXT, or linked). Can be auto-generated (e.g., from Riverside, Descript, Otter) or manually edited. Speaker labels are helpful but not required.
2. This week's CTA — the call-to-action for CTA posts (or use the default CTA from Client Profile if one is set)

**Optional per run:**
3. Specific emphasis — topics or angles to lean into this week
4. Topics to avoid — anything to de-emphasize or skip
5. Date override — if next Monday is not the target start date
6. Speaker focus — for multi-speaker podcasts, which speaker's ideas to prioritize (defaults to the client/host)

**From Client Profile in Project Knowledge (set up once via Phase 0, not collected per-run):**
- Brand voice guidelines (tone, language patterns, terminology)
- Active platforms and platform-specific preferences
- CTA links and current offers
- Hashtag preferences per platform
- Branded frameworks and proprietary terminology
- Past post examples the client liked
- Date format preference (default: DD MMM YYYY)
- Spelling convention (e.g., British English, American English)
- Content structure preferences
- Delivery preferences (Google Doc, artifact, etc.)

See [client-profile-template.md](references/client-profile-template.md) for the full profile structure.

**Rules:**
- If no Client Profile exists in Project Knowledge, run Phase 0 before doing anything else
- If a Client Profile exists and source content + CTA are both provided, begin immediately — no confirmation needed
- If the Client Profile has a default CTA and the user doesn't provide one, use the default
- If source content is provided without a CTA and no default exists in the profile, ask for the CTA before proceeding
- Do NOT ask clarifying questions that the source content or Client Profile already answers
- Only generate content for platforms marked active in the Client Profile
- Auto-detect source type (newsletter vs. podcast transcript) from the content. Signals for transcript: speaker labels, conversational turns, timestamps, filler words, spoken cadence. If ambiguous, ask.

---

## PHASE 0 — CLIENT ONBOARDING

**When to run:** First invocation only — when no Client Profile or strategy document can be found anywhere.

**Before triggering onboarding, search everywhere:**
1. Project Knowledge — look for a Client Profile, brand voice guide, or content strategy document
2. Working directory — list all files in the current working directory and any subdirectories. Look for strategy docs, voice guides, or anything with "strategy," "voice," "brand," "content," "repurpos," or "profile" in the filename
3. CoWork working directory — if running in CoWork, also check the CoWork workspace/sandbox directory for files the user may have placed there
4. Conversation context — check if the user has already uploaded or pasted a strategy document earlier in this conversation

**Search thoroughly.** Run `ls` or equivalent on the working directory. Read any file that looks like it could be a strategy or profile document. Do not skip this step — the document may already be sitting right there. Note: podcast transcripts are source content, not strategy docs — don't confuse a transcript with a profile/strategy document.

If you find ANY document that contains brand voice, content strategy, platform rules, or CTA information — treat it as the Client Profile and skip to Phase 1. It doesn't need to be named "Client Profile" or follow the template format. A comprehensive strategy document serves the same purpose.

**Skip if:** A Client Profile, strategy document, or brand guide already exists in any of the locations above, even if incomplete. Incomplete profiles are handled by the refinement mechanic in Phase 2, not by re-running onboarding.

### Step 1 — Ask for existing documents

Before asking any questions, ask the client to upload whatever they already have:

> "Before we start repurposing, I want to make sure I nail your brand voice and style. Do you have any of these you can upload or paste in?"
> - Brand voice guide or style guide
> - Content strategy document
> - Social media guidelines
> - Examples of posts you love (yours or others')
> - Any other document that captures how you communicate
>
> "Drop whatever you have — even rough notes help. I'll read through everything and only ask about what's missing."

Wait for the client to upload/paste documents or confirm they have nothing.

### Step 2 — Audit against the profile template

Read everything the client provided. Map what's covered against the Client Profile structure in [client-profile-template.md](references/client-profile-template.md). Categorise every field as:

- **Covered** — the uploaded docs clearly answer this
- **Partially covered** — some signal but needs clarification
- **Missing** — not addressed at all

### Step 3 — Interview for gaps

For missing and partially covered fields, ask focused questions. Group related questions together — do not ask one question at a time. Prioritise:

**Must-have (ask immediately):**
1. Brand voice — tone, language patterns, what to avoid (if not covered by uploaded docs)
2. Active platforms — which platforms they actually use
3. Spelling convention
4. Primary CTA and link

**Important (ask in the same pass if possible):**
5. Branded frameworks and proprietary terminology
6. Hashtag preferences
7. Platform-specific preferences (emoji rules, CTA style, etc.)

**Nice-to-have (ask only if the conversation is flowing):**
8. Content structure preferences
9. Date format
10. Google Drive folder for output

Frame questions naturally — not as a form, but as a conversation. Use what you learned from their uploaded docs to make questions specific. For example, if their voice guide says "authoritative but warm," don't ask about tone — ask about the boundary: "Your guide says authoritative but warm — when those two conflict, which wins? Like if a topic calls for a strong opinion, do you soften it or let it land hard?"

### Step 4 — Generate and present the Client Profile

Assemble everything into a completed Client Profile document following the structure in [client-profile-template.md](references/client-profile-template.md). Present it to the client:

> "Here's your Client Profile based on what you shared. This is what I'll use every time I repurpose content for you. Take a look — anything to adjust?"

Once confirmed, instruct the client to save the profile to Project Knowledge:

> "To make this profile available every session: copy the profile above, go to your Project settings, and paste it into Project Knowledge (or click the message and use 'Save to Project Knowledge' if available). That way you just paste your content and I handle the rest."

After the profile is saved (or if the client confirms they'll save it later), proceed to Phase 1 with the source content they originally provided.

---

## PHASE 1 — PARSE SOURCE CONTENT

Read the full source content and extract a structured content map. This extraction is the foundation every platform draws from.

**Source type detection:** Identify whether the input is a newsletter or podcast transcript. Transcripts typically have speaker labels (e.g., "Host:", "Guest:", "[Speaker 1]"), conversational turns, timestamps, and spoken-language patterns. Newsletters are structured prose with headers, sections, and edited language.

**For newsletters:** Follow the standard extraction methodology in [content-extraction.md](references/content-extraction.md).

**For podcast transcripts:** Follow the transcript-specific extraction methodology in [content-extraction.md](references/content-extraction.md) (Transcript Extraction section). Key differences: identify speakers, extract conversational gold (natural phrasing that sounds authentic on social), handle longer/looser source material, and clean spoken language for readability.

Skip reading content-extraction.md if a comprehensive strategy doc already defines the parsing approach.

---

## PHASE 2 — LOAD BRAND CONTEXT

Read the Client Profile from Project Knowledge. This is the single source of truth for brand voice, active platforms, CTAs, hashtag rules, terminology, and all client-specific preferences. Apply it as overrides to the platform defaults in the reference files.

**What to load from the Client Profile:**
- Voice/tone guidelines and language patterns
- Active platforms (only generate content for these)
- CTA templates and default CTA
- Hashtag rules per platform
- Branded frameworks and proprietary terminology
- Spelling and formatting conventions
- Content structure and delivery preferences

If no Client Profile exists, you should have caught this before reaching Phase 2 — go back and run Phase 0.

### Profile Refinement (periodic, not every run)

After loading the Client Profile, check whether it's been a while since you last asked a refinement question. The goal is to deepen and evolve the profile over time without being annoying.

**Trigger:** Check the "Last updated" date on the Client Profile. If it's more than 2-3 weeks old, ask **one** focused question. Not a checklist — a single, specific question that builds on what you've observed. If there's no date, ask one question and add the date when you update the profile.

**What to ask about (rotate through these):**
- Posts they got good engagement on recently — "Any posts land particularly well since last time? I can adjust the style based on what's working."
- Evolved preferences — "Still happy with [specific aspect of the profile], or has your thinking shifted?"
- New campaigns, offers, or CTAs — "Any new offers or links I should be using?"
- Gaps you've noticed — if a profile field is empty or vague, ask specifically about it
- Feedback on past output — "Anything in recent batches you'd change? Tone too strong, too soft, missing something?"

**Rules:**
- Never ask more than 1-2 questions in a refinement check
- If the client gives you new information, update the Client Profile document and tell them: "I've updated your profile with that — it'll carry forward."
- If the client says "just get on with it" or similar, skip and don't ask again for several runs
- Refinement is conversational, not procedural — weave it in naturally before you start generating

---

## PHASE 3 — TITLE OPTIONS

Generate title options using different engagement strategies. Default: 4 options, or as specified by the Client Profile/strategy doc.

**For newsletters:** These are newsletter subject line / title options. For full methodology, read [title-generation.md](references/title-generation.md).

**For podcast transcripts:** These are episode title or social series title options — a punchy title for the content batch that could double as an episode title if the client doesn't already have one. Same methodology (curiosity, specificity, engagement strategies) but framed for the episode's core theme rather than a newsletter subject line.

Skip reading title-generation.md if a comprehensive strategy doc already defines title generation rules.

---

## PHASE 4 — LINKEDIN CONTENT

Generate 5 days (Monday-Friday) of LinkedIn content: 2 posts per day (1 Thought Post + 1 CTA Post). Produces 10 posts total. Each Thought Post opens with a scroll-stopping hook and builds authority — no selling. Each CTA Post transitions naturally into the weekly CTA and ends with "Link in first comment." Day-by-day variety follows a theme rotation (case study → framework → contrarian → how-to → big-picture). Professional authority tone — peer-level, never talks down.

For full platform rules, formatting, and templates, read [linkedin-rules.md](references/linkedin-rules.md) — unless a comprehensive strategy doc already defines LinkedIn rules.

---

## PHASE 5 — INSTAGRAM CONTENT

Generate 5 days (Monday-Friday) of Instagram content: 1 Thought Post per day. Produces 5 posts total. No CTAs or links — Instagram doesn't support clickable links in captions. First 125 characters must be a compelling standalone hook (pre-"...more" truncation). Each post is 150-300 words with 10-15 varied hashtags and an engagement prompt instead of a CTA. Tone is slightly more conversational than LinkedIn.

For full platform rules, hook optimization, and hashtag strategy, read [instagram-rules.md](references/instagram-rules.md) — unless a comprehensive strategy doc already defines Instagram rules.

---

## PHASE 6 — FACEBOOK CONTENT

Generate 5 days (Monday-Friday) of Facebook content: 2 posts per day (1 Thought Post + 1 CTA Post). Produces 10 posts total. Hook must land within ~480 characters (pre-"See More" truncation). Tone is warmer and more community-oriented than LinkedIn — same substance, warmer delivery. Thought Posts end with discussion prompts. CTA Posts end with the weekly CTA + "Link in first comment." No hashtags by default.

For full platform rules, tone differentiation, and templates, read [facebook-rules.md](references/facebook-rules.md) — unless a comprehensive strategy doc already defines Facebook rules.

---

## PHASE 7 — SUBSTACK NOTES

Generate 5 days (Monday-Friday) of Substack Notes: 1 standalone note per day. Produces 5 notes total. Ultra-short: 50-150 words, non-negotiable. Each note must work completely standalone — no references to the source content (no "in this week's newsletter" or "on the podcast"). These are value drops, not teasers. Five format options rotate across the week: bold statement, question+answer, framework snapshot, punchline wisdom, observation+reframe. Word count must be displayed per note.

For full format options, word count rules, and variety guide, read [substack-rules.md](references/substack-rules.md) — unless a comprehensive strategy doc already defines Substack rules.

---

## PHASE 8 — CREATE GOOGLE DOC

After all platform content is generated (whether by sub-agents or sequentially), assemble everything into a single Google Doc.

The doc has one H1 section per content type/platform, in the order defined by the Client Profile's output format (or the default order in [operations.md](references/operations.md)). Try a single-shot write first (3 MCP calls). Only fall back to chunked writing if the single shot truncates. See operations.md for the full flow.

See [operations.md](references/operations.md) Section 3 for the full doc creation flow, section order, and critical rules.

**Always create a local markdown file first** as the source of truth. The Google Doc is the delivery copy for the client's team.

---

## PHASE 9 — DELIVER

**If Google Workspace MCP is available:**
The Google Doc has been created and moved to the client's content folder. Present the summary with the doc link.

**If Google Workspace MCP is unavailable:**
1. Output content as a conversation artifact
2. Explicitly tell the client: "Google Workspace isn't connected, so I couldn't create the Google Doc. Connect via Pipedream MCP to enable automatic delivery."

**After delivery, present a summary:**
- Total content pieces generated and expected count
- Platforms covered and post counts per platform
- Link to the Google Doc (or note that it's a conversation artifact)
- Any flags (missing profile fields, date assumptions, skipped steps)
- Ask: "Here's your weekly content. Want to adjust any posts, swap angles, or change the emphasis?"
- Continue revising until the client is satisfied — edits update the Google Doc directly via `google_docs-replace-text`

---

## QUALITY RULES

These rules apply to EVERY phase:

1. **Source integrity is non-negotiable.** Use ONLY content from the source (newsletter or transcript). No invented statistics, client stories, data points, frameworks, or personal anecdotes. For transcripts, the speaker's actual words are the source — even if messy, they contain the authentic ideas.
2. **Refinement is allowed.** You may tighten sentences, add line breaks, reorder for flow, remove filler words, break long sentences into fragments, and adapt structure for platform style. For podcast transcripts, you may also clean up spoken grammar, remove verbal tics, and compress meandering passages into their core point — but the idea must remain the speaker's. Refinement serves clarity. Invention serves nothing.
3. **Brand voice is consistent.** Every post across every platform should sound like the same person wrote it. Voice comes from the Client Profile — apply it uniformly.
4. **Platform constraints are absolute.** Character limits, hook lengths, hashtag rules, CTA rules — these are not suggestions. Instagram gets no links. LinkedIn gets no hashtags (unless Client Profile overrides this). Substack Notes stay under 150 words.
5. **Date calculations must be correct.** Calculate the next Monday from today's date. Add 1-4 days for Tuesday-Friday. Use the client's preferred date format (default: DD MMM YYYY). Double-check the math.
6. **Each platform is its own creative pass (default).** Write each platform's content fresh, drawing from the same content extraction but optimizing for each platform's unique constraints and audience. If the Client Profile or strategy doc specifies "write once, use across platforms," follow that instead — write unified social posts and let the client's team apply platform-specific formatting at posting time.
7. **Correct piece count.** The total depends on active platforms. Full suite (all 4 platforms) = 34 pieces: 4 title options + 10 LinkedIn + 5 Instagram + 10 Facebook + 5 Substack Notes. If fewer platforms are active, adjust the total accordingly but always produce the correct count for each active platform. State the expected total at the start of each run.
8. **Transcript-sourced content sounds conversational.** When the source is a podcast transcript, lean into the natural spoken tone. The best social content from podcasts sounds like someone talking, not someone writing about what someone said. Preserve the speaker's cadence where it works on the platform.
9. **Variety across the week.** Each day should have a different angle, theme, or approach. No two days should feel like the same post reworded. Use the day-by-day variety guides in each platform's reference file.

---

## CLIENT PROFILE SETUP

The Repurpose Content Skill uses a **Client Profile** document in Project Knowledge to tailor all content. There are two ways to set this up:

### Option 1: Run the skill and let it onboard you (recommended)
Just start using the skill. On first run, Phase 0 will:
1. Ask you to upload any existing brand/strategy documents you have
2. Read everything and identify what's covered vs. what's missing
3. Interview you for the gaps — focused questions, not a form
4. Generate a completed Client Profile for you to save to Project Knowledge

This is the easiest path. You don't need to prepare anything in advance.

### Option 2: Fill out the template yourself
If you prefer to set things up before your first run, use the template in [client-profile-template.md](references/client-profile-template.md). Fill in what you can and save it to Project Knowledge. The skill will use it immediately and ask about any blanks over time through periodic refinement questions.

### What the profile covers
See the full profile structure in [client-profile-template.md](references/client-profile-template.md).

### Profile evolution
The profile isn't static. When it hasn't been updated in a few weeks, the skill will ask a quick question to refine and update it — new CTAs, evolved preferences, what's working. You can also update the profile document directly at any time.

---

## FEEDBACK TONE

All client-facing output:
- Confident but collaborative — "here's your content, let me know what to adjust"
- Specific — reference the source content that drove each post
- Second person — "your content," "your audience"
- Professional but human — respected colleague, not corporate consultant
- Concise — present the content, not a commentary about the content
