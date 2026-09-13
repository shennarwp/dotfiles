# Sublime Text 3 (Windows)

Portable Sublime Text 3 configuration — preferences, keybindings, linter
settings, and the Package Control plugin list.

## Stock location

Windows (ST3):

```
%APPDATA%\Sublime Text 3\Packages\User\
```

## Layout

```
sublime-text/
├── Preferences.sublime-settings   theme (Flatland), colorscheme, font, misc
├── Default (Windows).sublime-keymap   custom keybindings (Ctrl+Alt+T terminal, ...)
├── Package Control.sublime-settings   installed package list + custom repos
├── Anaconda.sublime-settings          python linting config
├── Python.sublime-settings            python tab/spaces
├── SublimeLinter.sublime-settings     linter debug
├── Terminal.sublime-settings          external terminal exe (ConEmu)
├── trailing_spaces.sublime-settings   trim on save
└── SyncSettings.sublime-settings      TEMPLATE — fill in your own token/gist
```

## Setup on a new machine

1. Install **Sublime Text 3** (Windows).
2. If not already present, install **Package Control**:
   https://packagecontrol.io/installation
3. Copy every file in this folder into
   `%APPDATA%\Sublime Text 3\Packages\User\`.
4. Next launch, Package Control auto-installs every package listed under
   `installed_packages` in `Package Control.sublime-settings`
   (restart may be needed for themes/linters to activate).

## Plugins (from `Package Control.sublime-settings`)

A File Icon, BracketHighlighter, Exalt, File Rename, Line Endings Unify,
MarkdownLivePreview, MarkdownPreview, MoveTab, Open in Default Application,
Origami, Package Control, SideBarEnhancements, SublimeLinter,
SublimeLinter-javac, SublimeLinter-xmllint, SublimeREPL, Sync Settings,
Terminal, Theme - Flatland, TrailingSpaces.

The `Installed Packages/*.sublime-package` archives are not stored here —
Package Control re-downloads them from the list.

## Fonts

Requires **Fantasque Sans Mono** (see `windows-terminal/README.md`).
ConEmu (`C:\Program Files\ConEmu\ConEmu64.exe`) if you change the terminal.

## Secrets

`SyncSettings.sublime-settings` originally contained a real GitHub access
token. It is NOT tracked here — only the template is committed. Fill in your
own token/gist id per machine, and rotate any leaked token on GitHub.