---
name: dotnet-tests
description: My style for writing .NET (C#) tests with TUnit, NSubstitute and Shouldly - scenario-named test methods that act, then call `ItShould...()` local functions holding the assertions. Use this skill whenever you write, add, extend, fix or review C# tests, set up a test project, add regression tests for a bug fix, or add unit, integration or HTTP (WebApplicationFactory) tests to a .NET solution - even if the user only says "add a test for this" or "cover this with tests" and never names the libraries or the style.
---

# .NET tests in my style

Tests read as a specification: the method name says **what situation** the code is in, and the `ItShould...` calls
say **what must be true** afterwards. Someone skimming a test class should be able to read the scenarios and their
expectations without parsing any assertion code.

**Stack:** TUnit runs the tests, Shouldly asserts, NSubstitute fakes dependencies. Don't introduce xUnit, NUnit, MSTest,
FluentAssertions, Moq or TUnit's own `Assert.That`. If a repo already uses something else, ask before converting it.

## The shape of a test

```cs
public sealed class WikiPathsTests
{
    private readonly string _wikiRoot;
    private readonly WikiPaths _paths;

    public WikiPathsTests()
    {
        IOptions<WikiConfigurationSettings> options = Substitute.For<IOptions<WikiConfigurationSettings>>();
        options.Value.Returns(new WikiConfigurationSettings { RootDirectory = "/data/kb" });
        _wikiRoot = Path.GetFullPath(options.Value.WikiDirectory);
        _paths = new WikiPaths(options);
    }

    [Test]
    [Arguments("../notes/new/note.md")]
    [Arguments("../wiki-backup/index.md")]
    public void APathLeavesTheWiki(string path)
    {
        bool resolved = _paths.TryResolve(path, out _);
        Exception? exception = Catch.Exception(() => _paths.Resolve(path));

        ItShouldBeRefused();
        ItShouldExplainTheRefusal();

        void ItShouldBeRefused() => resolved.ShouldBeFalse();

        void ItShouldExplainTheRefusal() => exception
            .ShouldBeOfType<InvalidOperationException>()
            .Message.ShouldBe($"The path '{path}' is outside the wiki. All paths must be relative to the wiki root.");
    }
}
```

The rules behind it:

- **One sealed `XxxTests` class per class under test.** Build the subject (and its substitutes) in the constructor
  and keep it in a `private readonly` field. TUnit creates a new instance per test, so the constructor is the setup
  and `IDisposable`/`IAsyncDisposable` is the teardown.
- **The method name is the scenario, never the expectation.** `ARecordIsBeingTracked`, `TheFactFinderFails`,
  `TwoNotesAreCapturedTogether`, `SomeoneWhoIsNotAllowedInCallsTheApi`. Not `Track_AddsAudit`,
  `ResolveThrowsWhenOutsideTheWiki` or `Returns404`. Write it as a short sentence in the present tense, from the
  domain's point of view. If you can't name the scenario without describing the outcome, the test is probably
  checking a pure function: name the input situation instead (`AnEmptyNoteIsCaptured`, `NoResultsAreZipped`).
- **The body arranges and acts, then only calls `ItShould...()`.** Every expectation is a local function named
  `ItShould<Expectation>` and declared *after* the calls. The calls read like a checklist; the functions hold the
  Shouldly assertions.
- **`ItShould...` functions only assert.** All acting happens before them, captured in locals the functions close
  over. If a function would need to call the subject, act first and store the result. For expected exceptions, use a
  small `Catch.Exception(...)` / `Catch.ExceptionAsync(...)` helper in the act step (see
  [references/setup.md](references/setup.md)) instead of `Should.Throw` inside an `ItShould`.
- **Several focused `ItShould` functions beat one big one.** Each names one expectation. Group closely related checks
  inside one function (`ShouldSatisfyAllConditions` helps) when they describe a single expectation.
- **Async is fine.** The test becomes `async Task`, and an `ItShould` that must await becomes `async Task` and is
  awaited: `await ItShouldReturnItsContent();`.
- **Parameterise with `[Arguments(...)]`** when several inputs share one scenario and the same expectations.

## Start from what the repo already has

Before writing anything, look at the existing test projects and the repo's agent docs (`AGENTS.md`, `CLAUDE.md`). Reuse
their fixtures and helpers, such as a `Catch` helper, a temporary-wiki or `WebApplicationFactory` fixture, fake agents
or an `Eventually` poller, and put each new test in the project and folder that mirrors the code under test. Write a
new fixture only for something genuinely new, and keep it next to the others.

## Unit tests and integration tests

Keep them in **separate projects**, because they make different promises:

- **Unit tests (`Xxx.Tests`) are pure:** no disk, network, clock, database or model calls. They should run in
  milliseconds and never flake. Substitute interfaces and abstract classes with NSubstitute. Sealed concrete classes
  can't be substituted: construct the real one when it is itself pure and cheap (with `NullLogger<T>.Instance`), or
  move the test to the integration project. Don't add an interface only to make one test possible without asking.
- **Integration tests (`Xxx.IntegrationTests`) run real code against real local resources:** a temporary directory,
  the app's real DI container, an in-process HTTP server. Only what reaches the outside world is replaced: model
  calls, third-party sign-in, Redis or other remote services. Read
  [references/integration.md](references/integration.md) before writing these; it covers fixtures, waiting for
  asynchronous work, fake agents and clocks, and `WebApplicationFactory`.

## When fixing a bug

Write the regression test first and **watch it fail without the fix** (stash the fix, run the test, restore it). A
test that passes either way protects nothing; say so honestly if you can't make it fail, for example a race that
won't reproduce locally.

## Lessons that save time

- **Shouldly's `ShouldContain` on strings ignores case by default.** Use distinctive fixture text: a check that a
  prompt does *not* contain "Wiki rules." fails if surrounding text mentions "wiki rules".
- **TUnit forbids assigning instance fields inside a test (analyzer TUnit0018).** Vary behaviour through constructor
  state, parameters or locals. Setting a property *on an object* the field holds is fine.
- **Local functions that capture nothing must be `static`** when `csharp_prefer_static_local_function` is a warning
  (often the case with warnings as errors). `ItShould` functions usually capture the act results, so it rarely bites.
- **Never use fixed sleeps to wait for work.** Poll for the outcome with a timeout (see the integration reference), and
  wait for the *outcome*, not a count of intermediate events, so an extra event fails a specific check instead of the
  wait.
- **Follow the repo's `.editorconfig`** for everything else: explicit types versus `var`, file-scoped namespaces,
  using order and line endings.

## Before you finish

Run the repo's own build, format and test commands (check `AGENTS.md`, `CLAUDE.md` or the CI workflow) and report the
real results. For a new test project, adding it to the solution, `InternalsVisibleTo`, central package versions,
lock files and the `dotnet test` runner setting are covered in [references/setup.md](references/setup.md).
