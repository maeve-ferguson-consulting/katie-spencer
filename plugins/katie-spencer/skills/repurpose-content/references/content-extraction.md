# Content Extraction — Phase 1 Methodology

Parse the source content (newsletter or podcast transcript) and produce a structured content map. Every platform generation phase draws from this extraction — it is the single source of truth for what content exists in the source.

**Source types:** This methodology covers two input types. Newsletters follow the standard extraction process below. Podcast transcripts follow the additional Transcript Extraction section at the end of this document — read both sections for transcripts, as the standard categories still apply but the extraction approach differs.

---

## Standard Extraction Process (Newsletters)

Read the full newsletter text and identify:

### 1. Core Theme

The overarching subject or argument of the newsletter. One sentence.

### 2. Key Insights

3-7 distinct ideas, arguments, or observations. For each:
- **Insight:** The idea in one sentence
- **Supporting text:** The exact phrases or sentences from the newsletter that express this insight
- **Strength:** Is this backed by data, story, logic, or authority?

### 3. Quotable Phrases

Exact sentences or fragments that are punchy, memorable, or hook-worthy. These become post openings, Substack Notes, or Instagram hooks. Pull 8-12 of these.

Criteria for a quotable phrase:
- Could stand alone as a social post opener
- Provokes thought, challenges assumptions, or states a truth sharply
- Uses the author's natural voice (not generic business language)

### 4. Data Points and Specifics

Any numbers, statistics, revenue figures, percentages, timeframes, or concrete results mentioned. List each with its exact context from the newsletter.

**Critical:** Only extract data points that actually appear in the newsletter. Never round, estimate, or infer numbers.

### 5. Stories and Examples

Client stories, case studies, personal anecdotes, or illustrative examples. For each:
- **Summary:** What happened (1-2 sentences)
- **Key detail:** The specific, concrete detail that makes it credible
- **Lesson:** What it demonstrates

### 6. Frameworks and Models

Any named frameworks, step-by-step processes, mental models, or structured approaches mentioned. Include the exact name and components as stated in the newsletter.

### 7. CTAs and Offers

Any calls-to-action, offers, invitations, or next steps mentioned in the newsletter itself (separate from the weekly CTA the user provides).

### 8. Emotional Hooks

Moments of vulnerability, bold claims, contrarian takes, or emotionally resonant language. These are high-value for social content because they stop the scroll.

---

## Output Format

Structure the extraction as a content map:

```
NEWSLETTER CONTENT MAP

Core Theme: [one sentence]

Key Insights:
1. [Insight] — supported by: "[exact text]"
2. [Insight] — supported by: "[exact text]"
[etc.]

Quotable Phrases:
- "[exact phrase]"
- "[exact phrase]"
[etc.]

Data Points:
- [number/stat]: "[exact context from newsletter]"
[etc.]

Stories/Examples:
- [Summary] — Key detail: [detail] — Lesson: [lesson]
[etc.]

Frameworks:
- [Name]: [components as stated]
[etc.]

Newsletter CTAs:
- [CTA text]
[etc.]

Emotional Hooks:
- "[exact text]" — Type: [vulnerability / bold claim / contrarian / emotional]
[etc.]
```

---

## Extraction Rules

1. **Exact text only.** Quotable phrases and supporting text must be verbatim from the source. You may trim filler words but not change meaning. For transcripts, light grammar cleanup is allowed (see Transcript Extraction rules).
2. **Comprehensive but not exhaustive.** Capture everything that could become social content. Skip purely transitional or administrative text (e.g., "In this week's newsletter..." or email footer content). For transcripts, skip small talk, housekeeping, and ad reads.
3. **Categorize accurately.** A data point is a data point, not an insight. A story is a story, not a framework. Proper categorization makes platform generation faster and more accurate.
4. **Flag thin sources.** If the source has fewer than 3 insights or fewer than 5 quotable phrases, flag it: "This source has limited material. Some posts may feel repetitive across platforms. Consider supplementing with the client's recent content or asking for additional talking points."
5. **Preserve specificity.** "We generated $605,000 in pipeline" is better than "we generated significant revenue." Keep the specific language.

---

## Transcript Extraction (Podcasts)

