# Windows 11 实用脚本合集

自己日常用 Windows 11 时遇到「系统 / 软件这里要是能这样就好了」的地方，用 AI 辅助写出来的小工具。每个工具都是纯脚本，不装来路不明的软件，只改当前用户的设置，随时可以卸载。

🌐 [English](README.en.md)

## 工具列表

| 工具 | 解决什么问题 | 依赖 |
| --- | --- | --- |
| [右键复制绝对路径](copy-path-context-menu/) | 右键文件 / 文件夹 / 驱动器，一键复制完整路径（可带引号）。把文件路径发给 AI、粘贴到命令行时特别方便 | 无（PowerShell + 注册表） |
| [Ctrl + 滚轮缩放](ctrl-wheel-zoom/) | Claude 桌面版、Codex 桌面版、Obsidian 等应用按 Ctrl + 滚轮不能缩放，字太小 | AutoHotkey v2 |

点进每个文件夹看详细说明、安装和卸载方法。

## 通用说明

- 运行 `.ps1` 脚本统一用：`powershell -NoProfile -ExecutionPolicy Bypass -File .\脚本名.ps1`
- 安装脚本一般都支持 `-Status`（查看状态）和 `-Remove`（卸载）
- 只写当前用户范围（`HKCU`、用户目录、「启动」文件夹），无需管理员权限
- **建议在普通的 PowerShell 窗口里运行安装脚本。** Claude / Codex 等商店版桌面应用的内置终端运行在沙盒里，写入 `AppData` 和 `HKCU` 注册表的内容可能被重定向到该应用的私有位置，应用外看不到（例如右键菜单不出现、开机自启找不到文件）
- 脚本以 UTF-8 with BOM 保存，自己修改时请保持该编码，否则 Windows PowerShell 5.1 下中文会乱码

## 说明

这里的工具都是我在实际使用中遇到问题后，用 AI coding 写出来并在自己电脑上测试过的。如果和其他已有项目思路相似，纯属巧合。欢迎提 Issue 或 PR，分享你遇到的类似问题。

## License

[MIT](LICENSE)
