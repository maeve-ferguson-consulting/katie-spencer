---
name: build-story
description: "Use this skill to render Instagram or Facebook Stories as vertical 9:16 (1080x1920) PNG slide files. Trigger any time the user wants story slides BUILT, MADE, RENDERED, DESIGNED, GENERATED, or CREATED as actual image files - whether a full weekly batch (Monday-Friday, 5 days), a single one-off, or a re-render of last week's stories with new photos or new brand colors. Trigger on /story-build, /buildstories, /stories, and on any phrasing like 'build the stories', 'make the stories', 'make the story slides', 'design the 9:16 stories', 'story PNGs', 'turn this into IG stories', 'make them into Instagram stories', or 'stories for IG and Facebook'. Handles CTA slides with Instagram reply keywords (PARTNERSHIP, READY, DESIGN, etc.) and Facebook 'Tap to learn more' link stickers, photo-zip inputs, color-base picks, and brand styling pulled from a BRAND.md. NOT for writing/drafting story copy from scratch, content calendars, safe-zone questions, best-practices advice, or carousels/feed posts."
---

# BUILD STORY

Universal Story slide builder. Produces 1080x1920 (9:16) PNG slide sets in the client's brand, ready to post to Instagram and Facebook Stories.

## How this skill reads brand context

Brand-agnostic. Every brand decision (colors, fonts, monogram, voice, vision tethers) is read at runtime from a `BRAND.md` document in the client's Claude Project Knowledge, per the schema in `references/brand-schema.md` (shared with `build-carousel`).

If `BRAND.md` is missing or incomplete, this skill MUST stop and invoke `define-brand-voice` to capture it. Shipping in the wrong brand is worse than not shipping.

## BRAND.md is a living document - help the user elaborate it

Same handshake as `build-carousel`. After every render, surface ONE concrete elaboration prompt - something the user could improve in BRAND.md based on what they just saw. Story-specific examples:

- "Tuesday's Slide 1 photo was bright in the lower 40% - the gradient overlay had to go heavy. Want to add a `photo_brightness_threshold` note to BRAND.md, or just curate brighter-light photos out of the upload pile?"
- "Wednesday's Payoff line was a question but didn't punctuate. The skill auto-added the '?'. Want to add 'questions must end with ?' to your Voice Rules so the writing skill catches it upstream?"
- "Friday's life-texture photo set didn't have farm/family options - I used the same one as Monday. Want to commit to uploading a fresh life-texture batch each week, or add a 'reuse OK if > 4 weeks since last use' rule?"

The skill suggests, the user decides. The skill never edits BRAND.md programmatically.

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
   - Once that's in place, they can come back and re-run the same prompt - their story text will be preserved so they don't need to re-paste it.
   - Do NOT silently substitute defaults. Do NOT chain-invoke `define-brand-voice` automatically - tell the user it's their next step.
4. If a required section is present but marked PROVISIONAL (a `<!-- PROVISIONAL: ... -->` comment between its heading and its yaml fence - see `references/brand-schema.md`), do NOT silently proceed. The section holds starter defaults, not the client's real brand. Tell the user, in your own words:
   - Which required section(s) are still placeholder defaults (e.g. Color Bases, Typography), and that the build will therefore look generic, not like their brand.
   - To get real on-brand output, the fix is to run `define-brand-voice` again and set those values, then re-run - their story text is preserved.
   - If they explicitly say to proceed anyway ("render it anyway", "I know, just do it"), proceed using the placeholder values. Otherwise stop here. Do NOT chain-invoke `define-brand-voice` automatically.
5. If all required sections are present and none are PROVISIONAL, proceed.

---

## TRIGGER

Activates on: `/story-build`, `/buildstories`, `/stories`, "build the stories", "build the story slides", "create the story images", "make the stories", "turn these into story slides", or any request to turn story text into branded visual Story slides.

---

## CANVAS: 1080 x 1920 (9:16)

Stories are full-screen vertical. Every design decision accounts for this ratio.

### Safe Zones (non-negotiable)

Platform UI overlays eat into the top and bottom of every Story. No critical content in these areas.

| Zone | Pixels | What lives there |
|---|---|---|
| Top safe zone | 0-250px from top | Instagram: username bar, close button. Facebook: profile pic, name, timestamp. |
| Content zone | 250-1670px | ALL text, key visuals, and CTAs live here. 1420px of usable vertical space. |
| Bottom safe zone | 1670-1920px from bottom | Instagram: reply bar, message input. Facebook: reply bar. Swipe-up/link sticker zone. |

**Top zone rule:** Only the brand monogram or a subtle watermark may sit in the top 250px. Nothing the viewer needs to read.

