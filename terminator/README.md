# Terminator

This directory contains the Terminator profile and layout used on Linux.

## Prerequisites

On Debian or Ubuntu, install Terminator and the configured font:

```bash
sudo apt update
sudo apt install terminator fonts-fantasque-sans
```

The profile uses Fantasque Sans Mono at 11pt. If that font package is not
available on your distribution, install Fantasque Sans Mono through the
distribution package manager or a trusted font source.

## Install

Back up the existing configuration, then copy the tracked file into
Terminator's user configuration directory:

```bash
mkdir -p ~/.config/terminator
if [ -f ~/.config/terminator/config ]; then
    cp ~/.config/terminator/config ~/.config/terminator/config.backup
fi
cp config ~/.config/terminator/config
```

Run `terminator` to open a new window. The checked-in profile uses a dark
background, the Monokai-inspired palette, copy-on-selection, and a default
900x580 layout.
