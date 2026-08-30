# Windows 11 右クリック「絶対パスをコピー」

右クリックだけでファイル・フォルダの絶対パスをクリップボードにコピーできます（引用符付きも選択可能）。PowerShell + レジストリのみ、追加ソフト不要・管理者権限不要・いつでもアンインストール可能。

> 「画像をローカルに保存した後、AI チャットにフルパスを手入力する」面倒さを解決するためのプロジェクトです。右クリック → パスをコピー → 貼り付け。

🌐 **言語**: [简体中文](../README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [Español](README.es.md)

---

## 機能

- ファイル / フォルダ / ドライブを右クリック →「その他のオプションを表示」→「絶対パスをコピー」
- 「絶対パスをコピー（引用符付き）」も選択可能（コマンドラインに貼り付けやすい）
- PowerShell + レジストリのみ、常駐なし・通信なし
- 現在のユーザーのレジストリ（`HKCU`）だけに書き込み、管理者権限不要・完全に削除可能
- 日本語・スペース・角括弧を含むパスでテスト済み

## 使い方

### 1. インストール（一度だけ）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1
```

### 2. 使用

ファイル等を右クリック →「その他のオプションを表示」→「絶対パスをコピー」。約 1 秒待ってから貼り付け。

### 3. 状態確認 / アンインストール

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1 -Status
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1 -Remove
```

## 仕組み

- `CopyPath.ps1`：パスを解決してクリップボードに書き込む
- `Install-CopyPath.ps1`：`HKCU\Software\Classes\*\shell`（および `Directory`、`Drive`）に右クリックメニューを登録。メニューは非表示ウィンドウで `powershell.exe` → `CopyPath.ps1` を呼び、`%1`（右クリックしたパス）をコピー
- インストール時に `CopyPath.ps1` を `%LOCALAPPDATA%\CodexTools\CopyAbsolutePath\` へコピーし、メニューはそちらを呼ぶ

## FAQ

- **Windows 11 で見つからない？** 静的レジストリ項目は「その他のオプションを表示」にあります。新しいメニューに入れるには Nilesoft Shell などのツールが必要です。
- **文字化け？** スクリプトは UTF-8 with BOM で保存しています。編集時はそのままにしてください。
- **作業スクリプトを消した？** メニューが効かなくなるので、インストーラーを再実行してください。
- **Windows 10 でも？** はい、同じ仕組みで動作します。

## License

[MIT](../LICENSE)