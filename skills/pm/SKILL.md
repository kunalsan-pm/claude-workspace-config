---
name: pm
description: Product Orchestrator. Detects batch vs epic vs single-task intent, selects workflow from available skills, executes step 1, and lists next commands.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read
argument-hint: "[request or task list]"
---

# /pm — Product Orchestrator (batch + epic aware, manual deploy)

## Available Skills
- /plan
- /research
- /fix
- /test
- /qa
- /deploy
- /improve

## Modes
- SINGLE: one clear request
- BATCH: multiple mixed requests (bugs/improvements/small adds)
- EPIC: one large initiative needing milestones/workstreams

## Detection Heuristics

### BATCH Mode triggers (any 2+)
- Input contains an enumerated list of 3+ items (numbers, bullets, checkboxes)
- Items look like mixed intent (bug + tweak + add + change)
- Items touch multiple domains (UI + backend + copy + analytics, etc.)
- User explicitly says "here are X changes" / "multiple things" / "backlog"

### EPIC Mode triggers (any 2+)
- Mentions large initiative language: "epic", "initiative", "build X end-to-end", "new product/area"
- Requires milestones or phases (MVP → v2, rollout, migration)
- Multiple stakeholders/personas, or multiple systems involved
- Needs a success metric + rollout/validation plan
- User asks for "strategy", "roadmap", "operating model", "architecture"

### SINGLE Mode
- Default when neither BATCH nor EPIC triggers hit.

## Intent Classification (within chosen mode)
DISCOVER → /research
PLAN → /plan
IMPLEMENT → /plan (if big) or /fix (if small/bug)
DEBUG → /fix
QUALITY → /test or /qa
RELEASE-PREP → /deploy
SETUP/MAINTAIN → /improve

## Process
1) Detect mode: SINGLE vs BATCH vs EPIC.
2) Classify primary intent for the mode.
3) Select minimal workflow (max 5 steps).
4) Execute step 1 immediately using the relevant skill output protocol:
   - If BATCH: Step 1 is a structured breakdown + execute Task 1 using the right protocol.
   - If EPIC: Step 1 is a /plan-style epic plan with milestones + risks + validation.
   - If SINGLE: Step 1 uses the correct skill directly.
5) Print remaining steps explicitly as slash commands.
6) Never auto-call deploy operations. If deploying is relevant, suggest /deploy in "Next commands".

## Output
<pm>
Mode:
Intent:
Selected workflow:
Step 1 output:
Next commands:
</pm>

## Output Rules
- If executing /plan: embed only the <plan> block in "Step 1 output".
- If executing /research: embed only the <research> block in "Step 1 output".
- If executing /fix: embed only the <fix> block in "Step 1 output".
- If executing /test: embed only the <tests> block in "Step 1 output".
- If executing /qa: embed only the <qa> block in "Step 1 output".
- If executing /deploy: embed only the <deploy> block in "Step 1 output".
- Keep "Next commands" as explicit slash commands.

## Stop condition
Stop after listing next commands.
