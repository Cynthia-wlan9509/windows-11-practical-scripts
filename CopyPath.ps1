# CopyPath.ps1
# 把选中的文件/文件夹/驱动器的绝对路径复制到剪贴板。
# 用法: powershell -NoProfile -ExecutionPolicy Bypass -File CopyPath.ps1 <路径> [-Quoted]
#   -Quoted: 复制带双引号的路径（方便直接粘贴到命令行 / 参数位置）
# 由 Install-CopyPath.ps1 安装到右键菜单后自动调用。
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,
    [switch]$Quoted
)

$ErrorActionPreference = 'Stop'

$resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
$full = $resolved.Path

if ($Quoted) {
    $full = '"' + $full + '"'
}

Set-Clipboard -Value $full -ErrorAction Stop