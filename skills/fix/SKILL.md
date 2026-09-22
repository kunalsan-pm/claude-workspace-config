---
name: fix
description: Minimal safe patch with risk and verification.
disable-model-invocation: false
allowed-tools: Read, Glob, Grep
argument-hint: "[bug or broken behavior]"
---

# /fix

1. Define failing behavior.
2. Root cause (max 3).
3. Smallest safe fix.
4. Files changed.
5. Breakage risks.
6. Suggested tests.
7. Rollback note.

Output:
<fix>
...
</fix>
