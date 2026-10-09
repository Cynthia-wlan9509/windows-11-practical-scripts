# Ctrl + 滚轮缩放：让 Claude / Codex / Obsidian 桌面版支持 Ctrl + 鼠标滚轮放大缩小

> 本工具属于 [Windows 11 实用脚本合集](../README.md)。English below.

很多 Electron / Chromium 做的桌面应用只支持 `Ctrl + =` / `Ctrl + -` 缩放，按住 Ctrl 滚鼠标滚轮却没反应。字太小看着累，每次都按键盘又麻烦。

这个小脚本把 **Ctrl + 滚轮** 转成应用自带的缩放快捷键。缩放的是整个界面，聊天文字、代码块、文件预览、侧边栏一起变。

| 操作 | 效果 |
| --- | --- |
| Ctrl + 滚轮向上 | 放大 |
| Ctrl + 滚轮向下 | 缩小 |
| Ctrl + 按下滚轮（中键） | 恢复 100% |

## 默认支持的应用

- **Claude 桌面版**（`claude.exe`）
- **Codex 桌面版**（商店版，按安装路径识别，`Codex.exe` / 同包内 `ChatGPT.exe` 都能匹配）
- **Obsidian**（`Obsidian.exe`）：缩放是整个程序级别的，**不管打开哪个仓库（vault）都生效**。和 Obsidian 自带的「Ctrl + 滚轮调字号」也不冲突：Ctrl + 滚轮会先被脚本接管。

只在这些应用处于前台时生效，其他程序（浏览器、Office 等）不受影响。

## 安装

1. 安装 [AutoHotkey v2](https://www.autohotkey.com/)（免费开源）：

   ```powershell
   winget install --id AutoHotkey.AutoHotkey -e
   ```

2. 下载本仓库，进入 `ctrl-wheel-zoom` 文件夹，在 PowerShell 里执行：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CtrlWheelZoom.ps1
   ```

安装脚本会把 `CtrlWheelZoom.ahk` 复制到 `%USERPROFILE%\.win11-scripts\CtrlWheelZoom\`，在「启动」文件夹放一个快捷方式（开机自启），并立刻启动。无需管理员权限。

运行时任务栏右下角会有一个绿色 **H** 图标，右键 → Exit 可临时关闭。

### 查看状态 / 卸载

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CtrlWheelZoom.ps1 -Status
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CtrlWheelZoom.ps1 -Remove
```

## 加别的应用

编辑 `CtrlWheelZoom.ahk`，在 `ExeTargets` 里加上进程名（任务管理器 → 详细信息里能看到），然后重新运行安装脚本：

```autohotkey
ExeTargets := [
    "claude.exe",
    "Obsidian.exe",
    "YourApp.exe"
]
```

前提是这个应用本身支持 `Ctrl + =` / `Ctrl + -` 缩放（大多数 Electron 应用都支持）。

## 常见问题

- **滚一格跳两级？** 说明这个应用本身已经支持 Ctrl + 滚轮，把它从列表里删掉即可。
- **开机弹窗 `Script file not found`？** 旧版本把脚本装在 `%LOCALAPPDATA%`。如果是在 Claude / Codex 这类商店版应用的内置终端里（或让 AI 帮你）运行的安装脚本，写进 AppData 的文件会被重定向到该应用的私有目录，开机时就找不到。新版本已改为装到用户目录，重新运行一次安装脚本即可（会顺手清理旧位置）。
- **没反应？** 先确认应用里按 `Ctrl + =` 能不能缩放；再用 `-Status` 看脚本是否在运行。
- **为什么不直接改应用？** 商店版应用装在受保护的 `WindowsApps` 目录，改不了；而且应用一更新改动就没了。外挂一个热键脚本最稳。

---

## English

**Ctrl + mouse wheel zoom for Claude Desktop, Codex Desktop and Obsidian on Windows.** Many Electron apps only zoom with `Ctrl + =` / `Ctrl + -` and ignore Ctrl + scroll. This AutoHotkey v2 script maps Ctrl + Wheel Up / Down to zoom in / out and Ctrl + Middle Click to reset, only while one of the listed apps is in the foreground. Obsidian zoom is app-wide, so it works in every vault.

Install AutoHotkey v2 (`winget install --id AutoHotkey.AutoHotkey -e`), then run `Install-CtrlWheelZoom.ps1` from this folder. Use `-Status` to check and `-Remove` to uninstall. Add more apps by editing `ExeTargets` in `CtrlWheelZoom.ahk`.
