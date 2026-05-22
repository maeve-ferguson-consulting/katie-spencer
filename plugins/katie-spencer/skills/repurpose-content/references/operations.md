# Google Workspace Operations — Repurpose Content Skill

Tested MCP tool call patterns for creating the weekly content plan as a Google Doc and saving it to the client's Drive folder.

---

## Architecture

Each run produces:
- **One local markdown file** — the source of truth, generated first
- **One Google Doc** — the delivery copy for the client's team, with H1 sections per content type/platform

---

## 1. FIRST-RUN SETUP

On first use — or whenever the folder doesn't exist — set up the Google Drive workspace. This is idempotent: always check before creating.

**Step 1: Find or create the client content folder**
1. Use `google_drive-find-folder` to search for the client's content folder name (from Client Profile, e.g., "Maeve — Weekly Content") in My Drive.
2. If NOT found → use `google_drive-create-folder` to create it in My Drive. Save the folder ID.
3. If found → save the folder ID.

**Step 2: Confirm setup**
Report back: "Content folder ready. Weekly content plans will be saved here automatically."

---

## 2. GOOGLE WORKSPACE MCP — CRITICAL RULES

These rules apply to ALL Pipedream MCP tool calls. Violating them causes silent failures.

1. **Always include all identifiers** — doc ID, drive name, folder ID. Never assume defaults.
2. **Always end with an action directive** — "Please [verb] this now." or "Execute this replacement immediately." Passive descriptions get stuck in "configuration mode."
3. **Drive is always `My Drive`** — include this explicitly.
4. **If a tool returns "no output" or asks a follow-up question, it failed.** Retry with more explicit instruction text.

---

## 3. CREATING THE WEEKLY CONTENT DOC

All content goes into a single Google Doc per week, split into sections with H1 headers for each content type/platform. This gives VAs one doc to open with everything in order.

### Always create the local file first

Before touching Google Docs, generate the complete content plan as a local markdown file. This is the source of truth. The Google Doc is a delivery copy.

### Doc Creation Flow — 2 MCP Calls

**Primary method: `google_drive-create-file-from-text` (1 call to create, 1 to move)**

This tool creates a Google Doc directly from text content in a single call. No create → append → replace dance. Use this as the default.

**IMPORTANT: Always create in Drive root, then move.** Creating directly into a subfolder silently fails.

**Step 1: Create the Google Doc in Drive root**
- Tool: `google_drive-create-file-from-text`
- Pass the ENTIRE content plan as the text content
- Set the file name to the doc title (e.g., `Weekly Content Plan — Week Commencing [Date]`)
- Use mimeType `text/markdown` (NOT `application/vnd.google-apps.document` — that gets rejected). Google Drive auto-converts to a Google Doc.
- Do NOT specify a folder — create in root

**Step 2: Verify creation**
- Check if the response includes a file ID
- If no file ID returned, use `google_drive-find-file` to search by name
- If not found, retry ONCE (still targeting root)
- If still not found, output full content in chat and flag for manual creation

**Step 3: Move to the client's content folder**
- Tool: `google_drive-move-file`
- Move into the client content folder (folder ID from first-run setup or Client Profile)

**Step 4: Return the doc URL** for the delivery summary.

That's it. 3 MCP calls total (create, verify if needed, move).

### Fallback (only if `create-file-from-text` fails)

If `google_drive-create-file-from-text` fails, output the full content as a conversation artifact and note: "I couldn't create the Google Doc automatically. Here's the complete content — you can paste it into Google Docs." Do NOT attempt multi-step chunking with other doc tools.

### Formatting content for Google Docs

The content must use Markdown syntax so that Google Docs renders proper formatting. Without it, everything appears as plain text.

**Use Markdown in the content:**
- `# Section Name` → renders as Google Docs Heading 1
- `**Bold text**` → renders as bold
- Plain text → stays as plain text

**DO NOT use ALL CAPS for headers.** `SOCIAL CONTENT` renders as plain text. `# Social Content` renders as a proper heading.

**Apply this formatting:**
- `# LinkedIn Content`, `# Instagram Content`, `# Substack Notes`, etc. → H1 for platform sections
- `**Monday 26 Jan 2026**` → bold for day headers
- `**Thought Post**`, `**CTA Post**` → bold for post type labels
- `**Option 1:**`, `**Strategy:**`, `**Why This Works:**` → bold for metadata labels
- `**Word Count:** 82 words` → bold label for Substack word counts
- Everything else as plain text

The local markdown file and the Google Doc content use the same formatting — write it once, use it for both.
- Keep each replacement under ~3000 words. If a section is larger, split it into sub-sections (e.g., `SECTION_MONDAY_AM` and `SECTION_MONDAY_PM`).

---

## 4. GOOGLE DOCS & DRIVE TOOLS

### `google_drive-create-file-from-text` — PRIMARY DOC CREATION TOOL
Creates a Google Doc directly from text content in a single call. This is the fastest and most reliable way to create a content plan doc.
```
Create a Google Doc from the following text content. File name: "[TITLE]". Content: [FULL MARKDOWN CONTENT]
```

### `google_docs-get-document` — RELIABLE
Reads the full text contents of a Google Doc. Use to verify content was written correctly.

### `google_docs-find-document` — RELIABLE
Searches for a Google Doc by name (partial match supported).

---

## 5. GOOGLE DRIVE TOOLS

### `google_drive-create-folder` — RELIABLE
```
Create a folder named "[NAME]" in My Drive.
```
Inside a parent:
```
Create a folder named "[NAME]" inside the folder with ID "[PARENT_ID]" named "[PARENT_NAME]" in My Drive.
```

### `google_drive-find-folder` — RELIABLE
```
Find a folder named "[NAME]" in My Drive.
```

### `google_drive-move-file` — RELIABLE
```
Move the file with ID "[FILE_ID]" named "[FILE_NAME]" to the folder with ID "[FOLDER_ID]" named "[FOLDER_NAME]" in My Drive.
```
**Note:** Requires both file ID AND file name, and both folder ID AND folder name.

---

## 6. FALLBACK (No Google MCP)

If Google Workspace MCP is unavailable:

1. Output the complete content plan as a conversation artifact.
2. Explicitly tell the client: "Google Workspace isn't connected, so I couldn't create the Google Doc. Connect via Pipedream MCP to enable automatic delivery."

**Never silently skip steps.** If any part of the protocol can't be completed, name it and explain why.

---

## 7. WEEKLY FOLDER STRUCTURE

After several runs, the client's Drive folder looks like:

```
[Client Name] — Weekly Content/
├── Weekly Content Plan — Week Commencing 06 Apr 2026
├── Weekly Content Plan — Week Commencing 13 Apr 2026
├── Weekly Content Plan — Week Commencing 20 Apr 2026
...
```

One doc per week. Docs accumulate chronologically.

---

## CHANGELOG

| Date | Change | Reason |
|------|--------|--------|
| 2026-03-26 | v3.0 — Single doc, no tracker, section-by-section writing | Streamlined to single Google Doc per week with H1 platform sections. Removed tracker spreadsheet. Section-by-section placeholder+replace-text pattern with verification to prevent silent content loss. |
| 2026-03-26 | v2.1 — Section-by-section doc writing with verification | CoWork test showed append-text silently drops large content. |
| 2026-03-26 | v2.0 — Per-platform docs + tracker sheet model | Replaced single-doc model with per-platform docs and tracker. |
| 2026-03-25 | v1.0 — Initial single-doc operations | Original single Google Doc delivery model. |
