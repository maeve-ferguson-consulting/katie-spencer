# Output Format — Weekly Content Plan

Each run produces a single Google Doc containing all content types, split into sections.

---

## Heading Hierarchy in Google Docs

Google Docs renders markdown headings literally — every `##` becomes a large H2 heading, every `###` becomes an H3. This creates visual clutter when days and post types all get heading treatment.

**Use headings sparingly. Only these get heading-level formatting:**

| Level | Use for | Markdown |
|-------|---------|----------|
| H1 (`#`) | Platform/content type sections | `# LinkedIn Content`, `# Substack Notes`, `# Email Sequence` |
| Bold text | Day headers, post type labels, metadata | `**Monday 26 Jan 2026**`, `**Thought Post**`, `**Word Count: 50**` |
| Plain text | Post content, CTA blocks, hashtags | No special formatting |

**Do NOT use `##` or `###` for days, post types, or sub-labels.** Use **bold text** instead. This keeps the doc clean and scannable — H1 headers create the major sections, bold text creates the rhythm within each section.

---

## Document Title

Default: `Weekly Content Plan — Week Commencing [Date]`

The Client Profile may specify a different title format. Date format follows the client's preference (default: DD MMM YYYY).

---

## Date Calculation

1. Determine today's date
2. Calculate the next Monday (if today is Monday, use today)
3. Tuesday = Monday + 1, Wednesday = Monday + 2, Thursday = Monday + 3, Friday = Monday + 4
4. Format all dates consistently using the client's preferred format
5. Double-check: Monday through Friday should be 5 consecutive weekdays

---

## Document Structure

The doc follows this section order (adapt to match Client Profile's output format if different):

```markdown
# Weekly Content Plan
Week Commencing: [Date]
Generated from: [Newsletter title or subject]

# Newsletter Title Options

**Option 1:** [Title]
**Strategy:** [Type]
**Why This Works:** [Explanation]

**Option 2:** [Title]
**Strategy:** [Type]
**Why This Works:** [Explanation]

**Option 3:** [Title]
**Strategy:** [Type]
**Why This Works:** [Explanation]


# LinkedIn Content

**Monday [Date]**

**Thought Post**

[Full post content]

**CTA Post**

[Full post content]

[Weekly CTA]

Link in first comment


**Tuesday [Date]**

**Thought Post**

[Content]

**CTA Post**

[Content]

[Weekly CTA]

Link in first comment


[... Wednesday through Friday ...]


# Instagram Content

**Monday [Date]**

[Post content]

[Engagement prompt]

[Hashtags]


**Tuesday [Date]**

[Content]

[Engagement prompt]

[Hashtags]


[... Wednesday through Friday ...]


# Facebook Content

**Monday [Date]**

**Thought Post**

[Content]

**CTA Post**

[Content]

[Weekly CTA]

Link in first comment


[... Tuesday through Friday ...]


# Substack Notes

**Monday [Date]**

[50-150 word standalone insight]

**Word Count:** [XX words]


**Tuesday [Date]**

[Content]

**Word Count:** [XX words]


[... Wednesday through Friday ...]


# Summary

| Platform | Content Pieces |
|----------|----------------|
| Newsletter Titles | [X] options |
| LinkedIn | [X] posts |
| Instagram | [X] posts |
| Facebook | [X] posts |
| Substack Notes | [X] notes |
| **Total** | **[count] pieces** |
```

Only include sections for active platforms. Adjust the total accordingly.

If the Client Profile defines a different output format (additional content types like emails, carousels, different section order), follow their format instead — but always use the same heading rules: H1 for major sections, bold for everything else.

---

## Formatting Rules

1. **No emojis** unless Client Profile explicitly permits them.
2. **H1 for sections only.** Platform names and content type names get `#`. Nothing else gets heading markup.
3. **Bold for structure.** Day headers, post type labels, metadata labels all use `**bold**` not headings.
4. **Consistent layout.** Every day within a section uses the identical structure. No day gets extra or missing elements.
5. **Blank lines for separation.** Use blank lines between days and between posts. Do NOT use `---` horizontal rules in Google Docs content — they can cause silent failures with replace-text.
6. **Word counts on Substack Notes.** Every Note displays its word count.
7. **Dates on every day header.** Every "Monday," "Tuesday," etc. includes the actual date.
8. **Summary table at the end.** Always include the content count summary.

---

## Quality Checklist (Run Before Finalizing)

**Overall:**
- [ ] All content uses ONLY text from the newsletter (source integrity)
- [ ] Brand voice consistent throughout (from Client Profile)
- [ ] Spelling convention followed (from Client Profile)
- [ ] All dates calculated correctly (next Monday + 4 days)
- [ ] Total content count matches expected count for active platforms
- [ ] Only H1 headings used for platform sections — no H2/H3 clutter

**Newsletter Titles:**
- [ ] Distinct options with different strategies
- [ ] Each has "Why This Works" explanation

**LinkedIn:**
- [ ] Correct post count (default: 10 = 5 days x 2)
- [ ] Thought posts have NO CTA
- [ ] CTA posts end with weekly CTA + "Link in first comment"
- [ ] Hashtag/emoji rules from Client Profile applied

**Instagram:**
- [ ] Correct post count (default: 5)
- [ ] NO CTAs or links anywhere
- [ ] First 125 characters are hook-optimized
- [ ] Hashtags present and varied across days
- [ ] Engagement prompts instead of CTAs

**Facebook:**
- [ ] Correct post count (default: 10 = 5 days x 2)
- [ ] First ~480 characters are hook-optimized
- [ ] Thought posts end with discussion prompts
- [ ] CTA posts end with weekly CTA + "Link in first comment"
- [ ] Hashtag/emoji rules from Client Profile applied

**Substack Notes:**
- [ ] Correct note count (default: 5)
- [ ] Each 50-150 words (word count displayed)
- [ ] Each works standalone (no newsletter references)
- [ ] NO "read my newsletter" language
- [ ] Varied formats across days
