---
name: dotnet-testing-preferences
description: Use this skill whenever the user asks to write, improve, review, or extend tests in a .NET codebase (unit, integration, or end-to-end). Prefer this skill even when the request does not explicitly mention testing frameworks, because it encodes the required testing stack and structure - xUnit v3, NSubstitute, Shouldly, TestContainers, public-API-oriented verification, grouped expectation helpers, practical coverage targets, and C#-first output for .NET projects.
---

# Dotnet Testing Preferences

Use this skill to produce tests that match the user's preferred .NET testing style.

## Goals

- Write tests that validate behavior through public APIs.
- Keep tests readable and fast by grouping expectations under the same setup.
- Use realistic integration dependencies (real infra via containers) instead of fake in-memory providers.
- Mirror production structure and naming so test intent is obvious.

## Preferred Stack

- Framework: xUnit v3
- Mocking: NSubstitute
- Assertions: Shouldly
- External dependencies: TestContainers
- Integration host (when needed): WebApplicationFactory
- End-to-end: Playwright (often with Aspire to serve API/runtime)

## Trigger Cues

Apply this skill when the user asks for any of the following in a .NET context:

- Write tests for a class, handler, controller, endpoint, or feature.
- Add missing tests, improve coverage, or fix flaky tests.
- Create integration tests for API + persistence flows.
- Create end-to-end checks for user-visible behavior.
- Review testing strategy, naming, assertions, or organization.

If a prompt includes terms like "unit test", "integration test", "controller tests", "coverage", "NSubstitute", "Shouldly", "WebApplicationFactory", "Playwright", or "TestContainers", use this skill.

## Non-Negotiable Principles

1. Test behavior through public APIs. Do not design tests around private methods.
2. Prefer real dependencies for integration boundaries. Do not use in-memory database providers.
3. Keep expectations explicit and readable by calling helper methods in the Assert phase.
4. Mirror production structure: `Thing` maps to `ThingTests`.
5. Use `MethodName_StateUnderTest` test naming.
6. For .NET prompts, generate C# test code by default. Only generate JavaScript/TypeScript tests when explicitly requested.
7. Keep test names scoped to method plus state only. Do not append expected outcomes in the method name (for example `_PersistsOrderToPostgreSql`, `_Returns200`, `_Throws...`).

## Test Type Guidance

### Unit Tests

Use for isolated behavior in a class or method.

- Arrange only required inputs and test doubles.
- Act once.
- Assert through helper methods that each verify one expectation.
- Keep one behavioral scenario per test method.

### Integration Tests

Use for collaboration across layers (for example API + application + persistence).

- Use TestContainers for databases and external infrastructure.
- Use WebApplicationFactory only when an in-process HTTP host is needed.
- Validate externally visible outcomes (HTTP responses, persisted state, emitted effects).

### End-to-End Tests

Use for full user flow and runtime behavior.

- Use Playwright.
- In .NET projects, prefer Microsoft.Playwright with xUnit-style test organization.
- Do not switch to `@playwright/test` unless the user explicitly asks for JS/TS.
- Prefer testing real flows over implementation details.
- Validate key user outcomes and critical regressions.

## Coverage Expectations

- Domain layer: target full path coverage (100% of meaningful code paths).
- Application layer: cover behavior that is verifiable through public APIs.
- Non-public implementation details: only verify indirectly through public outcomes.

## Output Contract For Test Generation

When generating tests, produce output in this order:

1. Short test plan (what scenarios are covered and why).
2. Test code grouped by class under the mirrored naming convention.
3. Any test fixture/container setup code.
4. Brief note of what's intentionally not tested directly (private/internal details).

For .NET end-to-end requests, make the test code section C# by default and mention runtime assumptions (base URL, seeded test users/data, and CI/browser setup).

## Recommended Test Shape

```csharp
public class UserControllerTests
{
    private readonly UserController _controller;
    private readonly IAuditRepository _auditRepository;

    [Fact]
    public void GetUser_WithAValidUserId()
    {
        // Arrange
        long userId = 1;

        // Act
        UserResult result = _controller.GetUser(userId);

        // Assert
        ItShouldHaveValidUserId(result);
        ItShouldIncludeLastLoginDate(result);
        ItShouldHaveAuditedTheRequest(userId);
    }

    private static void ItShouldHaveValidUserId(UserResult result)
    {
        result.Id.ShouldBePositive();
    }

    private static void ItShouldIncludeLastLoginDate(UserResult result)
    {
        result.LastLoginDate.ShouldNotBeNull();
    }

    private void ItShouldHaveAuditedTheRequest(long userId)
    {
        _auditRepository
            .Received()
            .AuditRequest(new AuditStamp("GetUser", userId));
    }
}
```

## Generation Checklist

Before finalizing generated tests, verify:

- xUnit v3 attributes and style are used.
- Assertions use Shouldly.
- `Assert.*` is avoided when a Shouldly equivalent exists.
- Mocks/stubs use NSubstitute.
- No in-memory DB provider is introduced for integration tests.
- TestContainers are used when external dependencies are required.
- Naming follows `MethodName_StateUnderTest`.
- Method names do not include expectation/result suffixes (for example no `_Persists...`, `_Returns...`, `_Throws...`).
- Assertions are grouped via helper methods when they share context.
- Tests verify behavior via public APIs.
- End-to-end outputs for .NET prompts are in C# unless the user explicitly requests JS/TS.

## What To Avoid

- Testing private methods directly.
- Replacing integration dependencies with simplistic in-memory providers.
- Asserting too many unrelated concerns in one opaque assert block.
- Tight coupling of tests to implementation details that are not externally observable.
