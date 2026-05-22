<!--
BRAND.md — the single brand-context document every other skill reads.

This file conforms to references/brand-schema.md, the contract shared with
build-carousel, build-story, and any future build-* skill. Keep them in sync.

HOW SKILLS READ THIS FILE
- A builder skill looks for the four REQUIRED sections by their exact heading
  (### `Brand Identity`, ### `Color Bases`, ### `Typography`, ### `Voice
  Rules`). The first occurrence of each heading wins. If a required section is
  missing OR its body is empty, the builder stops and tells the user to run
  define-brand-voice. It will NOT substitute its own defaults.
- Therefore define-brand-voice must NEVER leave a required section empty. On
  the fastest possible pass it still fills all four with at least a sensible,
  user-acknowledged starter value (marked DEFAULT) so the user is never dead-
  ended. DEFAULT values are honest placeholders the user agreed to, not the
  builder silently faking a brand.
- OPTIONAL sections and the richer ENRICHMENT sections can be absent or grow
  over multiple sessions. Empty optional sections never block a build.

TIERS
- REQUIRED  → must always be present and non-empty (the build-unblocking minimum)
- OPTIONAL  → improves output; safe to omit or fill later
- ENRICHMENT→ define-brand-voice extras consumed by non-builder skills
              (newsletter, repurposing, etc.); never block a build
-->

# BRAND

The canonical brand context for this Claude Project. Conforms to `references/brand-schema.md`.

---

### `Brand Identity`

<!-- TIER: REQUIRED — never leave empty -->
```yaml
name: ""              # full brand or person name
short_name: ""        # one-word handle, used in filenames
monogram: ""          # 1-3 letter glyphs for slide headers (e.g. "MR")
tagline: ""           # optional one-liner
```

---

### `Color Bases`

<!-- TIER: REQUIRED — at least one base, dark + light variants, valid #RRGGBB.
     If the user has no palette, offer the neutral starter below as a DEFAULT
     they accept, so the build is never blocked. Replace on a later pass.
     KEEP the PROVISIONAL marker below while these are defaults; REMOVE it the
     moment the user supplies a real palette. -->
<!-- PROVISIONAL: starter default, not the client's real palette — replace before relying on output -->
```yaml
- name: "Default"     # DEFAULT starter — replace once the real palette exists
  dark:
    bg: "#1A1A1A"
    text: "#F5F5F0"
    accent: "#C9A227"
  light:
    bg: "#F5F5F0"
    text: "#1A1A1A"
    accent: "#C9A227"
```

---

### `Typography`

<!-- TIER: REQUIRED. If the user doesn't know, the DEFAULT below is a safe,
     widely-available serif/sans pair the user accepts to stay unblocked.
     KEEP the PROVISIONAL marker below while these are defaults; REMOVE it the
     moment the user supplies real fonts. -->
<!-- PROVISIONAL: starter default fonts, not the client's real typography — replace before relying on output -->
```yaml
heading_font: "EB Garamond"          # DEFAULT — replace with the real heading font
heading_fallback: "Georgia, serif"
body_font: "Inter"                   # DEFAULT — replace with the real body font
body_fallback: "Arial, sans-serif"
label_font: ""                       # optional; defaults to body_font
weight_override: ""                  # "allow" only if the brand wants 700+ weights
fontsource_packages:
  - "eb-garamond"
  - "inter"
```

---

### `Voice Rules`

<!-- TIER: REQUIRED. Defaults below are safe and neutral; the user confirms or
     overrides. banned_words / signature_phrases may start empty and grow. -->
```yaml
language_variant: "en-US"            # en-US | en-GB | other
em_dashes: "allow"                   # allow | replace_with_hyphen | replace_with_comma
emojis: "none"                       # allow | none
banned_words: []                     # grows over sessions
signature_phrases: []                # grows over sessions
person: "second"                     # first | second | third
```

---

### `Vision Tethers`

<!-- TIER: OPTIONAL — 2-5 big ideas every piece should connect to. Free-form.
     Safe to omit on the first pass; add as the worldview crystallises. -->

*empty: run /define-brand-voice section=vision*

---

### `Effects`

<!-- TIER: OPTIONAL — visual flourishes for builders. Omit unless wanted. -->
```yaml
metallic_accent: false
metallic_stops: []
```

---

### `Testimonial Bank`

<!-- TIER: OPTIONAL — verbatim verified client quotes, no paraphrasing.
     Skip until real quotes exist; empty is better than invented. -->

*empty: run /define-brand-voice section=testimonials*

---

### `Offer Bank`

<!-- TIER: OPTIONAL — canonical offers content can pull readers toward. -->

*empty: run /define-brand-voice section=offers*

---

<!-- ============================================================
     ENRICHMENT SECTIONS — define-brand-voice extras.
     Consumed by non-builder skills (newsletter, repurposing,
     copywriting). Never required; never block a build. Grow over time.
     ============================================================ -->

### `Voice Texture`

<!-- TIER: ENRICHMENT — the human feel of the voice for content skills. -->

**Voice summary:** *three lines on how the brand sounds*

**Stance toward the reader:** *peer | teacher | provocateur | mentor | insider*

**Allowed stylistic moves:** *punctuation/patterns to keep even if flagged as AI-tells*

**On-brand example:**
> *to be filled*

**Off-brand example (and why):**
> *to be filled* — *why it's off*

---

### `Audience`

<!-- TIER: ENRICHMENT — who the content is for; used by copy/newsletter skills. -->

**Primary:** *one paragraph — role, stage, what they're wrestling with*

**Exclude:** *the wrong-fit reader to repel*

**Their language:** *phrases they use about their own situation*

---

### `Reference Library`

<!-- TIER: ENRICHMENT — named frameworks, signature stories, influences,
     reusable proof points. Skip until they exist; empty beats invented. -->

**Named concepts:** *name — one-line definition*

**Signature stories:** *title — one-line summary*

**Proof points:** *reusable stats/results — skip until you have real numbers*