**Bottom zone rule:** Only a subtle swipe indicator or gradient fade. The CTA slide uses a link sticker overlay zone here, but the actual CTA text sits ABOVE the 1670px line.

---

## FONT INSTALLATION (run once per session)

Same as `build-carousel` - pulls fonts from `BRAND.md > Typography`.

---

## GENERATION SEQUENCE

### Step 1: Install fonts (per BRAND.md > Typography)

### Step 2: Collect inputs

**a)** "Paste the story text (all 5 days, or whichever days you want built)."

**b)** "Which color base? Options from BRAND.md: [list]. One base per week - all 5 stories use the same base."

**c) Photo library:**
"Upload your photo library zip. I'll extract, catalogue by orientation, and auto-select photos for photo slides."

If no zip uploaded, ask: "Upload 1-2 individual photos, or paste image URLs."

(Photo extraction + catalogue code identical to `build-carousel`.)

**Photo-placeholder mode (when the user wants to plan now, swap photos later):**
If the user explicitly says they want to plan the week now and add photos later, OR if they don't respond to the photo-library ask within the same turn, switch to placeholder mode:
- Build the full HTML for every slide, including photo slides (ST5, ST6, ST7)
- Wherever a photo would go, render a placeholder block: solid dark variant background with a small label "PHOTO PLACEHOLDER: [orientation] - swap before publish"
- In the final summary, list every placeholder slide as a punchlist of photos to upload before publishing
- Don't stop the build over missing photos.

**Auto-selection rules:**
- Stories are more photo-heavy than carousels. Use 1-2 photos per 4-slide story.
- Slide 1 (the scene) is the strongest photo candidate. Slide 2 or 3 can also carry a photo.
- Slide 4 (CTA) is always text-only on dark background.
- Rotate through the library across the week (never the same photo twice in one week).
- Portrait photos (h > w) are ideal for Stories. They fill the 9:16 frame naturally.
- Landscape photos work as cinematic strips (top or middle band with text above/below).
- Pre-crop at build time: portrait to 1080x1920 (full bleed) or 1080x1100 (top half), landscape to 1080x700 (cinematic band), centre-crop biased toward top 25% for faces.

**d)** "What is this week's Instagram Reply keyword?"

### Step 3: Analyse content, assign templates per slide, assign photo placements, select photos

If `BRAND.md > Vision Tethers` is populated, check each slide against the tether list.

### Step 4: Pre-crop selected photos, render each slide as HTML -> PNG via wkhtmltoimage -> optimise with Pillow

### Step 5: Present outputs

1. Present IG Story PNGs using `present_files` (grouped by day)
2. Present FB Story PNGs using `present_files` (grouped by day)
3. Confirm: "Five stories built. [X] slides total. IG set (Reply [KEYWORD] on CTA slides). FB set (link sticker zone on CTA slides)."

---

## COLOR BASES (read from BRAND.md)

Identical schema and rule to `build-carousel`. One color base per week. All 5 stories use the same base.

### Story Rhythm (within a 4-slide story)
- Slide 1 (Scene): dark or photo
- Slide 2 (Development): light
- Slide 3 (Payoff): dark
- Slide 4 (CTA): always dark

Photo slides override the rhythm. A photo slide counts as "dark" regardless of the underlying color base.

---

## CONTRAST RULES (non-negotiable)

Same rules as `build-carousel`.

- NO grey text on any background.
- Setup text on light: FULL color, smaller size.
- Setup text on dark: minimum 0.55 opacity.
- Nothing below 0.5 opacity except Reply keyword line on CTA.
- NO day-of-week labels on any slide.

---

## TYPOGRAPHY (scaled to BRAND.md fonts)

Same font-role schema as `build-carousel` (heading_font, body_font, label_font).

### Story-specific type scale (1080px production)

Stories have more vertical space but the viewer is closer. Text must be large enough to read instantly while tapping through.

| Element | Font role | Size | Weight/Style | Notes |
|---|---|---|---|---|
| Monogram | heading_font | 56px | 400 italic | Top zone watermark, 0.3 opacity |
| Scene text (Slide 1) | heading_font | 64px | 400 | Short, punchy. 2-3 lines max. |
| Development (Slide 2) | heading_font | 52px | 400 | Slightly smaller. 3-4 lines max. |
| Payoff (Slide 3) | heading_font | 68px | 500 italic | The big moment. |
| CTA line (Slide 4) | heading_font | 56px | 500 italic | The closing invitation. |
| Reply keyword | label_font | 36px | 600, letter-spacing 5px | Accent color, uppercase. |
| Accent word | heading_font | inherit | 400 italic | Accent color. Max one per slide. |
| Photo overlay text | heading_font | 64px | 400 | Light text on gradient. |
| Slide indicator dots | - | 8px circles | - | Accent active, 0.2 opacity inactive. |

