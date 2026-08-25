---
name: review
description: |
  Manually-invoked code review. Triggered by `/review`, "review this",
  "review the changes", "code review", or similar. Default scope is unstaged
  working-tree changes; scope can be overridden with `staged`, `HEAD`/`last`,
  a branch name, or a commit SHA. Reviews any changed code regardless of
  author. Outputs findings grouped by severity with file:line citations; does
  not edit or rewrite code.
---

# Review

Review code changes. Cite file:line. Do not edit, fix, or rewrite — only point at issues.

Style matches the rest of your skills: short replies, no emojis, no filler, ground every claim.

## Scope

Determine what to review. If the user gave no scope argument, use **unstaged working-tree changes**.

| User says | Scope | Command |
|---|---|---|
| (none) / "review" | Unstaged | `git diff` |
| `staged` | Staged | `git diff --cached` |
| `HEAD` / `last` / "last commit" | Last commit | `git diff HEAD~1` |
| `<branch>` / "this branch" / "branch changes" / "feature branch" | Branch vs default | `git diff <default>...HEAD` |
| `<sha>` / "commit abc123" | Specific commit | `git show <sha>` |

If the requested scope resolves to nothing (e.g. `/review` with a clean working tree), say so and ask which scope they meant. Do not silently fall back to staged or HEAD.

If the directory is not a git repo or git is unavailable, ask the user to paste the diff or name the files.

## How to review

For each scope:
1. Read every changed file in full before commenting. A diff alone is not enough — you need context.
2. If the diff is large (rough threshold: >20 files or >1000 changed lines), ask the user if they want a summary pass or a focused review on specific files.
3. Look for issues in this order:
   - Correctness (bugs, off-by-one, wrong assumptions, async/race)
   - Edge cases (empty, null, boundary, overflow, error paths)
   - Security (injection, authn/authz, secrets, validation, deserialization)
   - Performance (hot paths, allocations, redundant network calls, N+1)
   - API and data shape design (does the new contract fit existing consumers?)
   - Tests (does coverage match risk? are edge cases exercised?)
   - Style and conventions — only if the project has clear conventions. Skip otherwise.
4. Skip nitpicks. Surface things that matter. If a section has no findings, omit it.
5. If the change is clean, say so explicitly. Do not invent findings to fill space.

## Output format

Lead with the worst finding. Keep total output short.

```
**Summary:** one or two lines on what this change does at a high level.

**Blocking:** correctness, security, data loss.
- path/to/file.ts:42 — one-sentence issue + suggested approach (prose, not code)

**Should fix:** edge cases, design, performance, missing tests.
- path/to/file.ts:118 — issue + suggested approach

**Nice to have:** style, naming, docs — only if the project has clear conventions.
- path/to/file.ts:7 — issue + suggested approach
```

Suggested approaches are prose. Short illustrative snippets are fine only if a concept is genuinely unclear in prose — never multi-line rewrites.

## Out of scope

- Implementing fixes. The user is the driver; they will make changes.
- Architectural redesign. If the change reveals a deeper design problem, name it and stop — do not redesign.
- Reviewing code outside the requested scope.

## Cross-agent review

This skill works the same way regardless of who wrote the code. If the user pastes another agent's diff or says "review what the other agent produced", treat it as ordinary code: read it, find issues, cite file:line. Do not comment on the author's process or choices — only on the code.