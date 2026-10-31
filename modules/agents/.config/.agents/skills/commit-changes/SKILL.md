---
name: commit-changes
description: >
  Commit local repository changes as atomic conventional commits, link issues in the
  commit body, and push the finished work. Use this skill whenever the user asks to
  commit, save and push, push this up, create a commit, publish their work, save their
  progress, or persist their work, and be proactive when they indicate they are done
  implementing something. Trigger even when they do not say "commit" explicitly,
  including prompts like "done for today", "all tests pass now", "time to push this",
  "ship this", or "save my progress" after a feature, fix, refactor, migration, or test
  update. It describes my preferred commit procedure and message format. Do not use this
  skill for git status/diff inspection, branching, merging, rebasing, stashing,
  cherry-picking, reverting, unstaging, or pull-request creation unless the user is also
  asking to commit their current work.
---

Changes are committed as atomic units of work, each with a conventional commit message.

## Repo overrides

Before committing, check the repo's `AGENTS.md` (and `CLAUDE.md`) for commit rules. The
defaults below apply unless the repo says otherwise:

- **Branch:** never commit on `main`. If on `main`, create or ask for a branch first. A repo
  may explicitly allow commits to `main`.
- **Push:** push once all commits are made. A repo may say not to push.

## Procedure

1. Check the repo's overrides, then ensure the current branch is allowed (not `main` by
   default). One branch can hold many commits; do not create a branch per commit.
2. Identify all the files that have been changed. Use subagents to assist if the change is
   large.
3. Determine the units of work.
4. For each unit of work:
   1. stage only what belongs to that unit (see Staging)
   2. write the commit message (see Message format)
   3. link the issue(s) if an issue tracker is being used
5. Push the commits to the remote once all of them have been made (unless overridden).

## Staging

- Stage whole files per unit with `git add <paths>` when each file belongs to one unit.
- When a file mixes units, stage only the unit's lines with a patch: run `git diff <file>`,
  keep the hunks (edit them if needed) for that unit in a patch file, and apply it with
  `git apply --cached <patch>`. Check with `git diff --cached`.
- Do not use `git add -p` or `git add -i`: they need a terminal. Piping answers into
  `git add -p` is a fragile last resort.

## Message format

1. Title: `<type>(<scope>): <description>`, e.g. `feat(auth): add login functionality`.
2. The title is lower-case and at most 50 characters.
3. Every commit has a body. It explains the intent and the reason for the change, not just
   what was changed, so others understand it without reading the code.
4. Wrap the body at 72 characters.
5. If the commit has a breaking change, add a section describing it and how to address it.
6. Reference issues in the body, e.g. `Fixes #123` or `Implements #456`. If a commit relates
   to a previous commit, say so (e.g. `Relates to #456`).
7. Avoid vague messages like "fix bug" or "update code".

## Important

- Never create merge commits (multiple parents). Rebase or cherry-pick instead, and prefer
  rebase over merge for upstream changes.
- Keep changes focused. Split unrelated changes into separate commits.
