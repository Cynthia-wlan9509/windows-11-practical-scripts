# Windows 11 Practical Scripts

Small tools for everyday Windows 11 annoyances, built with AI-assisted coding and tested on my own machine. Each one is a plain script: no unknown software, current-user scope only, and an uninstall switch.

🌐 [简体中文](README.md)

## Tools

| Tool | What it fixes | Requires |
| --- | --- | --- |
| [Copy absolute path (context menu)](copy-path-context-menu/docs/README.en.md) | Right-click any file, folder or drive to copy its full path (optionally quoted). Handy for pasting paths into AI chats or the command line | Nothing (PowerShell + registry) |
| [Ctrl + wheel zoom](ctrl-wheel-zoom/README.md#english) | Claude Desktop, Codex Desktop and Obsidian don't zoom with Ctrl + mouse wheel | AutoHotkey v2 |

## General notes

- Run `.ps1` scripts with `powershell -NoProfile -ExecutionPolicy Bypass -File .\Script.ps1`
- Installers support `-Status` and `-Remove`
- Everything stays in current-user scope (`HKCU`, `%LOCALAPPDATA%`, the Startup folder); no admin rights needed
- Scripts are saved as UTF-8 with BOM; keep that encoding when editing, or Chinese text breaks in Windows PowerShell 5.1

Built from my own day-to-day pain points with AI coding; any resemblance to existing projects is coincidental. Issues and PRs welcome.

## License

[MIT](LICENSE)
