---
name: to-specs
description: Break a Requirement (or a plan, or the current conversation) into Spec sub-issues - tracer-bullet vertical slices that each fit one PR - with optional Tasks and blocking edges, published to the configured tracker using native sub-issue and blocking links.
disable-model-invocation: true
metadata:
  - author: Matt Pocock
  - local-fork: Forked from Matt Pocock's to-tickets for the Requirement -> Spec -> Task model. Do not overwrite from upstream.
---

# To Specs

Break a **Requirement** (or a plan or conversation) into a set of **Specs** - tracer-bullet vertical slices, each declaring the Specs that **block** it. A Spec answers **how**, for one slice: the domain, API and UI design, diagrams and test cases. Each Spec is a user story or deliverable section of the Requirement.

A Spec may be broken into **Tasks** (sub-issues of the Spec, each one unit of work with a checklist), but only when needed.

The issue tracker is the repository's own (GitHub, via `gh`). Readiness is signalled the way the repository's `AGENTS.md` says (a `Ready signal:` line); without one, apply the `ready-for-agent` label.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a Requirement number or URL, a path) as an argument, fetch it and read its full body and comments.

**Check the fog first.** If the Requirement still has unresolved unknowns - open questions, areas needing research or a proof of concept - stop and suggest `/wayfinder` (or `/grill-me`). Draft Specs only from a Requirement with no unresolved fog, or from a Requirement whose wayfinder map is closed. Read the closed map's Decisions so far and the tickets they link: those decisions feed the Specs.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** Specs.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) - vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each Spec is finishable in **one pull request** that merges to the default branch on its own. If it is too big for that, split it into **Tasks**, one PR each. Never rely on a long-lived integration branch
- A slice that is not user-visible yet ships behind a feature flag or as dark code, so it can still merge
- Any prefactoring should be done first

</vertical-slice-rules>

Give each Spec its **blocking edges** - the other Specs that must complete before it can start. A Spec with no blockers can start immediately. Do the same between Tasks of one Spec.

List each Spec's **decisions**: every choice its implementation depends on (approach, packaging, where a file or setting lives, what happens on failure, which environments it must work in). Each decision must be answered in the Spec or its Requirement, so the agent that picks it up in a fresh context never has to stop and ask. Anything you can't answer from the conversation or the code is an **open decision**: bring it to the quiz in step 4 rather than leaving it for the implementer.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change - rename a column, retype a shared symbol - whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand-contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own Task or Spec blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, blocked by every migrate batch.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each Spec, show:

- **Title**: short descriptive name
- **Blocked by**: which other Specs (if any) must complete first
- **What it delivers**: the end-to-end behaviour this Spec makes work
- **Tasks**: the Tasks it splits into, if any, and why
- **Open decisions**: any decision from step 3 that is still unanswered

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct - does each Spec only depend on Specs that genuinely gate it?
- Should any Specs be merged or split further?
- How should each open decision be settled?

Iterate until the user approves the breakdown and no open decisions remain.

### 5. Publish to the configured tracker

Publish the approved Specs in dependency order (blockers first) so blocking edges can reference real identifiers:

- Create each Spec as an issue and attach it to the Requirement as a **sub-issue** using the native `sub_issues` API (`gh api repos/{owner}/{repo}/issues/<requirement>/sub_issues -F sub_issue_id=<id>`; the id is the issue's database id, not its number).
- Create each Task the same way, as a sub-issue of its Spec.
- Express blocking with the native dependency relationship (`gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by -F issue_id=<id>`). If the tracker has no native blocking, set each issue's "Blocked by" section instead.
- If the Requirement has a closed wayfinder map, link it from each Spec's `## Requirement` section.
- Mark each ready per the repository's ready signal (label by default), unless instructed otherwise.

Work the **frontier**: any Spec or Task whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify the Requirement.

<spec-template>

## Requirement

A reference to the parent Requirement, and the closed wayfinder map if there is one.

## What to build

The end-to-end behaviour this Spec makes work, from the user's perspective - not layer-by-layer implementation.

## Design

The domain, API and UI design for this slice, with diagrams where they help. Name the seams at which it is tested.

## Decisions

Each decision the implementation depends on, with its answer and the reason, or "None beyond the Requirement". Decisions recorded in the Requirement or the map may be referenced rather than repeated.

## Test cases

The behaviours to verify, through the named seam.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking Spec, or "None - can start immediately".

</spec-template>

<task-template>

## Spec

A reference to the parent Spec.

## Checklist

- [ ] One unit of work
- [ ] ...

## Blocked by

- A reference to each blocking Task, or "None - can start immediately".

</task-template>

Avoid specific file paths or code snippets - they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts - not a working demo, just the important bits.
