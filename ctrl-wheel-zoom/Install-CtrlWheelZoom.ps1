# Install-CtrlWheelZoom.ps1
# 安装 / 卸载 / 查看 "Ctrl + 滚轮缩放" 脚本。
#
# 安装:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CtrlWheelZoom.ps1
# 卸载:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CtrlWheelZoom.ps1 -Remove
# 查看:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CtrlWheelZoom.ps1 -Status
#
# 需要 AutoHotkey v2。没装的话可以先执行: winget install --id AutoHotkey.AutoHotkey -e
# 作用范围: 仅当前用户，无需管理员权限。脚本复制到 %LOCALAPPDATA%，并在 "启动" 文件夹放一个快捷方式实现开机自启。
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

$toolDir    = Join-Path $env:LOCALAPPDATA 'Win11Scripts\CtrlWheelZoom'
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
    Write-Host '已卸载 Ctrl + 滚轮缩放。'
    exit
}

$ahk = Find-AutoHotkey
if (-not $ahk) {
    throw '未找到 AutoHotkey v2。请先安装: winget install --id AutoHotkey.AutoHotkey -e ，然后重新运行本脚本。'
}

New-Item -ItemType Directory -Force -Path $toolDir | Out-Null
Copy-Item -LiteralPath (Join-Path $scriptRoot 'CtrlWheelZoom.ahk') -Destination $workerPath -Force

$ws  = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = $ahk
$lnk.Arguments  = "`"$workerPath`""
$lnk.Description = 'Ctrl + 滚轮缩放 Electron 应用界面'
$lnk.Save()

Stop-Worker
Start-Process -FilePath $ahk -ArgumentList "`"$workerPath`""

Write-Host '已安装并启动 Ctrl + 滚轮缩放。'
Write-Host "脚本: $workerPath"
Write-Host "开机自启: $lnkPath"
Write-Host '想加别的应用：编辑本文件夹里的 CtrlWheelZoom.ahk，在 ExeTargets 里加 exe 名，然后重新运行本安装脚本。'
