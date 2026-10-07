# Windows 11 右鍵「複製絕對路徑」

右鍵一鍵複製檔案/資料夾的絕對路徑到剪貼簿，支援帶引號版本。純 PowerShell + 登錄檔，無需安裝任何軟體、無需系統管理員權限、可隨時移除。

> 這個專案正是為了解決「把圖片存到本機後，還要手動輸入完整路徑給 AI 對話框」的痛點：右鍵 → 複製路徑 → 貼上，三步變一步。

🌐 **語言 / Language**：[简体中文](../README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [Español](README.es.md)

---

## 功能

- 右鍵**檔案 / 資料夾 / 磁碟** →「顯示更多選項」→「複製絕對路徑」
- 另有「複製絕對路徑（帶引號）」，方便直接貼到命令列參數
- 純 PowerShell + 登錄檔，不裝軟體、不常駐、不聯網
- 只寫目前使用者登錄檔（`HKCU`），不需管理員權限，可隨時移除
- 已用含**中文、空格、方括號**的路徑實測通過

## 使用

### 1. 安裝（只跑一次）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1
```

### 2. 使用

右鍵任一檔案/資料夾/磁碟 →「顯示更多選項」→「複製絕對路徑」。約 1 秒後貼上。

### 3. 查看狀態 / 移除

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1 -Status
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1 -Remove
```

## 原理

- `CopyPath.ps1`：解析路徑並寫入剪貼簿
- `Install-CopyPath.ps1`：在 `HKCU\Software\Classes\*\shell`（以及 `Directory`、`Drive`）寫入右鍵選單，選單命令為「隱藏呼叫 powershell.exe → 執行 CopyPath.ps1，把 `%1` 複製進剪貼簿」
- 安裝時會把 `CopyPath.ps1` 複製到 `%LOCALAPPDATA%\CodexTools\CopyAbsolutePath\`

## 常見問題

- **Windows 11 找不到選單？** 靜態登錄檔選單位於「顯示更多選項」。想進新式精簡選單需 Nilesoft Shell 等工具。
- **中文亂碼？** 腳本以 UTF-8 with BOM 儲存；自行修改時請保持此編碼。
- **誤刪工作腳本？** 重跑安裝腳本即可恢復。
- **Windows 10 可用嗎？** 可以，原理相同。

## License

[MIT](../../LICENSE)