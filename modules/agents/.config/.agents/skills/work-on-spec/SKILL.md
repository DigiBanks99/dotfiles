---
name: work-on-spec
description: Implement one unit of a Spec end to end - a Task when the Spec has Tasks, otherwise the Spec itself. Check its blockers, plan against its acceptance criteria, implement, run the CI checks, review, commit and open a pull request to the default branch. Use when the user says "work on #24", "implement spec 24", "pick up the next spec" or invokes /work-on-spec.
disable-model-invocation: true
argument-hint: <issue number | "next">
metadata:
  - author: Matt Pocock
  - local-fork: Forked from Matt Pocock's implement and the earlier work-on-ticket for the Requirement -> Spec -> Task model. Do not overwrite from upstream.
---

# Work on Spec

Implement one unit of work from the issue tracker as one focused branch and one pull request that merges to the default branch. The unit is a **Task** when the Spec has Tasks (one Task per run, one PR per Task), otherwise the **Spec** itself. The issue you work is the source of truth: its acceptance criteria or checklist define done, its Spec supplies the design and decisions, and the Requirement supplies the what and why.

There is no integration branch. Every PR targets the default branch and must be mergeable on its own; work that is not user-visible yet ships behind a feature flag or as dark code.

Argument: `$ARGUMENTS`, an issue number (`24`, `#24`) or `next`.

## 1. Load the work

Readiness is signalled the way the repository's `AGENTS.md` says (a `Ready signal:` line, for example a Project "Ready" status); without one, it is the `ready-for-agent` label. Wherever this skill says "ready", it means that signal.

1. If the argument is `next`, find the ready, open Tasks and Specs (`gh issue list --label ready-for-agent --state open --json number,title`, or the Project query the repository names), keep those whose blockers are all closed (step 2), prefer a Task over its parent Spec, and pick the lowest number. If none qualify, say so and stop.
2. Read the issue in full: `gh issue view <n> --comments`.
3. Walk up the hierarchy and read each parent: a Task's Spec, then the Spec's Requirement (`gh issue view <parent>`; find parents with `gh api repos/{owner}/{repo}/issues/<n>/parent`, or the `## Spec` / `## Requirement` section). If the Requirement has a closed wayfinder map, read its Decisions so far. Use the parents for context and decisions, but implement only this issue's scope.
4. If the issue is a Spec that has open Tasks, do not work the Spec itself: pick its next unblocked Task instead.
5. Read the repository's agent guidance (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, whichever exist) and find the commands CI runs (the guidance, else the CI workflow files). Those conventions and commands are binding.

## 2. Check blockers

Read the native blocking relationships:

```shell
gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by --jq '.[] | {number, state, title}'
```

Also check any `#n` listed under the issue's `## Blocked by` section. If any blocker is still open, stop and report which ones. Do not start blocked work, even partially.

## 3. Prepare the branch

1. Make sure the working tree is clean. If it isn't, stop and ask: never stash or discard someone's changes.
2. Update the default branch (`git switch main && git pull --ff-only`).
3. Create a branch named `<type>/<n>-<short-slug>`, with the Conventional Commits type that fits the work (`feat`, `fix`, `refactor`, ...), e.g. `refactor/24-run-completion-observers`.
4. If the user asked for parallel work, or another session is using this checkout, use a git worktree instead of switching branches here.
5. If the default branch is not `main`, use the repository's default branch wherever this skill says `main`.

## 4. Plan

1. Explore the code the issue touches. Prefer existing seams and patterns named in the Spec's design and test cases.
2. List every decision the plan depends on that the issue's `## Decisions`, its parents and the repository guidance don't settle. Ask them all in one round (a single question tool call or message), each with the context the user needs and your recommendation. Don't drip questions across the session, and don't start planning around a guess.
3. Enter plan mode and write a plan that maps **every acceptance criterion** (or checklist item) to the change and the test that satisfies it. Call out any criterion that can't be verified in this environment, such as needing external services, deployment infrastructure, real secrets or interactive sign-in.
4. Wait for the user to approve the plan. If the issue is ambiguous or contradicts its Spec, the Requirement or `AGENTS.md`, ask here rather than guessing.

## 5. Implement

- Follow the repository's guidance: conventions, dependency rules (lock files, package managers, central versioning) and any rules about configuration, deployment or secrets.
- Write tests in the repository's existing style; for .NET use the `dotnet-tests` skill. Test external behaviour through the seam the Spec names.
- Stay inside the issue. If you find work outside its scope, note it for the report instead of doing it.
- Keep secrets and personal content out of the repository, especially when it is public.

## 6. Verify

Run every CI command that applies to what changed (all of them when in doubt). Fix failures until everything passes, without weakening or skipping checks. If a formatter's verify step fails, run the formatter and review the diff.

Then go through the acceptance criteria (or checklist) one by one. Each is either met (say how it was verified) or explicitly not verifiable here (say why and what the user should check).

## 7. Review

Invoke the `code-review` skill on the branch's diff and fix confirmed findings. Re-run the step 6 commands if anything changed.

## 8. Commit and open the pull request

1. Commit with the `commit-changes` skill. Split unrelated changes into separate commits, and reference the issue in the body (`Implements #<n>`).
2. Push the branch and open a pull request to the default branch:
   - Title: the main commit's Conventional Commits title.
   - Body: a short summary, the acceptance criteria or checklist ticked for what was verified (with a note on anything left for the user to verify), and `Closes #<n>` so merging closes the issue and unblocks its dependents.
3. Do not merge the pull request. Do not edit or close any other issue. When this PR closes the last open Task of a Spec, add `Closes #<spec>` to the PR body as well, so merging closes the Spec; the Requirement is closed by the user.

## 9. Report

Give the user the PR link, which criteria were verified and how, anything they must verify themselves, any out-of-scope follow-ups noticed, which Tasks or Specs this one unblocks once merged, and the next unblocked item if there is one.
