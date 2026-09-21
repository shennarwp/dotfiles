# xfce4

This directory contains the Monokai Remastered color scheme for Xfce
Terminal.

## Install for the current user

Install Xfce Terminal if needed, create its per-user color-scheme directory,
and copy the theme:

```bash
sudo apt install xfce4-terminal
mkdir -p ~/.local/share/xfce4/terminal/colorschemes
cp monokai-remastered.theme \
    ~/.local/share/xfce4/terminal/colorschemes/monokai-remastered.theme
```

Open Xfce Terminal, then choose `Edit > Preferences > Colors` and select
`Monokai Remastered`.

## Install system-wide

To make the scheme available to every user, copy it to the system color-scheme
directory:

```bash
sudo install -Dm644 monokai-remastered.theme \
    /usr/share/xfce4/terminal/colorschemes/monokai-remastered.theme
```

Restart Xfce Terminal if it was already open, then select the scheme from
`Edit > Preferences > Colors`.
