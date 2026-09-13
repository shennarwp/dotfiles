# Sublime Text 3 (Windows)

Portable Sublime Text 3 configuration — preferences, keybindings, linter
settings, and the Package Control plugin list.

> Also works with **Sublime Text 4** — the config format (`.sublime-settings`,
> `.sublime-keymap`, Package Control) is unchanged. On newer machines copy to
> `%APPDATA%\Sublime Text\Packages\User\` (ST4 dropped the version in the
> folder name).

## Stock location

Windows (ST3):

```
%APPDATA%\Sublime Text 3\Packages\User\
```

## Layout

```
sublime-text/
├── Preferences.sublime-settings   theme (Flatland), colorscheme, font, misc
├── Default (Windows).sublime-keymap   custom keybindings (Ctrl+Shift+T, ...)
├── Package Control.sublime-settings   installed package list
├── Python.sublime-settings            python tab/spaces
└── trailing_spaces.sublime-settings   trim on save
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
MarkdownLivePreview, MarkdownPreview, Open in Default Application, Origami,
Package Control, SideBarEnhancements, Theme - Flatland, TrailingSpaces.

The `Installed Packages/*.sublime-package` archives are not stored here —
Package Control re-downloads them from the list.

## Fonts

Requires **Fantasque Sans Mono** (see `windows-terminal/README.md`).