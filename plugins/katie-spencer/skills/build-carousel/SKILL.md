---
name: build-carousel
description: "Render Instagram, Facebook, and LinkedIn carousel slides as actual 1080x1350 PNG image files (plus a LinkedIn PDF). Trigger any time the user wants carousel slides BUILT, MADE, RENDERED, DESIGNED, GENERATED, CREATED, or RE-RENDERED as image files - whether this week's batch, a single post, or a redesign of last week's slides with new colors, lighter/darker backgrounds, swapped photos, a different color base, or updated brand assets. Trigger on /carousel-build, /buildcarousel, /carousels, and on phrasings like 'build the carousels', 'make the carousel slides', 'design the slides', 'render the Tuesday/Thursday carousels', 'turn this into IG/FB/LinkedIn carousels', 'carousel PNGs', or any request paired with carousel text, a DM keyword, a photo zip, or brand kit in Project Knowledge. Reads brand colors, fonts, monogram from a BRAND.md. NOT for writing carousel copy from scratch, single quote graphics, logos, flyers, or conceptual questions about carousels or platform choice."
---

# BUILD CAROUSEL

Universal carousel builder. Produces 1080x1350 PNG slide sets in the client's brand, ready to post to Instagram, Facebook, and LinkedIn.

## How this skill reads brand context

This skill is brand-agnostic. Every brand decision (colors, fonts, monogram, voice rules, vision tethers) is read at runtime from a document called `BRAND.md` placed in the client's Claude Project Knowledge. The skill expects the schema documented in `references/brand-schema.md`.

If `BRAND.md` is missing or incomplete, the skill MUST stop and invoke the `define-brand-voice` skill to walk the user through capturing it. Never substitute defaults - shipping carousels in a different brand than the client's is worse than shipping nothing.

## BRAND.md is a living document - help the user elaborate it

This skill expects the user to refine `BRAND.md` over time as they see real outputs. After every render, surface ONE specific elaboration prompt - something concrete the user could improve in BRAND.md based on what they just saw. Examples:

- "I noticed slide 4's punchline used 'leverage' - you have it in your banned_words. Want to add it to signature_phrases to override, or rephrase?"
- "The Forest base looked muted on slide 7's photo. Want to try the Editorial base next batch, or tweak the dark.bg hex?"
- "Slide 9's quote isn't in your Testimonial Bank - I had to flag that. Want to add a real testimonial verbatim?"
- "Slide 3 didn't tether to any Vision Tether on my soft-check. Want to add a new tether or revise the slide?"

This is not the same as the eval step. It's a single concrete editing prompt the user can act on in 30 seconds, framed as "here's how to make this more yours next time." The skill should NEVER edit BRAND.md itself - it surfaces the suggestion and the user decides.

When the user signals they want to make changes (e.g., "edit BRAND.md", "elaborate the brand", "make this more me"), the skill should hand off to whatever tool they use to edit Project Knowledge - never overwrite their canonical brand doc programmatically.

---

## PRECHECK (run before anything else)

1. Look for a `BRAND.md` document in the conversation context (it will be injected from Claude Project Knowledge when the user has it set up).
2. Verify the required sections exist:
   - `Brand Identity` (name, monogram letters)
   - `Color Bases` (at least one base with dark + light variant + accent)
   - `Typography` (heading_font, body_font, font fallbacks)
   - `Voice Rules` (language variant, em-dash policy)
3. If any required section is missing or empty, stop and tell the user this, in your own words:
   - The build can't proceed without their brand context.
   - Their next step is to run the `define-brand-voice` skill (a separate ~15-minute brand-capture interview) and save the resulting `BRAND.md` to their Claude Project Knowledge.
   - Once that's in place, they can come back and re-run the same prompt - their slide text will be preserved so they don't need to re-paste it.
   - Do NOT silently substitute defaults. Do NOT chain-invoke `define-brand-voice` automatically - tell the user it's their next step.
