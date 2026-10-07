; CtrlWheelZoom.ahk
; 让不支持 Ctrl + 滚轮缩放的 Electron / Chromium 桌面应用也能用 Ctrl + 滚轮缩放整个界面。
; 原理: 把 Ctrl + 滚轮 转成应用自带的缩放快捷键 Ctrl + = / Ctrl + - / Ctrl + 0。
;   Ctrl + 滚轮上 = 放大，Ctrl + 滚轮下 = 缩小，Ctrl + 中键 = 恢复 100%
; 只在下面列出的应用处于前台时生效，其他程序不受影响。
#Requires AutoHotkey v2.0
#SingleInstance Force

; 按进程名匹配的应用（想加新应用就往这里加 exe 名）
ExeTargets := [
    "claude.exe",      ; Claude 桌面版
    "Obsidian.exe"     ; Obsidian（缩放是程序级别的，和打开哪个仓库无关）
]

; 按安装路径片段匹配的应用（适合商店版、进程名不固定的应用）
PathTargets := [
    "\OpenAI.Codex_"   ; Codex 桌面版（进程可能是 Codex.exe 或同包内的 ChatGPT.exe）
]

IsZoomTarget() {
    for exe in ExeTargets
        if WinActive("ahk_exe " exe)
            return true
    try {
        procPath := WinGetProcessPath("A")
        for frag in PathTargets
            if InStr(procPath, frag)
                return true
    }
    return false
}

#HotIf IsZoomTarget()
^WheelUp::Send "^{=}"
^WheelDown::Send "^{-}"
^MButton::Send "^0"
#HotIf
