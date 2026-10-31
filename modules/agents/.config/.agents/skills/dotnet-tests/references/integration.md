# Integration and HTTP tests

Contents: [Fixtures](#fixtures-over-a-temporary-directory) · [Waiting](#waiting-for-asynchronous-work) ·
[Fake agents](#fake-agents-and-other-outside-services) · [Clocks](#clocks) · [Diagnostics](#make-timeouts-explain-themselves) ·
[HTTP tests](#http-tests-with-webapplicationfactory) · [File watchers](#file-watchers-and-linux)

The aim is real code over real local resources, with only the outside world replaced, and still deterministic.

## Fixtures over a temporary directory

Each test gets its own directory and its own instance of the app's services, so tests can run in parallel.

```cs
internal sealed class TemporaryDirectory : IDisposable
{
    public string Path { get; } = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "my-tests", Guid.NewGuid().ToString("N"));

    public TemporaryDirectory() => Directory.CreateDirectory(Path);

    public void Dispose()
    {
        // A background handler can still be finishing with a file; a leftover temporary directory is harmless.
        try { Directory.Delete(Path, recursive: true); }
        catch (IOException) { }
        catch (UnauthorizedAccessException) { }
    }
}
```

To get the app's real services without a web server, build them with the app's own registration extensions:

```cs
WebApplicationBuilder builder = WebApplication.CreateEmptyBuilder(new WebApplicationOptions());
builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?> { ["Wiki:RootDirectory"] = _root.Path });
builder.Services.AddLogging(logging => logging.AddProvider(_problems));   // see diagnostics below
builder.Services.AddSingleton<IServer, NoServer>();   // Build() wants a server even if nothing listens
builder.Services.AddSingleton<TimeProvider>(new AcceleratedTimeProvider(10));
builder.AddMyFeatures();                              // the same extension methods Program calls
_app = builder.Build();
```

`NoServer` is a tiny `IServer` whose `StartAsync` throws `NotSupportedException`. Expose `Get<T>()` for services, and a
`Start()` that runs the same startup code as `Program` (for example `app.UseWiki()`). Laying out files *before*
`Start()` then simulates a restart, which is how to test recovery from interrupted work.

Assert on observable state, such as which folder a file ended up in, what a store returns, or the HTTP response,
rather than on internals.

## Waiting for asynchronous work

Background work (watchers, queues, hosted services) finishes on its own schedule. Poll for the outcome with a generous
timeout; never `Task.Delay` a fixed amount and hope.

```cs
internal static class Eventually
{
    private static readonly TimeSpan PollInterval = TimeSpan.FromMilliseconds(50);
    private static readonly TimeSpan DefaultTimeout = TimeSpan.FromSeconds(15);

    public static Task<bool> Until(Func<bool> condition, TimeSpan? timeout = null) =>
        Until(() => Task.FromResult(condition()), timeout);

    public static async Task<bool> Until(Func<Task<bool>> condition, TimeSpan? timeout = null)
    {
        TimeSpan limit = timeout ?? DefaultTimeout;
        Stopwatch elapsed = Stopwatch.StartNew();
        while (elapsed.Elapsed < limit)
        {
            if (await condition()) return true;
            await Task.Delay(PollInterval);
        }

        return await condition();
    }
}
```

The wait is part of acting; its result is asserted like anything else:

```cs
bool settled = await Eventually.Until(() => FileNames(settings.ProcessedNotesDirectory).Count == 1);

ItShouldFinish();
ItShouldFileTheNoteAsProcessed();

void ItShouldFinish() => settled.ShouldBeTrue(pipeline);   // pipeline = a description, see below
```

Wait for the **outcome** (the note is processed, the request is completed), not for an exact number of intermediate
events. If a component misbehaves by doing something twice, an exact-count wait times out with no explanation, while an
outcome wait finishes and the specific `ItShould...` check (for example "the Editor ran once") fails with the real count.

To check that something does *not* happen yet, wait a short bounded time and assert the result was false:
`bool handledWhileOpen = await Eventually.Until(() => handled.Any(), TimeSpan.FromMilliseconds(750));`.

## Fake agents and other outside services

Replace the boundary, not the logic behind it. For an LLM agent (for example a Microsoft Agent Framework `AIAgent`),
write a small fake subclass whose behaviour each test scripts, usually by calling the agent's **real tools**, so
everything downstream of the model runs for real:

```cs
internal sealed class FakeAgent(string name) : AIAgent
{
    private readonly ConcurrentQueue<string> _prompts = new();
    public override string Name => name;
    public IReadOnlyCollection<string> Prompts => _prompts;
    public Func<string, CancellationToken, Task<string>> Behaviour { get; set; } = (_, _) => Task.FromResult("Nothing to do.");

    protected override async Task<AgentResponse> RunCoreAsync(IEnumerable<ChatMessage> messages, AgentSession? session = null,
        AgentRunOptions? options = null, CancellationToken cancellationToken = default)
    {
        string prompt = string.Join('\n', messages.Select(message => message.Text));
        _prompts.Enqueue(prompt);
        return new AgentResponse(new ChatMessage(ChatRole.Assistant, await Behaviour(prompt, cancellationToken)));
    }

    // Streaming and session members throw NotSupportedException unless a test needs them.
}
```

Register fakes after the real registrations (last registration wins), for example
`services.AddKeyedSingleton<AIAgent>(name, fake)`. If the real agent has middleware, such as tool-call recording, give
the fixture a helper that calls a tool the same way, so runs look as they would in production. Share common scripts
(`wiki.FactFinderWritesFacts("collection")`, `agent.Fails("message")`) as extension methods.

## Clocks

Production code should take an injected `TimeProvider` for both `GetUtcNow()` **and** delays
(`Task.Delay(delay, timeProvider, token)`, `PeriodicTimer(interval, timeProvider)`). Then tests choose the clock:

- **Accelerated clock**, for pipelines with debounces, polls and retries: real time, but timers run N times faster.
  The order and proportions stay the same, so behaviour such as "events within one debounce coalesce" still holds,
  and no test has to advance anything by hand.

  ```cs
  internal sealed class AcceleratedTimeProvider(int factor) : TimeProvider
  {
      public override ITimer CreateTimer(TimerCallback callback, object? state, TimeSpan dueTime, TimeSpan period) =>
          new AcceleratedTimer(this, TimeProvider.System.CreateTimer(callback, state, Scale(dueTime), Scale(period)));

      private TimeSpan Scale(TimeSpan interval) =>
          interval <= TimeSpan.Zero || interval == Timeout.InfiniteTimeSpan ? interval : interval / factor;

      private sealed class AcceleratedTimer(AcceleratedTimeProvider provider, ITimer timer) : ITimer
      {
          public bool Change(TimeSpan dueTime, TimeSpan period) => timer.Change(provider.Scale(dueTime), provider.Scale(period));
          public void Dispose() => timer.Dispose();
          public ValueTask DisposeAsync() => timer.DisposeAsync();
      }
  }
  ```

  Choose a factor that keeps windows meaningful. A 5 s debounce at ×10 is 500 ms, enough for a burst of writes to land
  inside it on a slow CI runner; ×100 (50 ms) would make coalescing flaky.

- **Fake clock** (`Microsoft.Extensions.Time.Testing.FakeTimeProvider`), for unit-testing one timing rule exactly,
  where the test calls `Advance(...)` itself.

## Make timeouts explain themselves

A timed-out wait that only says "should be True but was False" is useless, especially when it only fails on CI. Give
the fixture a `DescribeAsync()` that reports the observable state: what is in each folder, each recorded run with its
status and error, how often each fake was called, and the **warnings and errors the app logged** (capture them with a
tiny `ILoggerProvider` that records `LogLevel.Warning` and above). Compute it only when the wait failed:

```cs
string pipeline = settled ? string.Empty : await wiki.DescribeAsync();
```

## HTTP tests with WebApplicationFactory

Start the real `Program` in-process with `Microsoft.AspNetCore.Mvc.Testing` (`internal sealed class TestApi :
WebApplicationFactory<Program>`; top-level `Program` is internal, which works with `InternalsVisibleTo`). Override
`ConfigureWebHost`:

- **`builder.UseEnvironment("Testing")`.** Development loads the developer's user secrets and personal config into
  tests.
- **Pass settings with `builder.UseSetting(key, value)`.** Configuration that `Program` reads while building its
  services, before `Build()`, must be a host setting; `ConfigureAppConfiguration` arrives too late. Point every
  file-system setting at the test's temporary directory, and point config-file directories somewhere empty so
  personal config is never loaded.
- **Replace only the outside world in `ConfigureTestServices`:**
  - Remote caches: `services.RemoveAll<IOutputCacheStore>(); services.AddOutputCache();`.
  - Agents and other remote clients: fakes.
  - Third-party sign-in: add a test authentication scheme that signs a request in from a header (absent header means
    signed out), and make it only the default *authenticate* scheme:
    `services.PostConfigure<AuthenticationOptions>(o => o.DefaultAuthenticateScheme = "Test")`. Challenges and
    forbids still go through the app's real handlers, so 401 and 403 responses are the genuine ones.
  - OpenID Connect handlers fetch the provider's metadata before their events run, which turns a signed-out request
    into a 500 offline. Give them a fixed `OpenIdConnectConfiguration` *and* a
    `StaticConfigurationManager<OpenIdConnectConfiguration>` in a `PostConfigure<OpenIdConnectOptions>`.
- **Give the fixture a client factory** such as `Client(objectId: ..., sendsCsrfHeader: true)` that adds the sign-in
  header, plus any anti-forgery header the API requires, and turns off auto-redirects.

Then test the contract the UI relies on: status codes for signed out, forbidden, missing anti-forgery header, invalid
input and path escapes, the success bodies and `Location` headers, and that state-changing calls really changed (or
didn't change) state. Read JSON with the same serializer options as the app, for example web defaults plus
`JsonStringEnumConverter`.

## File watchers and Linux

If the code under test reacts to files appearing (`FileSystemWatcher`), remember that on Linux .NET emulates
`FileShare` with advisory locks taken just *after* a file is created. An "is it ready?" check by exclusive open can
therefore win the gap and see an empty file, or make the writer fail. Production writers should write to a temporary
name and move the file into place. Readiness checks should wait for a stable, non-empty size rather than an exclusive
open. Tests that write in place while a watcher runs can lose the same race: open the writer before the watcher
starts, or write atomically.

Windows enforces sharing at open time, so these bugs often only show up on Linux CI. When something passes locally but
fails on CI, reproduce it in a Linux container (`mcr.microsoft.com/dotnet/sdk:<version from global.json>`), copying the
repo inside the container so its `bin`/`obj` don't clash with the host's.
