# VS Code

Windows VS Code configuration for remote development over WSL.

## Files

- `settings.json` — editor settings, theme customizations, remote SSH config
- `wsl-ssh.bat` — helper that proxies `ssh` calls from Windows VS Code through WSL

## Deploy

Copy to `%APPDATA%\Code\User\` on the target machine:

```bat
copy settings.json %APPDATA%\Code\User\settings.json
copy wsl-ssh.bat C:\bin\wsl-ssh.bat
```

Then install the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension.

## Notes

- `wsl-ssh.bat` converts Windows paths to WSL paths before invoking `ssh` inside WSL. This lets VS Code's Remote SSH extension work seamlessly when your SSH config and keys live under `~/` in WSL.
- `remote.SSH.configFile` points to the WSL SSH config — adjust if your username differs from `shennarwp`.