4. If a required section is present but marked PROVISIONAL (a `<!-- PROVISIONAL: ... -->` comment between its heading and its yaml fence - see `references/brand-schema.md`), do NOT silently proceed. The section holds starter defaults, not the client's real brand. Tell the user, in your own words:
   - Which required section(s) are still placeholder defaults (e.g. Color Bases, Typography), and that the build will therefore look generic, not like their brand.
   - To get real on-brand output, the fix is to run `define-brand-voice` again and set those values, then re-run - their slide text is preserved.
   - If they explicitly say to proceed anyway ("render it anyway", "I know, just do it"), proceed using the placeholder values. Otherwise stop here. Do NOT chain-invoke `define-brand-voice` automatically.
5. If all required sections are present and none are PROVISIONAL, proceed.

---

## TRIGGER

Activates on: `/carousel-build`, `/buildcarousel`, `/carousels`, "build the carousels", "build the carousel slides", "create the carousel images", "make the carousels", "turn these into slides", or any request to turn carousel text into branded visual slides.

---

## FONT INSTALLATION (run once per session)

The skill installs whichever fonts the client's `BRAND.md` lists under `Typography`. Default fallback chain if a font isn't available: serif headings fall back to Georgia, sans labels fall back to Arial.

```bash
# This block is templated - it pulls font names from BRAND.md.
# Common Google Fonts via @fontsource. Adjust per BRAND.md.
cd /tmp
# For each font listed in BRAND.md > Typography:
#   npm pack @fontsource/<font-slug>
#   tar xzf fontsource-<font-slug>-*.tgz
#   install woff2 -> ttf via fonttools and copy to /usr/share/fonts/truetype/
pip install fonttools brotli --break-system-packages -q 2>/dev/null
```

After install, verify by rendering a test slide. If text renders in fallback (Georgia/Arial), fonts didn't install - retry or proceed with fallback only after telling the user.

---

## GENERATION SEQUENCE

### Step 1: Install fonts (per BRAND.md > Typography)

### Step 2: Collect inputs

**a)** "Paste the carousel text (slides + caption). Which post day is this for?"

**b)** "Which color base from your brand? Options from BRAND.md: [list bases]. Or 'auto' to pick based on content tone."

**c) Photo library:**
"Upload your photo library zip. I'll extract, catalogue by orientation, and auto-select photos for image slides."

If no zip uploaded, ask: "Upload 1-2 individual photos, or paste image URLs."

**Photo-placeholder mode (when the user wants to plan now, swap photos later):**
If the user explicitly says they want to plan the carousel now and add photos later, OR if they don't respond to the photo-library ask within the same turn, switch to placeholder mode:
- Build the full HTML for every slide, including photo slides (T7, T8, T9)
- Wherever a photo would go, render a placeholder block: solid dark variant background with a small label "PHOTO PLACEHOLDER: [orientation] - swap before publish"
- In the final summary, list every placeholder slide so the user has a punchlist of photos to upload before they ship
- Don't stop the build over missing photos - the user can iterate

**Photo zip extraction (run once per session):**
```bash
mkdir -p /home/claude/photos
for f in /mnt/user-data/uploads/*.zip; do
  unzip -o -q "$f" -d /home/claude/photos 2>/dev/null
done
```

Then catalogue:
```python
from PIL import Image
import os, glob, json
photos = sorted(glob.glob('/home/claude/photos/**/*.jpg', recursive=True) +
                glob.glob('/home/claude/photos/**/*.jpeg', recursive=True) +
                glob.glob('/home/claude/photos/**/*.png', recursive=True))
photos = [p for p in photos if '(1)' not in p]
catalogue = {'portrait': [], 'landscape': []}
for p in photos:
    try:
        img = Image.open(p); img.verify(); img = Image.open(p)
        orient = 'portrait' if img.height > img.width else 'landscape'
        catalogue[orient].append({'path': p, 'name': os.path.basename(p),
                                   'w': img.width, 'h': img.height})
    except: pass
with open('/home/claude/photos/manifest.json', 'w') as f:
    json.dump(catalogue, f)
```

