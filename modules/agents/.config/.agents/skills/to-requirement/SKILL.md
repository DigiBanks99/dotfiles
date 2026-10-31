---
name: to-requirement
description: Turn the current conversation into a Requirement - the what and why, with business rules and acceptance criteria - and publish it to the project issue tracker. No interview, just synthesis of what you've already discussed.
disable-model-invocation: true
metadata:
  - author: Matt Pocock
  - local-fork: Forked from Matt Pocock's to-spec for the Requirement -> Spec -> Task model. Do not overwrite from upstream.
---

This skill takes the current conversation context and codebase understanding and produces a **Requirement**. Do NOT interview the user - just synthesize what you already know. If the conversation leaves the problem, the outcomes or the rules unclear, say so and suggest `/grill-me` first rather than guessing.

A Requirement answers **what and why**. It does not design the solution: domain, API and UI design, diagrams and test cases belong in the Specs that `/to-specs` breaks it into. If the Requirement has real unknowns, run `/wayfinder` with this Requirement as the source before slicing it into Specs.

The issue tracker is the repository's own (GitHub, via `gh`). Readiness is signalled the way the repository's `AGENTS.md` says (a `Ready signal:` line); without one, apply the `ready-for-agent` label.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout, and respect any ADRs in the area you're touching.

2. Write the Requirement using the template below and publish it to the issue tracker. Only mark it ready when it has no open questions: a Requirement that still needs wayfinding or grilling is not ready for `/to-specs`. Tell the user which next step applies (`/grill-me`, `/wayfinder` or `/to-specs`).

<requirement-template>

## Problem

The problem the user is facing, from the user's perspective, and why it matters.

## Users

Who is affected, as actors.

## Outcomes

What is true when this is solved, from the user's perspective.

## Business Rules

The rules, constraints and policies the solution must respect.

## Acceptance Criteria

- [ ] Observable criteria that decide whether the Requirement is met, each verifiable without knowing the implementation

## Out of Scope

What this Requirement deliberately does not cover.

## Further Notes

Anything else worth knowing: links, prior art, open risks.

</requirement-template>

Do NOT include specific file paths or code snippets. They go stale quickly.
