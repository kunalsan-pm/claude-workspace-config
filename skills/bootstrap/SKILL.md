---
name: bootstrap
description: Scaffold this repo with the Builders Camp Claude OS (CLAUDE.md, skills, standards, registries). Use for new projects.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Glob, Write
argument-hint: "[refresh?]"
---

# /bootstrap — initialize repo Claude OS

## What this does
Creates (if missing) the standard Claude OS structure in the current repo:
- CLAUDE.md
- .claude/skills/*/SKILL.md
- .claude/standards/*.md
- .claude/qa-registry.md
- .claude/rule-candidates.md

## Process
1) Check if files already exist.
2) Create missing files only (do not overwrite).
3) If user explicitly says "refresh":
   - show a short summary of what will change
   - then overwrite the target files
4) Keep files concise; do not duplicate CLAUDE.md rules inside skills.
5) After scaffolding, list what was created and what was skipped.

## Output
<scaffold>
Created:
Skipped:
Notes:
</scaffold>

## Stop condition
Stop after "Notes".
