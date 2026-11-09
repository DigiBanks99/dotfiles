export PATH="$HOME/.dotnetup:$HOME/.dotnet/tools:$PATH"
if command -v dotnetup >/dev/null 2>&1; then
    eval "$(dotnetup env script --shell zsh --dotnet)"
fi
