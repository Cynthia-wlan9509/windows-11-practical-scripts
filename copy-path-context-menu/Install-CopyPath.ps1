# Install-CopyPath.ps1
# 安装 / 卸载 / 查看 右键菜单 "复制绝对路径"。
#
# 安装:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CopyPath.ps1
# 卸载:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CopyPath.ps1 -Remove
# 查看:  powershell -NoProfile -ExecutionPolicy Bypass -File Install-CopyPath.ps1 -Status
#
# 作用范围: 仅当前用户 (HKCU\Software\Classes)，无需管理员权限，可随时卸载。
# 注意: 在 Windows 11 里，该选项位于右键菜单 -> "显示更多选项"。
# 重要: 一律使用 .NET Registry API 读写，避免 "*" 被当成通配符。
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

$toolDir    = Join-Path $env:LOCALAPPDATA 'CodexTools\CopyAbsolutePath'
$workerPath = Join-Path $toolDir 'CopyPath.ps1'

$classes = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\Classes', $true)
if ($null -eq $classes) {
    throw '无法打开 HKCU\Software\Classes'
}

$defs = @(
    @{ Class = '*';        Name = 'CodexCopyPath';       Label = '复制绝对路径' },
    @{ Class = 'Directory'; Name = 'CodexCopyPath';       Label = '复制绝对路径' },
    @{ Class = 'Drive';    Name = 'CodexCopyPath';       Label = '复制绝对路径' },
    @{ Class = '*';        Name = 'CodexCopyPathQuoted'; Label = '复制绝对路径（带引号）' },
    @{ Class = 'Directory'; Name = 'CodexCopyPathQuoted'; Label = '复制绝对路径（带引号）' },
    @{ Class = 'Drive';    Name = 'CodexCopyPathQuoted'; Label = '复制绝对路径（带引号）' }
)

$psExe = (Get-Command powershell.exe -ErrorAction Stop).Source
$icon  = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

function Install-Verb {
    param($Def, $CmdLine)
    $path = "$($Def.Class)\shell\$($Def.Name)"
    $key = $classes.CreateSubKey($path)
    $key.SetValue('', $Def.Label)
    $key.SetValue('Icon', $icon)
    $cmdKey = $key.CreateSubKey('command')
    $cmdKey.SetValue('', $CmdLine)
    $cmdKey.Close()
    $key.Close()
}

function Remove-Verb {
    param($Def)
    $path = "$($Def.Class)\shell\$($Def.Name)"
    $classes.DeleteSubKeyTree($path, $false)
}

function Get-VerbStatus {
    param($Def)
    $path = "$($Def.Class)\shell\$($Def.Name)"
    $key = $classes.OpenSubKey($path)
    if ($null -eq $key) { return "[缺失] $($Def.Class) -> $($Def.Name)" }
    $label = [string]$key.GetValue('')
    $cmdVal = $null
    $cmdKey = $key.OpenSubKey('command')
    if ($null -ne $cmdKey) {
        $cmdVal = [string]$cmdKey.GetValue('')
        $cmdKey.Close()
    }
    $key.Close()
    if ([string]::IsNullOrWhiteSpace($cmdVal)) {
        return "[不完整] $($Def.Class) -> $($Def.Name) ($label, 无 command)"
    }
    if (-not $cmdVal.Contains('powershell.exe') -or -not $cmdVal.Contains('CopyPath.ps1')) {
        return "[异常] $($Def.Class) -> $($Def.Name) ($label) 命令异常: $cmdVal"
    }
    return "[正常] $($Def.Class) -> $($Def.Name) ($label) => $cmdVal"
}

if ($Status) {
    foreach ($d in $defs) { Get-VerbStatus $d }
    $classes.Close()
    exit
}

if ($Remove) {
    foreach ($d in $defs) { Remove-Verb $d }
    $classes.Close()
    if (Test-Path -LiteralPath $toolDir) {
        Remove-Item -LiteralPath $toolDir -Recurse -Force
    }
    Write-Host '已移除右键菜单：复制绝对路径。'
} else {
    New-Item -ItemType Directory -Force -Path $toolDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $scriptRoot 'CopyPath.ps1') -Destination $workerPath -Force

    $plainCmd = "`"$psExe`" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$workerPath`" `"%1`""
    $quoteCmd = "`"$psExe`" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$workerPath`" `"%1`" -Quoted"

    foreach ($d in $defs) {
        if ($d.Name -like '*Quoted*') { Install-Verb $d $quoteCmd } else { Install-Verb $d $plainCmd }
    }
    $classes.Close()

    Write-Host '已安装右键菜单：复制绝对路径。'
    Write-Host "工作脚本: $workerPath"
    Write-Host '提示: Windows 11 中该选项在 右键 -> 显示更多选项。可用 -Status 查看安装状态。'
}