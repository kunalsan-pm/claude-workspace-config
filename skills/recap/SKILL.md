---
name: recap
description: Produce a Monday-morning standup-style recap of the previous week's merged work, drawn from git history, GitHub PRs, and linked GitHub Issues. Output is technical-but-narrative — the way a tech lead would brief their PM. Groups work by product area, anchors each item to its issue/epic title where one exists, and explains the problem each merge solved. Use on Monday mornings or when catching up after time away. Default window is the previous 7 days.
---

# Weekly Recap — Standup from the Squad

## When to use this skill

- Monday morning catch-up on what shipped the previous week
- Returning from time off and needing to know what changed
- Preparing for a weekly review, retro, or stakeholder update
- Any time the user asks for a summary of recent merged work in this repo

If the user asks for a recap of *unmerged* work, work-in-progress, or planning — this is the wrong skill. Recap is about what shipped.

## Philosophy (read before producing output)

This is **standup mode**, not translation mode. The audience is the user — a technically literate solo operator who built this code. Plain English, narrative, but the technical substance stays in. Do not strip detail to make things "simpler." A good standup briefing keeps the detail that matters and drops the ceremony.

The format the user is reaching for: **"It's Monday, your engineering squad is briefing you on what shipped last week."** Brief, grouped by product area, each item tied to the problem it solved. Not a changelog. Not release notes.

Two failure modes you actively avoid:

1. **Listicle mode.** A flat bulleted list of PR titles is not a recap. It's a `git log` with bullets. The recap groups, contextualizes, and tells a small story per area.

2. **Hallucinated problem statements.** Every "this solved X" claim must trace to evidence — a PR description, a linked issue, a commit message. If you can't find the why, say so honestly: "merged a refactor of the auth module, no linked issue or context — flagging for review."

## Inputs

The skill expects to be invoked in a repo with `git` available and the GitHub CLI (`gh`) authenticated. If `gh` is not available, fall back to git-only mode and flag the degradation in the output.

Optional caller-supplied parameters:

- **Window** — number of days back from today (default: 7).
- **Branch** — the integration branch to read merges from (default: try `main` then `master`, in that order).

Do not ask the user for these unless the defaults clearly don't apply.

## Data gathering sequence

Run these in order. Stop as soon as you have enough to produce the recap.

### Step 1 — Establish the window

Compute the date range: from `today - <window> days` to `today`. State the exact range in the output header.

### Step 2 — Get merged PRs in window

Preferred command:
```
gh pr list --state merged --search "merged:>=<start-date>" --base <branch> --limit 50 --json number,title,body,mergedAt,labels,closingIssuesReferences,url
```

If `gh` is not authenticated or fails, fall back to:
```
git log --merges --since="<window> days ago" --pretty=format:"%h|%s|%an|%ai" <branch>
```
and flag in the output that you're operating in git-only mode and PR descriptions / issue links are unavailable.

### Step 3 — For each PR, gather linked issues

If a PR has `closingIssuesReferences`, fetch each linked issue:
```
gh issue view <number> --json number,title,body,labels,milestone,url
```

Linked issues give you the **why**. The PR tells you what was merged; the issue tells you what problem it was solving. If a PR has no linked issue, note that and use the PR body for context instead.

If an issue belongs to a milestone, capture the milestone title — this is your closest proxy for "epic" in GitHub Issues.

### Step 4 — Group by product area

You need to bucket the work into product areas. Strategy in priority order:

1. **GitHub labels** — if PRs or issues are labeled with area-style labels (`area/auth`, `frontend`, `billing`, `dashboards`), use those.
2. **Milestones** — if multiple PRs share a milestone, that milestone is likely a coherent theme; use it as a group.
3. **File paths touched** — as a fallback, group by top-level directory. `src/auth/*` → "Auth," `src/dashboards/*` → "Dashboards." Use `gh pr view <n> --json files` or `git diff --name-only` if needed.
4. **Inferred theme** — last resort, group by topic inferred from titles. Tag the section header `[inferred grouping]` so the user knows you guessed.

Aim for 2–5 groups. One mega-group means you under-grouped; ten micro-groups means you over-grouped.

### Step 5 — Skip noise

Filter out before writing:
- Dependabot / renovate / automated dependency PRs (unless a major version bump or one explicitly flagged)
- PRs with `chore:` prefix that only touch tooling, unless the tooling change is material
- PRs with empty descriptions and no linked issue and no diff context — list them in a "low-context merges" section at the end rather than inventing a story for them

Do not skip silently. Note the skip count in the output header.

## Output format

Markdown. Written to chat (not Notion). Structure:

### Header

```
# Weekly Recap — <start date> to <end date>

<N> PRs merged. <M> linked issues. <K> low-context merges deferred. <data source note if degraded>.
```

Keep this to two lines. The user wants to start reading the substance fast.

### Headline

One paragraph, 2–4 sentences. The "if you only read this" summary. Examples of what belongs here:
- The dominant theme of the week ("most of the week was auth and billing")
- Anything that shipped a Must from a discovery doc
- Anything externally visible / user-facing
- Anything that closed a long-running issue

This paragraph is the answer to "so what did we get done last week?" Optimize it for that question.

### By area

For each product area group, a section with:

```
## <Area name>

<One-sentence framing of what happened in this area this week.>

- **<PR title or short rephrase>** ([#<PR number>](<url>))
  Solved: <one sentence on the problem, drawn from linked issue or PR body>.
  <Optional second sentence on technical substance if it matters — e.g., "Refactored to remove the duplicate session check in the middleware."> If milestone exists: tagged to *<milestone title>*.

- ...
```

Rules:
- One bullet per PR, not per commit.
- "Solved" sentence is mandatory. If you genuinely cannot find the why, write `Solved: [no linked issue or PR description — context missing]` rather than inventing one.
- Milestone goes inline only if present. Don't fabricate epic structure.
- Two to five PRs per section is normal. If a section has one PR, consider whether it should be merged into another section. If a section has ten PRs, consider whether it should be split.

### Cross-cutting / notable

Optional section. Use only if there's something worth surfacing that doesn't fit cleanly in one area:
- A refactor that touched multiple areas
- A long-running issue that finally closed
- A breaking change or migration
- A reverted PR

Skip this section if there's nothing genuinely cross-cutting. Don't pad.

### Low-context merges

If any PRs were skipped from the main groups due to missing context, list them here as bare references, e.g.:

```
## Low-context merges
The following merged but had no linked issue and minimal PR description — listed for completeness:
- [#234](url) — "fix bug"
- [#241](url) — "update deps"
```

This honors the no-hallucination rule while still acknowledging the work happened.

### Closing line

One line at the end, conversational. Examples:
- "Solid auth-heavy week. Next: anything from the dashboards Should list waiting on the engineer brief."
- "Quiet week — three merges, all cleanup. Real work continues in the open PRs."

Don't force a closing line if nothing useful comes to mind. Better silent than performative.

## Asking the user questions

Almost never. The skill should run cleanly with defaults. The only question worth asking:

- If both `main` and `master` exist as branches and recent activity is on neither, ask which branch to read from.

Otherwise, run with defaults, state assumptions in the header, and produce the recap.

## What you do not do

- You do not list every commit. PRs only.
- You do not translate technical content into non-technical language. The user is technical.
- You do not invent problem statements when context is missing. You flag the gap.
- You do not include unmerged or work-in-progress items.
- You do not write to Notion. Output is chat-only.
- You do not ask for permission to start. Start.
- You do not skip the "Solved" line. If context is missing, say so explicitly per item.