### Optional metallic accent effect

Same rule as `build-carousel` - applied to accent text/rules if `BRAND.md > Effects > metallic_accent: true`.

---

## STORY STRUCTURE (from writing skill)

Every story is exactly 4 slides:

```
[DAY] STORY

Slide 1: [Scene or hook - 2-3 lines]

Slide 2: [Development - 3-4 lines]

Slide 3: [Payoff - 2-4 lines]

Slide 4 (CTA): Reply with [KEYWORD] [relevance bridge or simple invitation]
```

The skill takes this text and renders 4 branded PNGs per story, 5 stories per week = 20 slides total (plus platform variants for CTA slides).

---

## 7 SLIDE TEMPLATES

### Text Templates (4):

**ST1 SCENE** - Slide 1 default. Dark background. Text centred. Large, immediate. No day labels.

**ST2 DEVELOPMENT** - Slide 2. Light background. Text left-aligned or centred.

**ST3 PAYOFF** - Slide 3. Dark background. Biggest, most impactful. Medium italic.

**ST4 CTA** - Slide 4. Always dark. Closing line + Reply keyword. TWO versions rendered:

**CTA-IG (Instagram):**
```
[Top safe zone: monogram, 0.3 opacity]
[Content zone upper-centre: closing line - heading_font 56px, 500 italic]
[Accent rule]
[Reply with [KEYWORD] - label_font 36px, accent color, uppercase, letter-spacing 6px]
[Bottom safe zone: link sticker target zone - leave clear]
```

**CTA-FB (Facebook):**
```
[Top safe zone: monogram, 0.3 opacity]
[Content zone upper-centre: closing line - heading_font 56px, 500 italic]
[Accent rule]
[Tap to learn more - label_font 36px, accent color, uppercase, letter-spacing 6px]
[Bottom safe zone: link sticker target zone - leave clear]
```

Same design, same closing line. Only the CTA text differs.

### Question Punctuation Rule (applies to every slide, not just the CTA)

If any slide's primary text is a question and ends without a `?`, append one before rendering. Treat as a question when the text:
- Starts with one of: `If`, `Is`, `Are`, `Was`, `Were`, `Do`, `Does`, `Did`, `Will`, `Would`, `Could`, `Should`, `Can`, `Have you`, `Has`, `Had`, `Who`, `What`, `When`, `Where`, `Why`, `How`
- Or ends with a clearly-interrogative construction

Do not invent or reword - only append the `?` glyph. Document the fix in your final summary so the user can see which slides got auto-corrected (and so they can elaborate `BRAND.md > Voice Rules` with a `punctuation_rules: interrogatives must end with ?` line to catch it upstream in their writing skill).

This rule does NOT override the "source text is sacred" QC check - a single appended `?` is the only mutation allowed, and only on detected questions.

### Photo Templates (3):

**ST5 FULL BLEED OVERLAY** - Portrait photo fills entire 1080x1920. Full-frame gradient overlay (color from dark variant) heaviest at bottom. Text sits on the gradient at bottom of content zone.

Best for: Slide 1 (the scene).

Photo prep:
- Portrait photos: centre-crop to 1080x1920, bias top 25% for faces.
- Apply full-frame gradient (use dark variant bg color): `linear-gradient(to top, rgba(<dark.bg>, 0.97) 0%, rgba(<dark.bg>, 0.92) 35%, rgba(<dark.bg>, 0.7) 55%, rgba(<dark.bg>, 0.4) 75%, rgba(<dark.bg>, 0.2) 100%)`
- Text color: light variant text color on the gradient area.
- Text position: `justify-content: flex-end` - text always sits at the BOTTOM of the content zone where the gradient is heaviest.

### Brightness Check (non-negotiable for full bleed)
Before rendering, check the average brightness of the lower 40% of the photo. If average pixel value exceeds 160 (on 0-255), increase the gradient opacity at the 55% stop from 0.7 to 0.85. If it exceeds 190, fall back to a text-only template.

**ST6 CINEMATIC STRIP** - Landscape photo as a horizontal band (top half or centre). Text below on solid background.

Best for: Slide 2 (development).

**ST7 SPLIT VERTICAL** - Photo fills left or right 45%. Text on the other 55% over solid background.

Best for: Slide 2 or 3.

### Photo rules:
- Portrait (h > w) -> ST5 or ST7
- Landscape (w > h) -> ST6
- 1-2 photo slides per story (Slide 1 or 2 preferred, never Slide 4)

---

## SLIDE INDICATOR DOTS

Every slide carries indicator dots in the bottom safe zone, showing position within the 4-slide story.

