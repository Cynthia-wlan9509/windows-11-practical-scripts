; CtrlWheelZoom.ahk
; 让不支持 Ctrl + 滚轮缩放的 Electron / Chromium 桌面应用也能用 Ctrl + 滚轮缩放整个界面。
; 原理: 把 Ctrl + 滚轮 转成应用自带的缩放快捷键 Ctrl + = / Ctrl + - / Ctrl + 0。
;   Ctrl + 滚轮上 = 放大，Ctrl + 滚轮下 = 缩小，Ctrl + 中键 = 恢复 100%
; 只在下面列出的应用处于前台时生效，其他程序不受影响。
; Multisim 的电路图画布另有一套规则（滚轮滚动 / Ctrl + 滚轮缩放），见文件末尾。
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

; ---------- Multisim（NI Circuit Design Suite 电路仿真）----------
; Multisim 默认滚轮是缩放，和浏览器 / Claude 习惯相反。在电路图画布上改成：
;   滚轮 = 上下滚动，Shift + 滚轮 = 左右滚动
;   Ctrl + 滚轮 = 缩放，Ctrl + 中键 = 整张图纸显示（Multisim 的 F7「Zoom sheet」）
; 前提：Multisim 的 Options → Global options → General → Mouse wheel behavior 保持默认的
; Zoom workspace；勾上 Center on mouse 后会以鼠标位置为中心缩放。
; 滚动用的是窗口滚动消息（WM_VSCROLL / WM_HSCROLL）：实测 Multisim 不认模拟出来的
; 「Ctrl + 滚轮 = 滚动」，但认滚动消息。
; 只在鼠标停在电路图画布上时生效；元件列表、表格、对话框里的滚轮不受影响。
MultisimScrollLines := 3   ; 滚一格移动几行，嫌慢就调大

MultisimCanvasUnderMouse() {
    MouseGetPos , , &win, &ctl, 2   ; 2 = 直接拿控件句柄
    try {
        if WinGetProcessName("ahk_id " win) != "multisim.exe"
            return 0
        if InStr(WinGetClass("ahk_id " ctl), "AfxFrameOrView") = 1   ; 画布是 MFC 视图窗口
            return ctl
    }
    return 0
}

MultisimScroll(msg, dir) {   ; msg: 0x115 竖直 / 0x114 水平；dir: 0 向上(左) / 1 向下(右)
    if hwnd := MultisimCanvasUnderMouse()
        Loop MultisimScrollLines
            PostMessage msg, dir, 0, hwnd
}

#HotIf MultisimCanvasUnderMouse()
WheelUp::MultisimScroll(0x115, 0)
WheelDown::MultisimScroll(0x115, 1)
+WheelUp::MultisimScroll(0x114, 0)
+WheelDown::MultisimScroll(0x114, 1)
^WheelUp::Send "{WheelUp}"      ; Send 会先松开按住的 Ctrl，Multisim 收到普通滚轮 = 缩放
^WheelDown::Send "{WheelDown}"
^MButton::Send "{F7}"
#HotIf
