---
name: commit-plan-from-diff
description: >
  Use when the user wants to split uncommitted changes into multiple commits,
  or asks for a commit plan, split commits, or commit strategy.
  Triggers on: split commits, plan commits, how should I commit, split diff,
  help me commit, organize commits
allowed-tools: Bash, Read
---

# Commit Plan From Diff

## Commit message format (mandatory)

```text
type(featureName): concise subject in imperative mood
```

- **type**: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `build`
- **featureName**: **camelCase** short scope (e.g. `recipient`, `transferFlow`)
- Full first line ≤ ~72 characters

Body on separate lines — what changed and why. When the work maps to a Jira story, add `Ref: MSME-XXXX` as the last body line (optional otherwise):
```text
feat(recipient): add bank picker from get banks API

- Wire get banks response into recipient form.
- Show localized error state on fetch failure.

Ref: MSME-1234
```

## Git write safety (mandatory)

**Default flow:**
1. Inspect with read-only git (`git status`, `git diff`, `git diff --stat`)
2. Output full **Commits detail** (see below) — never vague placeholders
3. Ask: *"Reply **confirm** to have me stage and create these commits in order."*
4. **Only after explicit confirm** — run `git add` and `git commit` per commit in order
5. If user does not confirm in same turn — stop, do not commit

## Workflow

1. **Inspect**: `git status -s`, `git diff`, `git diff --stat`, `git diff --staged`

2. **Group changes**: data/API · domain · UI · routing · tests · generated code · deletions

3. **Order commits (dependency-first)**:
   DTOs/domain → repository+fakes → services/providers → UI/controllers → routing → entry points → cleanup → tests

4. **Split rules**:
   - Keep `*.dart` and its generated `*.g.dart` in the **same** commit (project ไม่ใช้ `freezed`)
   - Small independent issues (copy fix, mock data refresh, standalone bug) → own commit **before** main feature
   - Deletions go **after** replacement exists

5. **Commits detail** (required in every response):

For each commit (oldest first):
- **Title**: `type(featureName): subject`
- **Description**: what changed and why
- **Files**: `(new)` / `(modified)` / `(deleted)` with generated peers
- **Rationale**: one line why this is separate
- **Commands**: exact `git add …` and `git commit` with HEREDOC

After list: **Verify** (`flutter analyze` / `flutter test`) and **Execution note**.

## After user confirms

1. Re-run `git status`/`git diff` to ensure tree matches plan
2. For each commit: stage listed files, commit with agreed title+body
3. Run Verify
4. Show `git log` of new commits

## Anti-patterns to flag

- Splitting generated code from its source
- UI commits before the APIs they import
- Vague titles without a clear `featureName`
- Burying small independent issues inside a feature commit
