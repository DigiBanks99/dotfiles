# Setting up a test project

## Project file

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <!-- TUnit.Core and TUnit.Engine rather than the TUnit package, which also brings TUnit's assertions: Shouldly
       is the assertion library. -->
  <ItemGroup>
    <PackageReference Include="NSubstitute" />
    <PackageReference Include="Shouldly" />
    <PackageReference Include="TUnit.Core" />
    <PackageReference Include="TUnit.Engine" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\My.Project\My.Project.csproj" />
  </ItemGroup>

</Project>
```

- Reference `TUnit.Core` and `TUnit.Engine`, not the `TUnit` meta-package, so TUnit's assertions don't sit beside
  Shouldly.
- With central package management, versions go in `Directory.Packages.props` only. Look up current versions
  (`dotnet package search <id> --exact-match`) rather than guessing. Pick versions consistent with the repo, such as
  matching ASP.NET Core patch versions.
- If the repo commits `packages.lock.json`, run `dotnet restore` (not in locked mode) after adding packages and include
  the new or changed lock files.
- Add the project to the solution (`.sln` or `.slnx`).

## `GlobalUsings.cs`

```cs
global using NSubstitute;

global using Shouldly;
```

Add the main project's own common global usings too (for example `CSharpFunctionalExtensions`) when the subject's API
uses them heavily. Leave out `NSubstitute` in a project that doesn't substitute anything.

## Testing internal types

In the project under test:

```xml
<ItemGroup>
  <InternalsVisibleTo Include="My.Project.Tests" />
  <!-- Lets NSubstitute proxy internal types. -->
  <InternalsVisibleTo Include="DynamicProxyGenAssembly2" />
</ItemGroup>
```

A public test class can't expose an internal type publicly, so keep fixtures that inherit from or return internal types
`internal` (for example `internal sealed class TestApi : WebApplicationFactory<Program>`).

## Running the tests

TUnit runs on Microsoft.Testing.Platform. On the .NET 10 SDK, `dotnet test` needs this in `global.json`:

```json
{
  "test": {
    "runner": "Microsoft.Testing.Platform"
  }
}
```

Then:

```shell
dotnet test --solution My.slnx --no-build --configuration Release
dotnet test --project src/My.Project.Tests --treenode-filter "/*/*/WikiPathsTests/*"   # one class
```

Add the test step to CI after the build, and to the repo's `AGENTS.md`/`CLAUDE.md` command list.

TUnit runs tests **in parallel by default**. Give every test its own state (its own temporary directory, its own host)
rather than sharing static or file-system state.

## The `Catch` helper

Acting and asserting stay separate even when the act throws:

```cs
/// <summary>
/// Captures what an action throws, so a test can act first and leave the <c>ItShould...</c> checks to assert on the
/// outcome.
/// </summary>
internal static class Catch
{
    public static Exception? Exception(Action action)
    {
        try
        {
            action();
            return null;
        }
        catch (Exception ex)
        {
            return ex;
        }
    }

    public static async Task<Exception?> ExceptionAsync(Func<Task> action)
    {
        try
        {
            await action();
            return null;
        }
        catch (Exception ex)
        {
            return ex;
        }
    }
}
```

Then assert with `exception.ShouldBeOfType<InvalidOperationException>().Message.ShouldBe(...)`, or
`exception.ShouldBeNull()` for "it should succeed".