Report: "[X] photos loaded. [Y] portrait (full bleed + split), [Z] landscape (strip)."

**Auto-selection rules:**
- Pick 1-2 photos per carousel from the loaded library
- Rotate through the library across weeks (never the same photo two weeks running)
- Portrait photos -> T7 (Full Bleed Overlay) or T8 (Split)
- Landscape photos -> T9 (Photo Strip)
- Prefer variety: if using two photo slides, use one portrait + one landscape if both available
- Pre-crop at build time: portrait to 1080x1350 (full bleed) or 460x1350 (split), landscape to 1080x620 (strip), using centre-crop biased toward top 25% for faces

**d)** "What is this week's Instagram DM keyword? (Used on the IG CTA slide.)"

### Step 3: Analyse content, assign templates, assign color rhythm, select photos

If `BRAND.md > Vision Tethers` is populated, also check each slide against the tether list and surface any slides that don't connect to a listed tether. This is a soft warning, not a stop.

### Step 4: Pre-crop selected photos, render each slide as HTML -> PNG via wkhtmltoimage -> optimise with Pillow

### Step 5: Present outputs

1. Present IG PNGs (slides + IG CTA) using `present_files`
2. Present FB PNGs (slides + FB CTA) using `present_files`
3. Compile LinkedIn PDF from FB slides and present
4. Output caption text in chat with character count
5. Confirm: "Three outputs ready. [X] IG slides (DM [KEYWORD]). [X] FB slides (Link in first comment). 1 LinkedIn PDF (document post)."

---

## COLOR BASES (read from BRAND.md)

The client's `BRAND.md > Color Bases` defines one or more base palettes. Each base specifies a dark variant and a light variant. Within a single carousel, only ONE base is used, and slides alternate between that base's two variants.

A valid base entry in BRAND.md looks like:
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

Rhythm: Cover = dark, Slide 2 = light, then alternate. CTA = dark.

If `BRAND.md > Color Bases` lists only one base, use it. If multiple, ask the user which (or pass `auto` and let the skill choose based on content tone).

---

## CONTRAST RULES (non-negotiable, brand-agnostic)

- NO grey text on any background. Hierarchy = SIZE + WEIGHT, never vanishing opacity.
- Setup text on light backgrounds: FULL color, just smaller (56px vs 82px punchline).
- Setup text on dark backgrounds: primary text color at minimum 0.55 opacity.
- Nothing below 0.5 opacity except URL header and DM keyword line.
- Never accent text on light background below 72px. Never primary-text-color on accent-colored background.

These rules apply regardless of which brand is loaded.

---

## TYPOGRAPHY (elegant register, scaled to BRAND.md fonts)

Read font selections from `BRAND.md > Typography`:
- `heading_font` - used for cover titles, setup text, punchlines, stat numbers, quote text, CTA titles
- `body_font` - used for pretitles, stat labels, quote attributions, CTA instructions, DM keyword
- `label_font` - optional, used for uppercase labels (defaults to body_font if omitted)

Weights: **400 (Regular)** for setup/body/monogram. **500 (Medium Italic)** for punchlines. **Never 700/800** unless `BRAND.md > Typography > weight_override` says otherwise (some brands want bold; document the override there).

### Header
The header contains ONLY the brand monogram (top left), pulled from `BRAND.md > Brand Identity > monogram`. No URL.

### Production scale (1080px):

| Element | Font role | Size | Weight/Style |
|---|---|---|---|
| Monogram | heading_font | 64px | 400 italic |
| Pretitle | label_font | 24px | 400, letter-spacing 12px |
| Cover title | heading_font | 102px | 400 |
| Subtitle | heading_font | 42px | 400 italic, 0.55 opacity |
| Setup text | heading_font | 56px | 400 |
| Punchline | heading_font | 82px | 500 italic |
| Stat number | heading_font | 180px | 500 |
| Stat label | label_font | 28px | 400, letter-spacing 3px |
| Quote text | heading_font | 52px | 400 italic |
| Quote attr | label_font | 24px | 500, letter-spacing 3px |
| CTA title | heading_font | 76px | 500 italic |
| CTA instruction | label_font | 26px | 500, letter-spacing 5px, accent color |
| DM keyword | label_font | 22px | 400, 0.45 opacity |

