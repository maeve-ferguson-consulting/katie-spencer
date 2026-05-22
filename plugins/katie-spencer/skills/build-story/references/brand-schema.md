# BRAND.md Schema

The `build-carousel` and `build-story` skills read brand context from a single document called `BRAND.md` that lives in the client's Claude Project Knowledge. This is that document's schema.

The matching `define-brand-voice` skill produces a `BRAND.md` in this shape via an interactive interview. This file is the contract between the two.

## Required sections

### `Brand Identity`
```yaml
name: <full brand or person name>
short_name: <one-word brand handle, used in filenames>
monogram: <1-3 letter glyphs that sit in slide headers>
tagline: <optional one-liner>
```

### `Color Bases`
At least one. Each base has a dark variant and a light variant.
```yaml
- name: <BaseName>
  dark:
    bg: "#RRGGBB"
    text: "#RRGGBB"
    accent: "#RRGGBB"
  light:
    bg: "#RRGGBB"
    text: "#RRGGBB"
    accent: "#RRGGBB"
```

### `Typography`
```yaml
heading_font: <font name>
heading_fallback: <fallback chain, e.g. "Georgia, serif">
body_font: <font name>
body_fallback: <fallback chain, e.g. "Arial, sans-serif">
label_font: <font name, optional - defaults to body_font>
weight_override: <optional - if the brand wants 700+ weights, set "allow">
fontsource_packages:
  - <npm package slug, e.g. "eb-garamond">
  - <npm package slug, e.g. "dm-sans">
```

### `Voice Rules`
```yaml
language_variant: <en-US | en-GB | other>
em_dashes: <allow | replace_with_hyphen | replace_with_comma>
emojis: <allow | none>
banned_words:
  - <word or phrase>
signature_phrases:
  - <phrase the brand reuses>
person: <first | second | third>
```

## Optional sections

### `Vision Tethers`
A list of 2-5 big ideas the brand exists to advance. Every piece of content should connect to one. Free-form.

### `Effects`
```yaml
metallic_accent: <true | false>
metallic_stops:
  - "#RRGGBB"  # darkest
  - "#RRGGBB"  # mid
  - "#RRGGBB"  # lightest
  - "#RRGGBB"  # mid
  - "#RRGGBB"  # darkest
```

### `Testimonial Bank`
Verified client quotes for T5 (Quote) slides. Verbatim - no paraphrasing.
```yaml
- quote: "<exact words>"
  attribution: "<name>"
  title: "<role/title>"
```

### `Offer Bank`
Canonical list of offers the brand pulls readers toward.
```yaml
- name: <Offer name>
  one_liner: <one-line description>
  url: <landing page if applicable>
```

## Provisional markers

A required section can be structurally complete but hold *starter defaults*, not the client's real brand — e.g. `define-brand-voice` filled a neutral palette or a default font pair because the user had nothing yet and chose not to be blocked. Such a section carries a single HTML-comment marker between its heading and its ```yaml fence:

```
### `Color Bases`
<!-- PROVISIONAL: starter default, not the client's real palette — replace before relying on output -->
```yaml
...
```

**Contract:**
- The marker is a line matching the prefix `<!-- PROVISIONAL` located after a section's `### \`Heading\`` and before that section's first ```yaml fence.
- `define-brand-voice` emits it on any required section it fills with default/starter values, and removes it the moment the user supplies real values for that section.
- A consuming skill that finds a required section marked PROVISIONAL must NOT silently proceed. It treats the section as present-but-placeholder: warn the user plainly that output will look generic until real values are set, and offer to proceed anyway only on explicit confirmation. This is distinct from a missing/empty required section, which is still a hard stop.

## How the skill parses this

Both skills look for `BRAND.md` in the conversation context (injected from Claude Project Knowledge). The first occurrence of each section heading is the source of truth. If a required section is missing or its body is empty, the skill stops and invokes `define-brand-voice`. If a required section is present but marked PROVISIONAL (see above), the skill soft-stops: warn and offer render-anyway, do not proceed silently.

Hex colors are validated as `#RRGGBB`. Font names are looked up against installed fonts; missing fonts fall back to the declared fallback chain.
