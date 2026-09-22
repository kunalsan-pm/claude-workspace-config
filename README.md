# claude-workspace-config

My personal Claude Code setup as a product manager: a global `CLAUDE.md` with my working rules, eight specialist **agents** coordinated by a `@pm` orchestrator, and ten **skills** (slash commands) for planning, research, fixes, testing, QA and weekly recaps.

It's kept in one repo so I can run the same setup on any machine and share it with teammates. `install.sh` symlinks everything into `~/.claude`, so after a `git pull` every machine is up to date.

— Kunal Sanghani ([@kunalsan-pm](https://github.com/kunalsan-pm))

## What's inside

```
.
├── CLAUDE.md                     # Global operating rules (main session + subagents)
├── install.sh                    # Symlinks CLAUDE.md, skills, and agents into ~/.claude
├── LICENSE
├── agents/                       # 8 subagent definitions
│   ├── pm.md
│   ├── visionary.md
│   ├── discovery.md
│   ├── designer.md
│   ├── engineer.md
│   ├── researcher.md
│   ├── reviewer.md
│   └── qa.md
├── skills/                       # 10 slash-command skills, each in skills/<name>/SKILL.md
│   ├── pm/  plan/  research/  fix/  test/
│   └── qa/  deep-review/  recap/  bootstrap/  improve/
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

- **CLAUDE.md**: symlinks `~/.claude/CLAUDE.md` to this repo. If a regular (non-symlink) file is already there, it's backed up to `CLAUDE.md.bak` first.
- **Skills and agents**: symlinks each one individually into `~/.claude/skills/` and `~/.claude/agents/`. If a personal skill or agent with the same name already exists, it's **skipped**, not overwritten. Delete yours to use the shared one.

### Update

```bash
cd ~/claude-workspace-config && git pull && ./install.sh
```

Because everything is symlinked, changes pulled from `main` take effect immediately. Re-running `install.sh` only matters when a new skill or agent is added.

## How I work with it

`CLAUDE.md` sets the defaults: smallest correct change, minimal diffs, a short plan only for multi-layer work (UI + API + DB), and at most one clarifying question. Every non-trivial task goes to `@pm` first, which decides which specialists, if any, need to run.

```
                 ┌──────────────┐
  request   →    │     @pm      │  classify → route → hand off (never does the work itself)
                 └──────┬───────┘
    upstream (only when it matters)            downstream
  @visionary → @discovery → @designer → @engineer   →   @reviewer / @qa
                                                        @researcher (any time)
```

When upstream specialists run, `@pm` stops at a **validation gate** before any build work starts. Each specialist writes its output to `docs/features/<slug>/` (`vision.md`, `discovery.md`, `design-brief.md`, `engineering-brief.md`), and `@pm` combines them into `prd.md` or `brief.md`. Once I've reviewed them, I reply "validated, proceed" to `@pm`.

### Agents

| Agent | Role | Model |
|---|---|---|
| `pm` | Orchestrator. Classifies every task and routes it to the fewest specialists that can handle it | sonnet |
| `visionary` | Rarely used. Product or company direction, north star, platform-level bets → `vision.md` | sonnet |
| `discovery` | Shapes unformed ideas through JTBD → Opportunity Solution Tree → MoSCoW | sonnet |
| `designer` | Written design briefs: IA, flows, interaction patterns, accessibility (no mockups) | opus |
| `engineer` | Written engineering briefs: architecture, dependencies, rules against overengineering (no code) | sonnet |
| `researcher` | Concept, codebase and pattern research; option and tradeoff analysis | sonnet |
| `reviewer` | Deep technical review: architecture, refactors, security, performance | sonnet |
| `qa` | Acceptance criteria, user journeys, regression risk, release readiness | sonnet |

### Skills

| Command | Purpose |
|---|---|
| `/pm` | Product orchestrator. Detects single-task, batch or epic intent, picks a workflow and runs step 1 |
| `/plan` | Execution-ready plan for a feature or task |
| `/research` | High-level concept research grounded in PM best practices |
| `/fix` | Minimal safe patch with risk and verification |
| `/test` | Adds tests that catch regressions |
| `/qa` | Product-level QA checklist |
| `/deep-review` | Full architecture, code quality, test and performance audit for large changes |
| `/recap` | Monday-standup recap of last week's merged work from git history, PRs and issues |
| `/bootstrap` | Scaffolds a new repo with the Claude OS structure (`CLAUDE.md`, skills, standards, registries) |
| `/improve` | Promotes lasting patterns into `CLAUDE.md` and skills |

`/pm`, `/bootstrap` and `/improve` only run when I type them (`disable-model-invocation: true`). Claude can also pick up the others on its own.

## Slack notifications

`.github/workflows/slack-notify.yml` posts to Slack on every push to `main`. The message lists which of `CLAUDE.md`, skills, agents or `install.sh` changed, links the commit, and includes the update command.

Setup: add a repository secret named **`SLACK_WEBHOOK_URL`** (Settings → Secrets and variables → Actions) containing a Slack incoming-webhook URL.

## Adding to it

- Keep `CLAUDE.md` for lasting rules that apply across projects. Put task-specific steps in a skill.
- New skill: `skills/<name>/SKILL.md` with frontmatter (`name`, `description`, and optionally `allowed-tools`, `argument-hint`, `disable-model-invocation`).
- New agent: `agents/<name>.md` with frontmatter (`name`, `description`, `tools`, `model`). Add it to the agent lists in `CLAUDE.md` and `agents/pm.md` so `@pm` can route to it.
- Merging to `main` sends a Slack notification.

## License

[MIT](LICENSE)