### Decorative:
- Accent rule: 120px wide, 2px tall, accent color (optionally with gradient per BRAND.md > Effects)
- Progress bar: 420px wide, 1px tall, accent color
- Slide number: 64px circle, accent color, contrasting text

### Optional metallic accent effect

If `BRAND.md > Effects > metallic_accent` is `true`, apply a multi-stop gradient to all accent elements (text, rules, slide numbers) for a shimmer effect. The gradient stops are pulled from `BRAND.md > Effects > metallic_stops` (a list of hex colors) - typical pattern is dark accent -> mid accent -> light accent -> mid accent -> dark accent. Skip the effect on full paragraphs of body text in accent color (reduces readability).

---

## 9 TEMPLATE TYPES

### Text (6):
**T1 COVER** - Slide 1. Dark bg. Pretitle + rule + title + subtitle.
**T2 STATEMENT** - Setup (56px) + punchline (82px italic). Or standalone.
**T3 ANAPHORA** - Repetition. "In your X. In your Y." Emphatic word in accent color.
**T4 DATA** - Centred number (180px accent) + label + context.
**T5 QUOTE** - Client testimonial. Must be visually unmistakable as a testimonial: "CLIENT TESTIMONIAL" label in label_font uppercase at top, accent rule below label, large opening quotation mark (88px, accent, 0.3 opacity), quote text in italic, closing quotation mark (88px, accent, 0.3 opacity, right-aligned), accent rule below quote, then name + title in label_font uppercase. Verified quotes only - pull from `BRAND.md > Testimonial Bank` if listed.
**T6 CTA** - TWO separate final slides per carousel, clearly labelled:
- **CTA-FB-LI** (for Facebook + LinkedIn): closing line + "LINK IN FIRST COMMENT"
- **CTA-IG** (for Instagram): closing line + "DM [KEYWORD]"

Same design, same closing line, only the CTA text differs. Output both files every time. Tell the user: "Two CTA slides rendered. IG version in the Instagram set. FB/LI version in the Facebook set and the LinkedIn PDF."

### Image (3):
**T7 FULL BLEED** - Portrait photo fills slide. Gradient overlay (color from dark variant) bottom 60%. Text at bottom.
**T8 SPLIT** - Portrait photo left 45%. Text right on dark bg.
**T9 PHOTO STRIP** - Landscape photo top 46%. Text below on dark bg.

### Photo rules:
- Portrait (h > w) -> T7 or T8
- Landscape (w > h) -> T9
- 1-2 photo slides per carousel (positions 2, 8, or 9 typically)
- Photo prep at build time: open from `/home/claude/photos/`, resize to max 800px wide, save as JPEG q80, convert to base64, embed in HTML `<img src="data:image/jpeg;base64,...">`
- Crop rules: portrait -> centre crop biased top 25% for faces. Landscape -> centre crop biased top 30% for faces.
- The skill auto-selects from the uploaded library. User can override: "use DSC00274 on slide 8"

---

## QUESTION PUNCTUATION RULE (applies to every slide, not just the CTA)

If any slide's primary text is a question and ends without a `?`, append one before rendering. Treat as a question when the text:
- Starts with one of: `If`, `Is`, `Are`, `Was`, `Were`, `Do`, `Does`, `Did`, `Will`, `Would`, `Could`, `Should`, `Can`, `Have you`, `Has`, `Had`, `Who`, `What`, `When`, `Where`, `Why`, `How`
- Or ends with a clearly-interrogative construction (rare for short slide text, but check)

Do not invent or reword - only append the `?` glyph. Document the fix in your final summary so the user can see which slides got auto-corrected (and so they can elaborate `BRAND.md > Voice Rules` to catch it upstream in their writing skill).

