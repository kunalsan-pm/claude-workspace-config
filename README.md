# claude-workspace-config

Shared Claude Code configuration for the team: a global `CLAUDE.md` operating system, a set of specialist **agents** orchestrated by `@pm`, and reusable **skills** (slash commands). One install script symlinks everything into `~/.claude`, so a `git pull` keeps everyone on the same setup.

## What's inside

```
.
├── CLAUDE.md                     # Global operating rules (applies to main session + subagents)
├── install.sh                    # Symlinks CLAUDE.md, skills, and agents into ~/.claude
├── agents/                       # Subagent definitions
├── skills/                       # Slash-command skills (each in skills/<name>/SKILL.md)
└── .github/workflows/
    └── slack-notify.yml          # Posts to Slack when main changes
```

## Install

```bash
git clone https://github.com/kunalsan-pm/claude-workspace-config.git ~/claude-workspace-config
cd ~/claude-workspace-config
./install.sh
```

What `install.sh` does:

- **CLAUDE.md** — symlinks `~/.claude/CLAUDE.md` to this repo. An existing non-symlinked file is backed up to `CLAUDE.md.bak`.
- **Skills & agents** — symlinks each one individually into `~/.claude/skills/` and `~/.claude/agents/`. If you already have a personal skill or agent with the same name, it is **skipped**, not overwritten (delete yours to use the shared one).

### Update

```bash
cd ~/claude-workspace-config && git pull && ./install.sh
```

Because everything is symlinked, edits pulled from `main` take effect immediately; re-running `install.sh` only matters when new skills or agents are added.

## How it works

`CLAUDE.md` sets the defaults — smallest correct change, minimal diffs, plan only for multi-layer work, at most one clarifying question — and routes every non-trivial task through the `@pm` orchestrator.

```
                 ┌──────────────┐
  user request → │     @pm      │  classify → route → hand off (never does the work)
                 └──────┬───────┘
     upstream (only when load-bearing)          downstream
  @visionary → @discovery → @designer → @engineer  →  @implementer → @reviewer / @qa
                                                      @researcher (any time)
```

When upstream specialists run, `@pm` stops at a **validation gate** before implementation. Each specialist writes its artifact to `docs/features/<slug>/` (`vision.md`, `discovery.md`, `design-brief.md`, `engineering-brief.md`), and `@pm` synthesizes them into `prd.md` or `brief.md`. Reply "validated, proceed" to `@pm` to continue.

### Agents

| Agent | Role | Model |
|---|---|---|
| `pm` | Orchestrator — classifies every task and routes to the minimum set of specialists | sonnet |
| `visionary` | Rare. Product/company direction, north star, platform-level bets → `vision.md` | sonnet |
| `discovery` | Shapes unformed ideas via JTBD → Opportunity Solution Tree → MoSCoW | sonnet |
| `designer` | Written design briefs: IA, flows, interaction patterns, accessibility (no mockups) | opus |
| `engineer` | Written engineering briefs: architecture, dependencies, anti-overengineering rules (no code) | sonnet |
| `researcher` | Codebase, library, and pattern research; option and tradeoff analysis | sonnet |
| `reviewer` | Deep technical review: architecture, refactors, security, performance | sonnet |
| `qa` | Acceptance criteria, user journeys, regression risk, release readiness | sonnet |

> `CLAUDE.md` and the agents also reference an `@implementer`, which is not yet defined in `agents/`. Until it's added, implementation falls to the main session.

### Skills

| Command | Purpose |
|---|---|
| `/pm` | Product orchestrator — detects single / batch / epic intent, picks a workflow, runs step 1 |
| `/plan` | Execution-ready plan for a feature or task |
| `/research` | High-level concept research grounded in PM best practices |
| `/fix` | Minimal safe patch with root cause, risk, and verification |
| `/test` | Add regression-preventing tests |
| `/qa` | Product-level QA checklist |
| `/deep-review` | Full architecture / quality / test / performance audit for large or sensitive changes |
| `/recap` | Monday-standup recap of last week's merged work from git, PRs, and issues |
| `/bootstrap` | Scaffold a new repo with the Claude OS structure (`CLAUDE.md`, `.claude/skills`, standards, registries) |
| `/improve` | Promote durable patterns into `CLAUDE.md` and skills |

`/pm`, `/bootstrap`, and `/improve` are manual-only (`disable-model-invocation: true`); the rest can also be picked up automatically by Claude.

## Slack notifications

`.github/workflows/slack-notify.yml` posts a summary to Slack on every push to `main`, listing which of `CLAUDE.md`, skills, agents, or `install.sh` changed plus the update command.

Setup: add a repository secret **`SLACK_WEBHOOK_URL`** (Settings → Secrets and variables → Actions) containing a Slack incoming-webhook URL.

## Contributing

- Keep `CLAUDE.md` for durable, cross-project rules only; put task-specific procedure in a skill.
- New skill: `skills/<name>/SKILL.md` with frontmatter (`name`, `description`, optional `allowed-tools`, `argument-hint`).
- New agent: `agents/<name>.md` with frontmatter (`name`, `description`, `tools`, `model`), and register it in the agent tables in `CLAUDE.md` and `agents/pm.md` so `@pm` can route to it.
- Open a PR; merging to `main` notifies the team in Slack.
