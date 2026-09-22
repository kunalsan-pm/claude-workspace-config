---
name: deep-review
description: Full architecture, code quality, tests, and performance audit for large changes.
disable-model-invocation: false
allowed-tools: Read, Glob, Grep
argument-hint: "[feature, file, or area to review]"
---

# /deep-review

Use ONLY for:
- Large feature
- Refactor
- Security/performance work

## Review Sections

### 1. Architecture
- Boundaries
- Coupling
- Scaling risks
- Security surface

### 2. Code Quality
- Structure
- DRY violations
- Over/under engineering
- Error handling gaps

### 3. Tests
- Coverage gaps
- Missing edge cases
- Weak assertions

### 4. Performance
- N+1 risks
- Memory
- Hot paths
- Complexity

## For Each Issue

- Describe concretely.
- Give 2–3 options.
- Recommend one.
- Explain tradeoffs.

Stop after recommendations.