This rule does NOT override the "source text is sacred" QC check - a single appended `?` is the only mutation allowed, and only on detected questions.

## STATISTIC SOURCING CHECK

If a slide contains a statistic, percentage, ratio, or factual claim (e.g., "78% of EDs..."), check whether the input includes a source citation for it. If no source is present:
- Do not silently render the stat
- Surface the missing source in your final summary as a specific ask back to the user ("Slide N references '78% of EDs' - what's the source citation? I can add it to the slide or footnote it.")
- Proceed with the slide draft but mark the source as `[NEEDS CITATION]` so the user knows to fill it in before posting.

## LANE DRIFT CHECK (when BRAND.md has positioning lanes)

Some brands maintain multiple positioning lanes (e.g., Lane A: services brand, Lane B: niche speaking brand). If `BRAND.md > Positioning` or similar declares a `current_lane` and the slide content clearly belongs to a different lane:
- If > 50% of slides drift from `current_lane`, surface this as a single soft warning at the start of the run: "Your `current_lane` is set to A but this batch reads as Lane B. I'm rendering as Lane B for this run. Update `current_lane` in BRAND.md if you want this to be the default going forward."
- Do not stop the build - the user usually wants the batch they're working on, not a re-litigation of their brand strategy.

## CTA FORMAT

Final slide. Always dark. Always centred. No button. TWO versions rendered every time:

### CTA-FB-LI (Facebook + LinkedIn):
```
[Accent rule]
[Closing line - 76px heading_font medium italic]
[Accent rule]
LINK IN FIRST COMMENT          (accent color, label_font 28px, letter-spacing 5px)
```

### CTA-IG (Instagram):
```
[Accent rule]
[Closing line - identical to FB-LI version]
[Accent rule]
DM [KEYWORD]                   (accent color, label_font 28px, letter-spacing 5px)
```

Same design. Same closing line. Only the CTA text changes. Always tell the user: "Two CTA slides. Use the FB-LI version on Facebook and LinkedIn. Use the IG version on Instagram."

---

## LAYOUT VARIATIONS (rotate weekly)

Within each template type, vary: text alignment (left/centre/right), vertical position (top/centre/bottom), decorative elements (rule above, rule below, bookend rules, left border, accent frame, clean), and setup/punchline arrangement (standard, rule-divided, punchline-only, question-answer, connector-label, kicker-word).

Never repeat the same layout combination two weeks running. The skill should track recent runs in `/home/claude/carousel-history.json` if it can, or ask the user "what did last week look like?" if not.

---

## EXAMPLE 10-SLIDE CAROUSEL

```
1:  COVER (dark)          - Hook title
2:  PHOTO STRIP (dark)    - Landscape photo + statement
3:  STATEMENT (light)     - Setup + punchline
4:  STATEMENT (dark)      - Declaration
5:  DATA/STAT (light)     - Key number
6:  STATEMENT (dark)      - The turn
7:  ANAPHORA (light)      - Repetition build
8:  FULL BLEED (dark)     - Portrait photo + bridge
9:  QUOTE (light)         - Client testimonial
10: CTA (dark)            - Close + link in first comment
```

---

## OUTPUT FORMAT

The skill produces THREE outputs per carousel:

### 1. Instagram PNGs (individual slides)
- Slides 1 through N as individual PNGs
- Final slide = CTA-IG version ("DM [KEYWORD]")
- Naming: `carousel-[day]-[date]-IG-slide-[NN].png`

### 2. Facebook PNGs (individual slides)
- Slides 1 through N as individual PNGs (identical to IG except final slide)
- Final slide = CTA-FB version ("Link in first comment")
- Naming: `carousel-[day]-[date]-FB-slide-[NN].png`

### 3. LinkedIn PDF (single document)
- All slides compiled into one PDF file for upload as a LinkedIn document post
- Final page = CTA-FB version ("Link in first comment")
- Naming: `carousel-[day]-[date]-LI.pdf`

