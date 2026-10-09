# Install-CtrlWheelZoom.ps1
# 安装 / 卸载 / 查看 "Ctrl + 滚轮缩放" 脚本。
#
# 安装:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CtrlWheelZoom.ps1
# 卸载:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CtrlWheelZoom.ps1 -Remove
# 查看:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CtrlWheelZoom.ps1 -Status
#
# 需要 AutoHotkey v2。没装的话可以先执行: winget install --id AutoHotkey.AutoHotkey -e
# 作用范围: 仅当前用户，无需管理员权限。脚本复制到 %USERPROFILE%\.win11-scripts，并在 "启动" 文件夹放一个快捷方式实现开机自启。
# 为什么不放 %LOCALAPPDATA%: 在商店版应用（如 Claude / Codex 桌面版）的内置终端里运行时，写入 AppData 的文件会被
# 重定向到该应用的私有目录，开机自启时就会报 "Script file not found"。用户目录本身不会被重定向。
[CmdletBinding()]
param(
    [switch]$Remove,
    [switch]$Status
)

$ErrorActionPreference = 'Stop'

$scriptRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptRoot)) {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$toolDir    = Join-Path $env:USERPROFILE '.win11-scripts\CtrlWheelZoom'
$legacyDir  = Join-Path $env:LOCALAPPDATA 'Win11Scripts'  # 旧版本的安装位置，安装 / 卸载时顺手清理
$workerPath = Join-Path $toolDir 'CtrlWheelZoom.ahk'
$lnkPath    = Join-Path ([Environment]::GetFolderPath('Startup')) 'CtrlWheelZoom.lnk'

function Find-AutoHotkey {
    $candidates = @(
        (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $null
}

# 只结束运行本工具脚本的 AutoHotkey 进程，不影响你的其他 AHK 脚本
function Stop-Worker {
    Get-CimInstance Win32_Process -Filter "Name LIKE 'AutoHotkey%'" |
        Where-Object { $_.CommandLine -and $_.CommandLine.Contains($workerPath) } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
}

if ($Status) {
    $ahk = Find-AutoHotkey
    if ($ahk) { "[正常] AutoHotkey v2: $ahk" } else { '[缺失] 未找到 AutoHotkey v2' }
    if (Test-Path -LiteralPath $workerPath) { "[正常] 脚本: $workerPath" } else { "[缺失] 脚本: $workerPath" }
    if (Test-Path -LiteralPath $lnkPath) { "[正常] 开机自启: $lnkPath" } else { "[缺失] 开机自启: $lnkPath" }
    $running = Get-CimInstance Win32_Process -Filter "Name LIKE 'AutoHotkey%'" |
        Where-Object { $_.CommandLine -and $_.CommandLine.Contains($workerPath) }
    if ($running) { '[正常] 正在运行' } else { '[未运行]' }
    exit
}

if ($Remove) {
    Stop-Worker
    if (Test-Path -LiteralPath $lnkPath) { Remove-Item -LiteralPath $lnkPath -Force }
    if (Test-Path -LiteralPath $toolDir) { Remove-Item -LiteralPath $toolDir -Recurse -Force }
    if (Test-Path -LiteralPath $legacyDir) { Remove-Item -LiteralPath $legacyDir -Recurse -Force }
    Write-Host '已卸载 Ctrl + 滚轮缩放。'
    exit
}

$ahk = Find-AutoHotkey
if (-not $ahk) {
    throw '未找到 AutoHotkey v2。请先安装: winget install --id AutoHotkey.AutoHotkey -e ，然后重新运行本脚本。'
}

New-Item -ItemType Directory -Force -Path $toolDir | Out-Null
Copy-Item -LiteralPath (Join-Path $scriptRoot 'CtrlWheelZoom.ahk') -Destination $workerPath -Force
if (Test-Path -LiteralPath $legacyDir) { Remove-Item -LiteralPath $legacyDir -Recurse -Force }

$ws  = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = $ahk
$lnk.Arguments  = "`"$workerPath`""
$lnk.Description = 'Ctrl + 滚轮缩放 Electron 应用界面'
$lnk.Save()

Stop-Worker
# 通过资源管理器打开快捷方式来启动，让脚本跑在商店版应用的沙盒外，和开机自启时的环境一致
Start-Process -FilePath (Join-Path $env:SystemRoot 'explorer.exe') -ArgumentList "`"$lnkPath`""

Write-Host '已安装并启动 Ctrl + 滚轮缩放。'
Write-Host "脚本: $workerPath"
Write-Host "开机自启: $lnkPath"
Write-Host '想加别的应用：编辑本文件夹里的 CtrlWheelZoom.ahk，在 ExeTargets 里加 exe 名，然后重新运行本安装脚本。'
