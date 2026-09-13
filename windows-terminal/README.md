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

## Extracted color scheme

`schemes/monokai-remastered.json` holds the scheme standalone, e.g. for reuse
in other terminals (tmux, Xresources, terminal.sexy, etc.).

ANSI index mapping (0–15 + extras):

| Index | Color | Hex |
|-------|-------|-----|
| 00 | black | `#1A1A1A` |
| 01 | red | `#F4005F` |
| 02 | green | `#98E024` |
| 03 | yellow | `#FD971F` |
| 04 | blue | `#9D65FF` |
| 05 | purple | `#F4005F` |
| 06 | cyan | `#58D1EB` |
| 07 | white | `#C4C5B5` |
| 08 | brightBlack | `#625E4C` |
| 09 | brightRed | `#F4005F` |
| 10 | brightGreen | `#98E024` |
| 11 | brightYellow | `#E0D561` |
| 12 | brightBlue | `#9D65FF` |
| 13 | brightPurple | `#F4005F` |
| 14 | brightCyan | `#58D1EB` |
| 15 | brightWhite | `#F6F6EF` |

Plus: foreground `#D9D9D9`, background `#0C0C0C`, cursor `#FC971F`,
selection `#343434`.