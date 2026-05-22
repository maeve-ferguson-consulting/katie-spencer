<!--
WORKED EXAMPLE — not a default. Loosely based on a real consulting brand,
rewritten with [Speaker] and [Company] tokens to make clear this is an
illustration of a fully-populated BRAND.md, not a starting point for any
new client.

This file conforms to references/brand-schema.md — the same contract
build-carousel and build-story parse. Calling skills can read this to see
the exact shape a complete BRAND.md takes.
-->

# BRAND — [Company]

The canonical brand context for this Claude Project. Conforms to `references/brand-schema.md`.

---

### `Brand Identity`

```yaml
name: "[Speaker]"
short_name: "[company]"
monogram: "SP"
tagline: "Engineering proven expertise into infrastructure that outlasts the algorithm"
```

---

### `Color Bases`

```yaml
- name: "Forest"
  dark:
    bg: "#223734"
    text: "#F5F5DA"
    accent: "#F5DEA7"
  light:
    bg: "#F5F5DA"
    text: "#1B1B1B"
    accent: "#C4A44E"
- name: "Noir"
  dark:
    bg: "#1B1B1B"
    text: "#F5F5DA"
    accent: "#F5DEA7"
  light:
    bg: "#F5F5DA"
    text: "#1B1B1B"
    accent: "#C4A44E"
```

---

### `Typography`

```yaml
heading_font: "EB Garamond"
heading_fallback: "Georgia, serif"
body_font: "DM Sans"
body_fallback: "Arial, sans-serif"
label_font: "DM Sans"
weight_override: ""
fontsource_packages:
  - "eb-garamond"
  - "dm-sans"
```

---

### `Voice Rules`

```yaml
language_variant: "en-GB"
em_dashes: "replace_with_comma"
emojis: "none"
banned_words:
  - "leverage"
  - "synergy"
  - "unlock potential"
  - "game-changing"
  - "in today's fast-paced world"
  - "let's dive in"
  - "quiz funnel"
signature_phrases:
  - "Data is the only moat"
  - "Infrastructure, not tactics"
  - "From respected but replaceable to Category of One"
  - "The diagnostic is the mechanism. The data is the asset."
person: "second"
```

---

### `Vision Tethers`

- **The Great IP-to-Data Transition** — the most valuable asset in a knowledge business is no longer intellectual property, it is proprietary first-party data. Every piece traces back to this shift.
- **Infrastructure, not tactics** — permanent infrastructure that compounds over years, never campaigns that expire.
- **Data is the only moat** — the moat that survives AI; leads are the byproduct, the data is the asset.
- **From respected to Category of One** — moving the speaker from one option among many to the reference point an industry is measured against.
- **Legacy that outlives the algorithm** — engineering permanence in a world built for impermanence; answer to a 10-year horizon.

---

### `Effects`

```yaml
metallic_accent: true
metallic_stops:
  - "#8A6D1F"
  - "#C4A44E"
  - "#F5DEA7"
  - "#C4A44E"
  - "#8A6D1F"
```

---

### `Testimonial Bank`

```yaml
- quote: "She rebuilt our entire authority engine in fifteen days. I have never worked with anyone who sees the whole board like this."
  attribution: "[Client A]"
  title: "#1 NYT bestselling author"
- quote: "The data asset alone changed our exit conversation. We did not know we were sitting on it."
  attribution: "[Client B]"
  title: "Founder, nine-figure platform"
```

---

### `Offer Bank`

```yaml
- name: "Authority Scan"
  one_liner: "1-day intensive — IP extraction, positioning brief, diagnostic blueprint, 90-day roadmap"
  url: "https://example.com/authority-scan"
- name: "IP-to-Diagnostic Intensive"
  one_liner: "60-day done-for-you build — full diagnostic infrastructure, routing, alerts"
  url: "https://example.com/intensive"
- name: "Authority Architect"
  one_liner: "12-month complete build — diagnostic + intelligence engine + data partnership"
  url: "https://example.com/architect"
```

---

<!-- ============================================================
     ENRICHMENT SECTIONS — consumed by non-builder skills.
     ============================================================ -->

### `Voice Texture`

**Voice summary:** Intense, magnetic, authoritative. Fun, intriguing, smart. Controlled, not chaotic. High energy delivered with precision.

**Stance toward the reader:** Peer. Talks to people who are already authorities and treats them as authorities who haven't yet seen the next layer.

**Allowed stylistic moves:** One-sentence paragraphs. Direct rhetorical questions. Sentence fragments for emphasis. (Em-dashes are banned here — see Voice Rules — but other brands keep them; this is per-brand.)

**On-brand example:**
> The knowledge economy has collapsed. Not slowly eroding. Collapsed. The natural response was to rush to AI. But the moment you load your IP into a GPT, it is no longer proprietary. You gave away everything you built and got nothing back.

**Off-brand example (and why):**
> In today's fast-paced AI landscape, it's important to leverage your proprietary data to unlock new growth opportunities. — every AI-tell phrase in one sentence; sounds like everyone, not like this brand.

---

### `Audience`

**Primary:** Established authorities aged 40–70 with proven methodology that isn't systematised. Authors, consultants, keynote speakers, executives. $500K–$50M+ revenue. Already has audience, IP, credibility. Feels they should be further ahead given what they've built.

**Exclude:** Anyone without an established audience. Anyone "building a personal brand." Beginners. Anyone who negotiates on price before understanding value.

**Their language:** "My IP only works when I'm present." "I'm the bottleneck in my own business." "There has to be a smarter way than explaining myself repeatedly."

---

### `Reference Library`

**Named concepts:** The Data Funnel — infrastructure that captures proprietary first-party data; leads are a byproduct. The Three Forces — knowledge-economy collapse, AI Saviour Trap, insatiable data demand.

**Signature stories:** The hospital data deal — $100M paid for patient data, used to anchor what an engaged audience's structured data is worth. The 15-day delivery — proof of premium speed without quality loss.

**Proof points:** 23% reduction in 30-day readmissions (verified). 100+ data points captured per assessment completion.
