# `OUTREACH_DATABASE` schema

The flat-file prospect roster `craft-outreach` reads in batch mode. The consultant maintains this file — the skill **reads** status; it does **not** write back. Batch mode produces drafts for each row; the consultant logs status updates in their own system after sending.

The skill accepts the database as a CSV file, a markdown table, or a Google Sheet ID (with appropriate MCP access). Format is consultant's choice — match whichever they already use. The schema below is the field contract.

## Required fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Full name |
| `org` | string | Organisation name |
| `status` | enum | One of: `cold`, `warmed`, `replied`, `nurture`, `closed-won`, `closed-lost`, `drop` |
| `dossier_path` | string | Filesystem path or URL to the prospect's dossier (output of `lead-dossier-builder`). If empty, batch mode flags this row and skips it. |

## Recommended fields

| Field | Type | Description |
|---|---|---|
| `role` | string | Title at the org (e.g., "Executive Director") |
| `last_touch_date` | ISO date | When the consultant last reached out |
| `last_touch_channel` | enum | `linkedin-dm`, `email`, `voice-note`, `in-person`, `referral` |
| `last_touch_type` | enum | `first-touch`, `follow-up`, `nudge`, `re-engage`, `ping` |
| `last_touch_result` | enum | `no-reply`, `replied-warm`, `replied-cold`, `meeting-booked`, `passed` |
| `hook_url` | URL | The most recent prospect activity to tether to (if known — otherwise the skill checks the dossier) |
| `priority` | enum | `high`, `medium`, `low` |
| `notes` | string | Free text — referral source, mutual connection, anything contextual |

## Example CSV

```csv
name,org,role,status,dossier_path,last_touch_date,last_touch_channel,last_touch_type,last_touch_result,hook_url,priority,notes
Anya Patel,Memphis Music Initiative,Executive Director,cold,./dossiers/patel-anya.md,,,,,https://linkedin.com/posts/anya-patel-mmi-board-reengagement,high,Met briefly at Memphis Nonprofit Summit 2025
Marcus Chen,Bay Area Foundation,Program Officer,warmed,./dossiers/chen-marcus.md,2026-04-12,linkedin-dm,first-touch,no-reply,,medium,
```

## Example markdown table

```markdown
| name | org | role | status | dossier_path | last_touch_date | last_touch_type | last_touch_result | priority |
|---|---|---|---|---|---|---|---|---|
| Anya Patel | Memphis Music Initiative | ED | cold | ./dossiers/patel-anya.md | | | | high |
| Marcus Chen | Bay Area Foundation | PO | warmed | ./dossiers/chen-marcus.md | 2026-04-12 | first-touch | no-reply | medium |
```

## Batch-mode behaviour

When the skill loads the database:

1. **Filter** to the requested cohort — by `status`, `priority`, or an explicit row range. Default: all rows where `status` ∈ `{cold, warmed, nurture}`.
2. **Per row**, run the precheck:
   - `dossier_path` exists and is readable
   - The dossier surfaces a real recent hook (per the no-hallucination discipline in `SKILL.md`)
3. **Flag** any row that fails precheck. List the flagged rows at the top of the output so the consultant knows to deepen those dossiers (or wait for substantive activity) before re-running.
4. **Write** three angle variants per non-flagged row.

## What the skill never writes back

- `status` changes
- `last_touch_*` fields
- Notes

The consultant updates these after sending. The skill is read-only against the database.

## Single-prospect mode

If the consultant supplies only a name + org (no database), the skill builds the dossier on the fly via `lead-dossier-builder` and writes the three-variant draft directly. No database needed.

## Bootstrapping

A consultant who has no database yet can run:

> "/outreach setup database"

and the skill will write a starter CSV with the required columns at `OUTREACH_DATABASE.csv` in the working directory. The consultant fills in their first rows manually (or pastes from LinkedIn, Notion, an existing CRM export) and re-runs in batch mode.
