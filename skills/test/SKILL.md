---
name: test
description: Add regression-preventing tests.
disable-model-invocation: false
allowed-tools: Read, Glob, Grep
argument-hint: "[function, component, or behavior to test]"
---

# /test

1. Identify risk surface.
2. Choose test level.
3. Write:
   - Happy path
   - 2 edge cases
   - 1 failure case
4. Provide run command.

Output:
<tests>
...
</tests>