```
o * o o    (slide 2 of 4)
```

- Active dot: 8px circle, accent color fill
- Inactive dots: 8px circle, text color at 0.2 opacity
- Positioned: bottom centre, y=1880
- Spacing: 16px between dots

---

## EXAMPLE WEEK TEMPLATE ROTATION

Vary photo placement and template mix across the 5 stories so the week feels dynamic, not repetitive.

```
Monday:    ST5 (photo) -> ST2 (text) -> ST3 (text) -> ST4 (CTA)
Tuesday:   ST1 (text)  -> ST6 (photo) -> ST3 (text) -> ST4 (CTA)
Wednesday: ST1 (text)  -> ST2 (text) -> ST3 (text) -> ST4 (CTA)  [no photo - industry obs]
Thursday:  ST7 (photo) -> ST2 (text) -> ST3 (text) -> ST4 (CTA)
Friday:    ST5 (photo) -> ST2 (text) -> ST3 (text) -> ST4 (CTA)  [life-texture photo]
```

Rules:
- At least 3 of the 5 stories include a photo slide.
- Never the same photo template two days running.

---

## OUTPUT FORMAT

TWO outputs per story, FIVE stories per week:

### 1. Instagram Story PNGs
- 4 slides per story as individual PNGs
- Slide 4 = CTA-IG ("Reply with [KEYWORD]")
- Naming: `story-[day]-slide-[N]-IG.png`

### 2. Facebook Story PNGs
- 4 slides per story (identical except Slide 4)
- Slide 4 = CTA-FB ("Tap to learn more")
- Naming: `story-[day]-slide-[N]-FB.png`

Slides 1-3 identical across platforms. Render once, copy to both output sets.

---

## RENDERING PIPELINE

```bash
wkhtmltoimage --width 1080 --height 1920 --quality 95 \
  /home/claude/story-slide.html /home/claude/story-slide-raw.png
```

Optimise with Pillow:
```python
from PIL import Image
img = Image.open('/home/claude/story-slide-raw.png')
assert img.size == (1080, 1920), f"Wrong size: {img.size}"
img.save('/home/claude/story-slide.png', optimize=True)
```

---

## QUALITY CHECKLIST (run before delivering)

### Source integrity (CRITICAL)
- [ ] **Source text is sacred.** Word-for-word match against input.
- [ ] **No hallucinated content.**
- [ ] **4 slides per story.** Scene -> Development -> Payoff -> CTA.

### Brand integrity (CRITICAL)
- [ ] **Colors match BRAND.md exactly.**
- [ ] **Fonts match BRAND.md.** Flag if rendering shows fallback fonts.
- [ ] **Monogram matches BRAND.md > Brand Identity > monogram.**
- [ ] **Voice rules respected** (language variant, em-dash policy, banned words per BRAND.md).

### Safe zones (CRITICAL)
- [ ] **No readable text in top 250px.** Monogram only at low opacity.
- [ ] **No readable text below 1670px.**
- [ ] **CTA text sits above 1670px line.**

### Photo checks
- [ ] **Face not cut off.**
- [ ] **Correct template for orientation.** Portrait -> ST5/ST7. Landscape -> ST6.
- [ ] **Gradient overlay readable.** Run brightness check on ST5.

### Typography and contrast
- [ ] **No bold 700/800** unless BRAND.md allows.
- [ ] **No text below 0.5 opacity** except monogram (0.3) and Reply keyword (0.45 if needed).
- [ ] **Hierarchy from SIZE not opacity.**
- [ ] **Text large enough for phone viewing.** Min 48px for body text at 1080px production.

### Layout and structure
- [ ] **No day-of-week labels.**
- [ ] **Slide 1 = Scene.** Slide 4 = CTA on dark.
- [ ] **Background alternates** where possible.
- [ ] **Accent on max one word/phrase per slide.**
- [ ] **Line breaks at phrase boundaries.**
- [ ] **Max 25 words per slide.**

### CTA and output
- [ ] **CTA closing line punctuation.** Questions end with "?".
- [ ] **Two CTA slides per story** (CTA-IG + CTA-FB).
- [ ] **Two output folders** (IG + FB).
- [ ] **All PNGs at 1080x1920.**
- [ ] **Photo slides under 900KB.** Text slides under 200KB.
- [ ] **20 slides total** per week (4 x 5 days), plus 5 extra CTA variants per platform = 25 PNGs per folder.

### Language (per BRAND.md > Voice Rules)
- [ ] **Language variant matches.**
- [ ] **Em-dash policy respected.**
- [ ] **No banned words.**
- [ ] **Emojis only if BRAND.md allows.**

---

**END OF SKILL**
