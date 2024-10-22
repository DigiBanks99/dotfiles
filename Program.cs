using System.CommandLine;
using System.Diagnostics;

namespace dotfiles;

public static class Program
{
    public static async Task<int> Main(string[] args)
    {
        RootCommand rootCommand = new("Menlo dotfiles CLI");
        rootCommand.SetHandler(DelegateToShell);

        Command checkCommandExists = new("check", "Check if a command exists");
        Argument<string> commandArg = new("command", "The command to check");
        checkCommandExists.Add(commandArg);
        checkCommandExists.SetHandler(CheckCommandExists, commandArg);

        rootCommand.Add(checkCommandExists);

        return await rootCommand.InvokeAsync(args);
    }

    public static void DelegateToShell()
    {
        ProcessStartInfo startInfo;
        string? homePath = AppContext.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar)
            ?? Environment.GetEnvironmentVariable("HOME")
            ?? Environment.GetEnvironmentVariable("USERPROFILE");
        if (homePath is null)
        {
            Console.Error.WriteLine("Could not determine home directory. Please ensure the HOME or USERPROFILE environment variable is set.");
            Environment.Exit(1);
            return;
        }

        Console.WriteLine($"Home directory: {homePath}");
        string dotfilesBinSegment = Path.Combine(".dotfiles", "bin");
        string dotfilesBinPath = homePath.EndsWith(dotfilesBinSegment) ? homePath : Path.Combine(homePath, dotfilesBinSegment);
        Console.WriteLine($"Dotfiles bin path: {dotfilesBinPath}");
        if (CheckIfCommandExists("pwsh"))
        {
            string shellScriptPath = Path.Combine(dotfilesBinPath, "dotfiles.ps1");
            startInfo = new ProcessStartInfo("pwsh")
            {
                Arguments = $"-Command \"{shellScriptPath}\""
            };
        }
        else if (CheckIfCommandExists("zsh"))
        {
            string shellScriptPath = Path.Combine(dotfilesBinPath, "dotfiles.zsh");
            startInfo = new ProcessStartInfo("zsh")
            {
                Arguments = $"-c \"{shellScriptPath}\""
            };
        }
        else if (CheckIfCommandExists("bash"))
        {
            string shellScriptPath = Path.Combine(dotfilesBinPath, "dotfiles.sh");
            startInfo = new ProcessStartInfo("bash")
            {
                Arguments = $"-c \"{shellScriptPath}\""
            };
        }
        else
        {
            Console.Error.WriteLine("No supported shell found. Please ensure either PowerShell 7+, Bash, or Zsh is installed.");
            Environment.Exit(1);
            return;
        }

        startInfo.CreateNoWindow = true;
        startInfo.UseShellExecute = false;
        startInfo.RedirectStandardOutput = true;
        startInfo.RedirectStandardError = true;

        Process process = new()
        {
            StartInfo = startInfo
        };

        process.OutputDataReceived += (sender, e) => Console.WriteLine(e.Data);
        process.ErrorDataReceived += (sender, e) => Console.WriteLine(e.Data);

        _ = process.Start();
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        process.WaitForExit();
    }

    public static void CheckCommandExists(string command)
    {
        if (CheckIfCommandExists(command))
        {
            Console.WriteLine($"Command '{command}' found");
        }
        else
        {
            Console.WriteLine($"Command '{command}' not found");
            Environment.Exit(1);
        }
    }

    private static bool CheckIfCommandExists(string command)
    {
        ProcessStartInfo startInfo = OperatingSystem.IsWindows()
            ? new("where", command)
            : new("bash", $"-c \"type '{command}' >/dev/null 2>&1\"");
        startInfo.CreateNoWindow = true;
        startInfo.UseShellExecute = false;

        Process process = new()
        {
            StartInfo = startInfo
        };
        _ = process.Start();
        process.WaitForExit();

        return process.ExitCode == 0;
    }
}