```python
from PIL import Image
slides = [Image.open(f) for f in sorted(slide_files)]
slides[0].save('output.pdf', save_all=True, append_images=slides[1:], resolution=150)
```

Tell the user: "Three outputs. IG folder (PNGs with DM CTA). FB folder (PNGs with link CTA). LinkedIn PDF (single document upload)."

---

## QUALITY CHECKLIST (run before delivering)

### Source integrity (CRITICAL)
- [ ] **Source text is sacred.** Compare every slide's rendered text against the original input word for word. If even one word has been changed, rewritten, paraphrased, restructured, or dropped, STOP and fix it.
- [ ] **No hallucinated content.** Never present AI-written content as if it came from the source.
- [ ] **Testimonial quotes are verified.** Every quote on a T5 slide matches the client's Testimonial Bank (BRAND.md > Testimonial Bank) verbatim. No paraphrasing.

### Brand integrity (CRITICAL)
- [ ] **Colors match BRAND.md exactly.** No hex substitutions, no "close enough" approximations.
- [ ] **Fonts match BRAND.md.** If rendering shows fallback fonts (Georgia/Arial instead of the brand fonts), flag it before delivering.
- [ ] **Monogram matches.** Uses the letters/glyphs in BRAND.md > Brand Identity > monogram.
- [ ] **Voice rules respected.** Check the language variant (en-US vs en-GB), em-dash policy, banned words per BRAND.md > Voice Rules.

### Photo checks
- [ ] **Face not cut off.** Visually inspect every photo slide. Adjust `object-position` if cropped.
- [ ] **Correct template for orientation.** Portrait -> T7/T8. Landscape -> T9. No exceptions.
- [ ] **Not using brand board as photo.** Brand-asset files (logos, mood boards) are NOT headshots.

### Typography and contrast
- [ ] **No bold 700/800 weights** unless BRAND.md > Typography > weight_override allows.
- [ ] **No text below 0.5 opacity** except the DM keyword line on CTA-IG slides (0.45).
- [ ] **No grey text on light backgrounds.** Full color at smaller size, never reduced opacity for hierarchy.
- [ ] **Hierarchy from SIZE not opacity.**
- [ ] **Accent effect applied if BRAND.md > Effects > metallic_accent: true.** NOT on full paragraphs of body text.

### Layout and structure
- [ ] **No URL in header.** Monogram only.
- [ ] **Slide 1 is Cover template** on dark background.
- [ ] **Background alternates dark/light** throughout.
- [ ] **Only the chosen color base's two backgrounds used.** No mixing bases.
- [ ] **Accent on max one word or phrase per slide.**
- [ ] **Line breaks at phrase boundaries.** No orphans, no mid-phrase breaks.
- [ ] **Max 30 words per slide preferred.**

### Testimonial slides
- [ ] **"CLIENT TESTIMONIAL" label** in label_font uppercase at top.
- [ ] **Opening + closing quotation marks** large, accent color, visible (88px, 0.3 opacity).
- [ ] **Accent rule above and below the quote.**
- [ ] **Name and title attribution** in label_font uppercase below the closing rule.

### CTA and output
- [ ] **Two separate CTA slides rendered.** CTA-FB and CTA-IG. Never combined.
- [ ] **Three platform outputs.** IG PNGs, FB PNGs, LinkedIn PDF.
- [ ] **All PNGs render at 1080x1350.** Check actual pixel dimensions.
- [ ] **Photo slides under 900KB.** Text slides under 200KB.
- [ ] **Caption included** with character count and first-125 preview.
- [ ] **Fonts installed and verified.**

### Language (per BRAND.md > Voice Rules)
- [ ] **Language variant matches** (en-US or en-GB, etc.).
- [ ] **Em-dash policy respected** (allow, replace with " - ", or other per BRAND.md).
- [ ] **No banned words** from BRAND.md > Voice Rules > banned_words.
- [ ] **Emojis only if BRAND.md > Voice Rules > emojis: allowed.**

---

**END OF SKILL**