When the source is a podcast transcript, the same content map categories apply (Core Theme, Key Insights, Quotable Phrases, etc.) but the extraction approach changes to handle conversational, multi-speaker, longer-form content.

### Pre-Processing

Before extracting, do a quick structural pass:

1. **Identify speakers.** Note who is speaking — host vs. guest(s). If speaker labels aren't present, infer from context (the person asking questions is usually the host).
2. **Identify the client.** The client is usually the host. If the client is a guest on someone else's podcast, their ideas get priority — the host's questions provide context but aren't source material for content.
3. **Mark the meat.** Podcasts have warm-up, transitions, and wind-down. Skim for the substantive segments where ideas, stories, and frameworks surface. Typical structure: intro/banter (skip) → topic 1 → topic 2 → ... → wrap-up/plugs (skip CTA language, keep final insights).
4. **Note timestamps** if present — useful for the client to reference back to the episode.

### Transcript-Specific Extraction Adjustments

**Core Theme:** Podcasts often cover 2-3 topics. If there's a clear throughline, name it. If topics are distinct, name the dominant one and list the others as secondary themes.

**Key Insights:** Conversations surface insights gradually — a speaker may circle back to the same idea multiple times, adding nuance each pass. Synthesize these into the clearest expression of the insight, but note which speaker said it. Attribution matters for brand voice.

**Quotable Phrases:** Spoken language produces two kinds of quotable material:
- **Polished soundbites** — moments where the speaker lands a clean, punchy line. These are gold. Extract verbatim.
- **Raw gems** — ideas expressed well but with spoken-language roughness (false starts, filler, run-on phrasing). Extract the core phrasing and lightly clean for readability. Mark these as `[cleaned]` in the extraction so you know refinement happened.

Pull 10-15 quotable phrases (transcripts are longer, so aim higher than newsletters).

**Stories and Examples:** Podcasts are story-rich. Conversations naturally prompt "tell me about a time when..." moments. Capture these even if they meander — the story structure might need compression for social, but the raw material is there.

**Data Points:** Speakers often cite numbers loosely in conversation ("around 600K" vs. "exactly $605,000"). Extract as spoken — do NOT sharpen vague numbers into precise ones. If a number sounds approximate, preserve that ("~600K" not "$600,000").

**Frameworks:** Speakers sometimes articulate frameworks conversationally ("I think about it in three buckets..."). Capture the framework even if it's not formally named — the platform content can formalize the structure.

**Emotional Hooks:** Conversations produce raw, unfiltered moments — vulnerability, frustration, excitement — that written content rarely captures. These are the highest-value extraction targets for social content. A speaker saying "honestly, I almost quit that week" hits harder than any crafted hook.

### Transcript Content Map Additions

Add these fields to the standard content map when the source is a transcript:

```
Source Type: Podcast Transcript
Episode: [title if known]
Speakers: [Host: name] / [Guest(s): name(s)]
Primary Speaker (for content): [name]
Episode Length: [approximate duration if timestamps present]
Secondary Themes: [if the episode covers multiple distinct topics]
```

### Transcript Extraction Rules (supplement to standard rules)

1. **Clean for readability, not for polish.** Remove "um," "uh," "like," "you know," false starts, and repeated words. Tighten run-on sentences. But keep the speaker's natural cadence — don't turn spoken language into essay prose.
2. **Attribute insights.** Tag each insight and quotable phrase with the speaker. When the client is the host and a guest says something brilliant, that's guest IP — the client can share it with attribution ("As [guest] said on the show...") but shouldn't present it as their own.
3. **Compress, don't cherry-pick.** A speaker might take 200 words to make a point that lands in 30. Compress the passage to its essence, but make sure the compressed version is faithful to the full argument — don't extract a sentence that sounds good out of context but misrepresents the speaker's actual position.
4. **Flag rich episodes.** If the transcript yields more than 7 key insights and 15+ quotable phrases, note: "This episode is content-rich. Consider splitting across two weeks or selecting a theme to focus this week's content on."
5. **Prefer dialogue moments.** The back-and-forth between speakers often produces the most engaging social content — "When [guest] said X, it clicked for me that Y" is more compelling than a monologue excerpt. Capture these exchanges.
