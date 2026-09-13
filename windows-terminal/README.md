# Windows Terminal config

Portable `settings.json` for Microsoft's Windows Terminal.

## Stock location

Store build:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

Unpackaged (preview) build:

```
%LOCALAPPDATA%\Microsoft\Windows Terminal\settings.json
```

## Apply on a new machine

1. Install Windows Terminal and the fonts it references, e.g.:
   - Fantasque Sans Mono
   - FantasqueSansMono Nerd Font Mono
   (Windows Terminal bundles only Cascadia Code/Mono.)
2. Copy `settings.json` over the stock location above (or symlink it).

## Notes

- Everything portable (color scheme "Monokai Remastered", font faces/sizes,
  opacity, cursor color) lives in this one file.
- The `WSL` Debian profile GUID is deterministic, so it resolves on any
  machine with Debian installed under WSL.
- Machine-specific bits were stripped from the original: the cygwin profile
  (absolute `C:\cygwin64\...` paths/icon) and the Debian profile icon
  (`C:\Users\...\Downloads\...`). Re-add icons locally if desired.