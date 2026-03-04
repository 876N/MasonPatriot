format PE GUI 4.0
entry MasonMain
include 'win32ax.inc'

Mason_ID_BIN  = 101
Mason_ID_BOUT = 102
Mason_ID_GO   = 103
Mason_ID_EIN  = 104
Mason_ID_EOUT = 105
Mason_ID_C0   = 110
Mason_ID_C1   = 111
Mason_ID_C2   = 112
Mason_ID_C3   = 113
Mason_ID_LOG  = 130
Mason_ID_CLOSE = 140
Mason_ID_MIN   = 141

Mason_FL_E = 1
Mason_FL_D = 2
Mason_FL_M = 4
Mason_FL_V = 8

MasonBgCol    = 01A1A2Eh
MasonTBarCol  = 0141428h
MasonAccCol   = 04E4E6Dh
MasonHiCol    = 03A3A52h
MasonShdCol   = 00A0A16h
MasonEdCol    = 010101Eh
MasonTxtCol   = 0D0D0E0h
MasonDimCol   = 07878A0h
MasonLogBg    = 00A0A14h
MasonLogTxt   = 000FF41h
MasonBtnFace  = 0282840h
MasonBtnHi    = 04E4E6Dh
MasonBtnShd   = 0101020h

section '.MasonI' import data readable

    library kernel32, 'kernel32.dll',\
            user32,   'user32.dll',\
            gdi32,    'gdi32.dll',\
            comdlg32, 'comdlg32.dll',\
            comctl32, 'comctl32.dll'

    include 'api/kernel32.inc'
    include 'api/user32.inc'
    include 'api/gdi32.inc'
    include 'api/comdlg32.inc'
    import comctl32,\
        InitCommonControlsEx, 'InitCommonControlsEx'

section '.MasonC' code readable executable

MasonMain:
    sub esp, 8
    mov dword [esp], 8
    mov dword [esp + 4], 8
    push esp
    call [InitCommonControlsEx]
    add esp, 8

    invoke GetModuleHandle, 0
    mov [MasonHInst], eax

    invoke LoadCursor, 0, IDC_ARROW
    mov dword [MasonWC + 28], eax
    invoke LoadIcon, [MasonHInst], 1
    mov dword [MasonWC + 24], eax

    mov dword [MasonWC], 48
    mov dword [MasonWC + 4], 3
    mov dword [MasonWC + 8], MasonWndProc
    mov dword [MasonWC + 12], 0
    mov dword [MasonWC + 16], 0
    mov eax, [MasonHInst]
    mov dword [MasonWC + 20], eax
    mov dword [MasonWC + 32], 0
    mov dword [MasonWC + 36], 0
    mov dword [MasonWC + 40], MasonCls
    mov dword [MasonWC + 44], 0
    invoke RegisterClassEx, MasonWC

    invoke GetSystemMetrics, SM_CXSCREEN
    sub eax, 710
    shr eax, 1
    mov esi, eax
    invoke GetSystemMetrics, SM_CYSCREEN
    sub eax, 540
    shr eax, 1

    invoke CreateWindowEx, 0, MasonCls, 0,\
        WS_POPUP or WS_CLIPCHILDREN or WS_MINIMIZEBOX,\
        esi, eax, 710, 540, 0, 0, [MasonHInst], 0
    mov [MasonHWnd], eax
    invoke ShowWindow, [MasonHWnd], SW_SHOW
    invoke UpdateWindow, [MasonHWnd]

.MasonPump:
    invoke GetMessage, MasonMSG, 0, 0, 0
    test eax, eax
    jz .MasonQuit
    invoke TranslateMessage, MasonMSG
    invoke DispatchMessage, MasonMSG
    jmp .MasonPump
.MasonQuit:
    invoke ExitProcess, 0

proc MasonWndProc hw, um, wp, lp
    push ebx esi edi
    cmp [um], WM_CREATE
    je .MasonCreate
    cmp [um], WM_PAINT
    je .MasonPaint
    cmp [um], WM_ERASEBKGND
    je .MasonErase
    cmp [um], WM_COMMAND
    je .MasonCmd
    cmp [um], WM_DRAWITEM
    je .MasonDrawItem
    cmp [um], WM_CTLCOLOREDIT
    je .MasonColorEdit
    cmp [um], WM_CTLCOLORSTATIC
    je .MasonColorStatic
    cmp [um], WM_CTLCOLORBTN
    je .MasonColorBtn
    cmp [um], WM_LBUTTONDOWN
    je .MasonMouseDown
    cmp [um], WM_DESTROY
    je .MasonDestroy
    jmp .MasonDefWnd

.MasonCreate:
    mov eax, [hw]
    mov [MasonHWnd], eax
    call MasonBuildUI
    xor eax, eax
    jmp .MasonOut

.MasonErase:
    mov eax, 1
    jmp .MasonOut

.MasonPaint:
    invoke BeginPaint, [hw], MasonPS
    mov edi, eax

    mov dword [MasonTmpRC], 0
    mov dword [MasonTmpRC + 4], 0
    mov dword [MasonTmpRC + 8], 710
    mov dword [MasonTmpRC + 12], 540
    invoke CreateSolidBrush, MasonBgCol
    mov ebx, eax
    invoke FillRect, edi, MasonTmpRC, ebx
    invoke DeleteObject, ebx

    invoke CreatePen, 0, 1, MasonHiCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 0, 539, 0
    invoke LineTo, edi, 0, 0
    invoke LineTo, edi, 709, 0
    pop eax
    invoke DeleteObject, eax

    invoke CreatePen, 0, 1, MasonShdCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 709, 0, 0
    invoke LineTo, edi, 709, 539
    invoke LineTo, edi, 0, 539
    pop eax
    invoke DeleteObject, eax

    invoke CreatePen, 0, 1, MasonHiCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 1, 538, 0
    invoke LineTo, edi, 1, 1
    invoke LineTo, edi, 708, 1
    pop eax
    invoke DeleteObject, eax

    invoke CreatePen, 0, 1, MasonShdCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 708, 1, 0
    invoke LineTo, edi, 708, 538
    invoke LineTo, edi, 1, 538
    pop eax
    invoke DeleteObject, eax

    mov dword [MasonTmpRC], 2
    mov dword [MasonTmpRC + 4], 2
    mov dword [MasonTmpRC + 8], 708
    mov dword [MasonTmpRC + 12], 34
    invoke CreateSolidBrush, MasonTBarCol
    mov ebx, eax
    invoke FillRect, edi, MasonTmpRC, ebx
    invoke DeleteObject, ebx

    invoke CreatePen, 0, 2, MasonAccCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 2, 34, 0
    invoke LineTo, edi, 708, 34
    pop eax
    invoke DeleteObject, eax

    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, MasonTxtCol
    invoke SelectObject, edi, [MasonHFontT]
    invoke TextOut, edi, 12, 7, MasonTitle, 12

    call Mason3DBoxIn
    call Mason3DBoxOut
    call Mason3DBoxOpt

    invoke CreatePen, 0, 1, 04E4E6Dh
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 21, 59, 0
    invoke LineTo, edi, 587, 59
    invoke LineTo, edi, 587, 85
    invoke LineTo, edi, 21, 85
    invoke LineTo, edi, 21, 59
    invoke MoveToEx, edi, 21, 127, 0
    invoke LineTo, edi, 587, 127
    invoke LineTo, edi, 587, 153
    invoke LineTo, edi, 21, 153
    invoke LineTo, edi, 21, 127
    invoke MoveToEx, edi, 11, 279, 0
    invoke LineTo, edi, 699, 279
    invoke LineTo, edi, 699, 529
    invoke LineTo, edi, 11, 529
    invoke LineTo, edi, 11, 279
    pop eax
    invoke DeleteObject, eax

    invoke EndPaint, [hw], MasonPS
    xor eax, eax
    jmp .MasonOut

.MasonMouseDown:
    movzx eax, word [lp + 2]
    cmp eax, 34
    jge .MasonDefWnd
    invoke ReleaseCapture
    invoke SendMessage, [hw], 0A1h, 2, 0
    xor eax, eax
    jmp .MasonOut

.MasonCmd:
    movzx eax, word [wp]
    cmp eax, Mason_ID_BIN
    je .MasonCBin
    cmp eax, Mason_ID_BOUT
    je .MasonCBout
    cmp eax, Mason_ID_GO
    je .MasonCGo
    cmp eax, Mason_ID_C0
    je .MasonCC0
    cmp eax, Mason_ID_C1
    je .MasonCC1
    cmp eax, Mason_ID_C2
    je .MasonCC2
    cmp eax, Mason_ID_C3
    je .MasonCC3
    cmp eax, Mason_ID_CLOSE
    je .MasonCClose
    cmp eax, Mason_ID_MIN
    je .MasonCMin
    jmp .MasonDefWnd

.MasonCClose:
    invoke DestroyWindow, [hw]
    xor eax, eax
    jmp .MasonOut

.MasonCMin:
    invoke ShowWindow, [hw], SW_MINIMIZE
    xor eax, eax
    jmp .MasonOut

.MasonCBin:
    mov eax, [hw]
    mov dword [MasonOFN], 76
    mov dword [MasonOFN + 4], eax
    mov dword [MasonOFN + 12], MasonFilter
    mov dword [MasonOFN + 24], 1
    mov dword [MasonOFN + 28], MasonPathIn
    mov dword [MasonOFN + 32], 260
    mov dword [MasonOFN + 52], 1804h
    mov byte [MasonPathIn], 0
    invoke GetOpenFileName, MasonOFN
    test eax, eax
    jz .MasonDefWnd
    invoke SetWindowText, [MasonHEditIn], MasonPathIn
    call MasonGenOutName
    invoke SetWindowText, [MasonHEditOut], MasonPathOut
    jmp .MasonDefWnd

.MasonCBout:
    mov eax, [hw]
    mov dword [MasonOFN], 76
    mov dword [MasonOFN + 4], eax
    mov dword [MasonOFN + 12], MasonFilter
    mov dword [MasonOFN + 24], 1
    mov dword [MasonOFN + 28], MasonPathOut
    mov dword [MasonOFN + 32], 260
    mov dword [MasonOFN + 52], 806h
    mov byte [MasonPathOut], 0
    invoke GetSaveFileName, MasonOFN
    test eax, eax
    jz .MasonDefWnd
    invoke SetWindowText, [MasonHEditOut], MasonPathOut
    jmp .MasonDefWnd

.MasonCC0:
    xor byte [MasonChkSt], 1
    invoke InvalidateRect, [MasonHChk0], 0, 1
    jmp .MasonDefWnd
.MasonCC1:
    xor byte [MasonChkSt + 1], 1
    invoke InvalidateRect, [MasonHChk1], 0, 1
    jmp .MasonDefWnd
.MasonCC2:
    xor byte [MasonChkSt + 2], 1
    invoke InvalidateRect, [MasonHChk2], 0, 1
    jmp .MasonDefWnd
.MasonCC3:
    xor byte [MasonChkSt + 3], 1
    invoke InvalidateRect, [MasonHChk3], 0, 1
    jmp .MasonDefWnd

.MasonCGo:
    call MasonProtect
    jmp .MasonDefWnd

.MasonDrawItem:
    mov esi, [lp]
    mov eax, [esi + 4]
    mov edi, [esi + 24]
    lea ebx, [esi + 28]
    mov ecx, [esi + 16]

    cmp eax, Mason_ID_CLOSE
    je .MasonDIClose
    cmp eax, Mason_ID_MIN
    je .MasonDIMin
    cmp eax, Mason_ID_GO
    je .MasonDIGo
    cmp eax, Mason_ID_BIN
    je .MasonDIBrowse
    cmp eax, Mason_ID_BOUT
    je .MasonDIBrowse

    cmp eax, Mason_ID_C0
    je .MasonDIChk
    cmp eax, Mason_ID_C1
    je .MasonDIChk
    cmp eax, Mason_ID_C2
    je .MasonDIChk
    cmp eax, Mason_ID_C3
    je .MasonDIChk
    jmp .MasonDefWnd

.MasonDIClose:
    push ecx
    test ecx, 1
    jnz .MasonDICH
    invoke CreateSolidBrush, MasonTBarCol
    jmp .MasonDICF
.MasonDICH:
    invoke CreateSolidBrush, 04040D0h
.MasonDICF:
    push eax
    invoke FillRect, edi, ebx, eax
    call [DeleteObject]
    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, 0E0E0E0h
    invoke SelectObject, edi, [MasonHFontT]
    invoke DrawText, edi, MasonTX, 1, ebx, 25h
    pop ecx
    mov eax, 1
    jmp .MasonOut

.MasonDIMin:
    push ecx
    test ecx, 1
    jnz .MasonDIMH
    invoke CreateSolidBrush, MasonTBarCol
    jmp .MasonDIMF
.MasonDIMH:
    invoke CreateSolidBrush, MasonHiCol
.MasonDIMF:
    push eax
    invoke FillRect, edi, ebx, eax
    call [DeleteObject]

    invoke CreatePen, 0, 2, 0E0E0E0h
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [ebx]
    add eax, 13
    mov ecx, dword [ebx + 4]
    add ecx, 18
    invoke MoveToEx, edi, eax, ecx, 0
    mov eax, dword [ebx]
    add eax, 27
    mov ecx, dword [ebx + 4]
    add ecx, 18
    invoke LineTo, edi, eax, ecx
    pop eax
    invoke DeleteObject, eax

    pop ecx
    mov eax, 1
    jmp .MasonOut

.MasonDIGo:
    push ecx
    test ecx, 1
    jnz .MasonDIGP

    invoke CreateSolidBrush, MasonAccCol
    push eax
    invoke FillRect, edi, ebx, eax
    call [DeleteObject]
    invoke CreatePen, 0, 1, 08E6E6Eh
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [ebx]
    mov ecx, dword [ebx + 4]
    invoke MoveToEx, edi, eax, ecx, 0
    mov eax, dword [ebx + 8]
    dec eax
    mov ecx, dword [ebx + 4]
    invoke LineTo, edi, eax, ecx
    mov eax, dword [ebx]
    mov ecx, dword [ebx + 4]
    invoke MoveToEx, edi, eax, ecx, 0
    mov ecx, dword [ebx + 12]
    dec ecx
    invoke LineTo, edi, dword [ebx], ecx
    pop eax
    invoke DeleteObject, eax
    invoke CreatePen, 0, 1, 01E1010h
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [ebx + 8]
    dec eax
    mov ecx, dword [ebx + 4]
    invoke MoveToEx, edi, eax, ecx, 0
    mov ecx, dword [ebx + 12]
    dec ecx
    invoke LineTo, edi, eax, ecx
    mov eax, dword [ebx]
    mov ecx, dword [ebx + 12]
    dec ecx
    invoke MoveToEx, edi, eax, ecx, 0
    mov eax, dword [ebx + 8]
    invoke LineTo, edi, eax, ecx
    pop eax
    invoke DeleteObject, eax
    jmp .MasonDIGT

.MasonDIGP:
    invoke CreateSolidBrush, 02A1E1Eh
    push eax
    invoke FillRect, edi, ebx, eax
    call [DeleteObject]
    invoke CreatePen, 0, 1, 01E1010h
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [ebx]
    mov ecx, dword [ebx + 4]
    invoke MoveToEx, edi, eax, ecx, 0
    mov eax, dword [ebx + 8]
    dec eax
    mov ecx, dword [ebx + 4]
    invoke LineTo, edi, eax, ecx
    mov eax, dword [ebx]
    mov ecx, dword [ebx + 4]
    invoke MoveToEx, edi, eax, ecx, 0
    mov ecx, dword [ebx + 12]
    dec ecx
    invoke LineTo, edi, dword [ebx], ecx
    pop eax
    invoke DeleteObject, eax

.MasonDIGT:
    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, 0FFFFFFh
    invoke SelectObject, edi, [MasonHFontT]
    invoke DrawText, edi, MasonLGo, 7, ebx, 25h
    pop ecx
    mov eax, 1
    jmp .MasonOut

.MasonDIBrowse:
    push ecx
    test ecx, 1
    jnz .MasonDIBP

    invoke CreateSolidBrush, MasonBtnFace
    push eax
    invoke FillRect, edi, ebx, eax
    call [DeleteObject]
    invoke CreatePen, 0, 1, MasonHiCol
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [ebx]
    mov ecx, dword [ebx + 4]
    invoke MoveToEx, edi, eax, ecx, 0
    mov eax, dword [ebx + 8]
    dec eax
    invoke LineTo, edi, eax, dword [ebx + 4]
    mov eax, dword [ebx]
    invoke MoveToEx, edi, eax, dword [ebx + 4], 0
    mov ecx, dword [ebx + 12]
    dec ecx
    invoke LineTo, edi, dword [ebx], ecx
    pop eax
    invoke DeleteObject, eax
    invoke CreatePen, 0, 1, MasonBtnShd
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [ebx + 8]
    dec eax
    invoke MoveToEx, edi, eax, dword [ebx + 4], 0
    mov ecx, dword [ebx + 12]
    dec ecx
    invoke LineTo, edi, eax, ecx
    invoke MoveToEx, edi, dword [ebx], ecx, 0
    mov eax, dword [ebx + 8]
    invoke LineTo, edi, eax, ecx
    pop eax
    invoke DeleteObject, eax
    jmp .MasonDIBT

.MasonDIBP:
    invoke CreateSolidBrush, MasonBtnShd
    push eax
    invoke FillRect, edi, ebx, eax
    call [DeleteObject]

.MasonDIBT:
    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, MasonTxtCol
    invoke SelectObject, edi, [MasonHFont]
    invoke DrawText, edi, MasonLBr, 3, ebx, 25h
    pop ecx
    mov eax, 1
    jmp .MasonOut

.MasonDIChk:
    push eax
    sub eax, Mason_ID_C0
    mov ecx, eax
    push ecx

    invoke CreateSolidBrush, MasonBgCol
    push eax
    invoke FillRect, edi, ebx, eax
    call [DeleteObject]

    mov eax, dword [ebx]
    add eax, 2
    mov ecx, dword [ebx + 4]
    add ecx, 3
    mov [MasonCBRc], eax
    mov [MasonCBRc + 4], ecx
    add eax, 14
    add ecx, 14
    mov [MasonCBRc + 8], eax
    mov [MasonCBRc + 12], ecx

    invoke CreateSolidBrush, MasonEdCol
    push eax
    invoke FillRect, edi, MasonCBRc, eax
    call [DeleteObject]

    invoke CreatePen, 0, 1, 04E4E6Dh
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [MasonCBRc]
    mov ecx, dword [MasonCBRc + 4]
    invoke MoveToEx, edi, eax, ecx, 0
    mov eax, dword [MasonCBRc + 8]
    mov ecx, dword [MasonCBRc + 4]
    invoke LineTo, edi, eax, ecx
    mov ecx, dword [MasonCBRc + 12]
    invoke LineTo, edi, eax, ecx
    mov eax, dword [MasonCBRc]
    invoke LineTo, edi, eax, ecx
    mov ecx, dword [MasonCBRc + 4]
    invoke LineTo, edi, eax, ecx
    pop eax
    invoke DeleteObject, eax

    pop ecx
    push ecx
    movzx eax, byte [MasonChkSt + ecx]
    test eax, eax
    jz .MasonDIChkNoMark

    invoke CreatePen, 0, 2, MasonAccCol
    push eax
    invoke SelectObject, edi, eax
    mov eax, dword [MasonCBRc]
    add eax, 3
    mov ecx, dword [MasonCBRc + 4]
    add ecx, 7
    invoke MoveToEx, edi, eax, ecx, 0
    mov eax, dword [MasonCBRc]
    add eax, 6
    mov ecx, dword [MasonCBRc + 4]
    add ecx, 11
    invoke LineTo, edi, eax, ecx
    mov eax, dword [MasonCBRc]
    add eax, 12
    mov ecx, dword [MasonCBRc + 4]
    add ecx, 3
    invoke LineTo, edi, eax, ecx
    pop eax
    invoke DeleteObject, eax

.MasonDIChkNoMark:
    pop ecx
    push ecx
    mov eax, [MasonChkLabels + ecx * 4]
    mov [MasonCBLbl], eax

    mov eax, dword [MasonCBRc + 8]
    add eax, 5
    mov [MasonCBTRc], eax
    mov eax, dword [ebx + 4]
    mov [MasonCBTRc + 4], eax
    mov eax, dword [ebx + 8]
    mov [MasonCBTRc + 8], eax
    mov eax, dword [ebx + 12]
    mov [MasonCBTRc + 12], eax

    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, MasonDimCol
    invoke SelectObject, edi, [MasonHFont]

    invoke lstrlen, dword [MasonCBLbl]
    invoke DrawText, edi, dword [MasonCBLbl], eax, MasonCBTRc, 0

    pop ecx
    pop eax
    mov eax, 1
    jmp .MasonOut

.MasonColorEdit:
    mov eax, [lp]
    cmp eax, [MasonHEditLog]
    je .MasonColorLog
    invoke SetBkColor, [wp], MasonEdCol
    invoke SetTextColor, [wp], MasonTxtCol
    mov eax, [MasonHBrEdit]
    jmp .MasonOut
.MasonColorLog:
    invoke SetBkColor, [wp], MasonLogBg
    invoke SetTextColor, [wp], MasonLogTxt
    mov eax, [MasonHBrLog]
    jmp .MasonOut

.MasonColorStatic:
    invoke SetBkColor, [wp], MasonBgCol
    invoke SetTextColor, [wp], MasonDimCol
    mov eax, [MasonHBrBg]
    jmp .MasonOut

.MasonColorBtn:
    invoke SetBkColor, [wp], MasonEdCol
    invoke SetTextColor, [wp], MasonDimCol
    mov eax, [MasonHBrBg]
    jmp .MasonOut

.MasonDestroy:
    invoke DeleteObject, [MasonHBrBg]
    invoke DeleteObject, [MasonHBrEdit]
    invoke DeleteObject, [MasonHBrLog]
    invoke DeleteObject, [MasonHFontT]
    invoke DeleteObject, [MasonHFont]
    invoke DeleteObject, [MasonHFontM]
    invoke DeleteObject, [MasonHFontL]
    invoke PostQuitMessage, 0
    xor eax, eax
    jmp .MasonOut

.MasonDefWnd:
    invoke DefWindowProc, [hw], [um], [wp], [lp]
.MasonOut:
    pop edi esi ebx
    ret
endp

Mason3DBoxIn:
    pushad
    mov edi, dword [MasonPS]
    invoke CreatePen, 0, 1, MasonShdCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 12, 44, 0
    invoke LineTo, edi, 696, 44
    invoke LineTo, edi, 696, 105
    pop eax
    invoke DeleteObject, eax
    invoke CreatePen, 0, 1, MasonHiCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 696, 105, 0
    invoke LineTo, edi, 12, 105
    invoke LineTo, edi, 12, 44
    pop eax
    invoke DeleteObject, eax
    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, MasonAccCol
    invoke SelectObject, edi, [MasonHFontL]
    invoke TextOut, edi, 22, 46, MasonLI, 10
    popad
    ret

Mason3DBoxOut:
    pushad
    mov edi, dword [MasonPS]
    invoke CreatePen, 0, 1, MasonShdCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 12, 112, 0
    invoke LineTo, edi, 696, 112
    invoke LineTo, edi, 696, 173
    pop eax
    invoke DeleteObject, eax
    invoke CreatePen, 0, 1, MasonHiCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 696, 173, 0
    invoke LineTo, edi, 12, 173
    invoke LineTo, edi, 12, 112
    pop eax
    invoke DeleteObject, eax
    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, MasonAccCol
    invoke SelectObject, edi, [MasonHFontL]
    invoke TextOut, edi, 22, 114, MasonLO, 11
    popad
    ret

Mason3DBoxOpt:
    pushad
    mov edi, dword [MasonPS]
    invoke CreatePen, 0, 1, MasonShdCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 12, 180, 0
    invoke LineTo, edi, 696, 180
    invoke LineTo, edi, 696, 228
    pop eax
    invoke DeleteObject, eax
    invoke CreatePen, 0, 1, MasonHiCol
    push eax
    invoke SelectObject, edi, eax
    invoke MoveToEx, edi, 696, 228, 0
    invoke LineTo, edi, 12, 228
    invoke LineTo, edi, 12, 180
    pop eax
    invoke DeleteObject, eax
    invoke SetBkMode, edi, 1
    invoke SetTextColor, edi, MasonAccCol
    invoke SelectObject, edi, [MasonHFontL]
    invoke TextOut, edi, 22, 182, MasonLOpt, 10
    popad
    ret

MasonBuildUI:
    invoke CreateFont, 19, 0, 0, 0, 700, 0,0,0,0,0,0,4,0, MasonFnt
    mov [MasonHFontT], eax
    invoke CreateFont, 18, 0, 0, 0, 400, 0,0,0,0,0,0,4,0, MasonFnt
    mov [MasonHFont], eax
    invoke CreateFont, 13, 0, 0, 0, 400, 0,0,0,0,0,0,4,0, MasonFntM
    mov [MasonHFontM], eax
    invoke CreateFont, 11, 0, 0, 0, 700, 0,0,0,0,0,0,4,0, MasonFnt
    mov [MasonHFontL], eax
    invoke CreateSolidBrush, MasonBgCol
    mov [MasonHBrBg], eax
    invoke CreateSolidBrush, MasonEdCol
    mov [MasonHBrEdit], eax
    invoke CreateSolidBrush, MasonLogBg
    mov [MasonHBrLog], eax

    invoke CreateWindowEx, 0, MasonBtn, 0, WS_CHILD or WS_VISIBLE or 0Bh,\
        666, 4, 38, 26, [MasonHWnd], Mason_ID_CLOSE, [MasonHInst], 0
    invoke CreateWindowEx, 0, MasonBtn, 0, WS_CHILD or WS_VISIBLE or 0Bh,\
        626, 4, 38, 26, [MasonHWnd], Mason_ID_MIN, [MasonHInst], 0

    invoke CreateWindowEx, 0, MasonEdt, 0, WS_CHILD or WS_VISIBLE or 80h or 100h,\
        22, 60, 564, 24, [MasonHWnd], Mason_ID_EIN, [MasonHInst], 0
    mov [MasonHEditIn], eax
    invoke SendMessage, eax, WM_SETFONT, [MasonHFont], 1

    invoke CreateWindowEx, 0, MasonBtn, 0, WS_CHILD or WS_VISIBLE or 0Bh,\
        596, 59, 90, 26, [MasonHWnd], Mason_ID_BIN, [MasonHInst], 0

    invoke CreateWindowEx, 0, MasonEdt, 0, WS_CHILD or WS_VISIBLE or 80h or 100h,\
        22, 128, 564, 24, [MasonHWnd], Mason_ID_EOUT, [MasonHInst], 0
    mov [MasonHEditOut], eax
    invoke SendMessage, eax, WM_SETFONT, [MasonHFont], 1

    invoke CreateWindowEx, 0, MasonBtn, 0, WS_CHILD or WS_VISIBLE or 0Bh,\
        596, 127, 90, 26, [MasonHWnd], Mason_ID_BOUT, [MasonHInst], 0

    invoke CreateWindowEx, 0, MasonBtn, MasonC0, WS_CHILD or WS_VISIBLE or 0Bh,\
        40, 200, 100, 20, [MasonHWnd], Mason_ID_C0, [MasonHInst], 0
    mov [MasonHChk0], eax
    invoke SendMessage, eax, WM_SETFONT, [MasonHFont], 1

    invoke CreateWindowEx, 0, MasonBtn, MasonC1, WS_CHILD or WS_VISIBLE or 0Bh,\
        200, 200, 120, 20, [MasonHWnd], Mason_ID_C1, [MasonHInst], 0
    mov [MasonHChk1], eax
    invoke SendMessage, eax, WM_SETFONT, [MasonHFont], 1

    invoke CreateWindowEx, 0, MasonBtn, MasonC2, WS_CHILD or WS_VISIBLE or 0Bh,\
        380, 200, 120, 20, [MasonHWnd], Mason_ID_C2, [MasonHInst], 0
    mov [MasonHChk2], eax
    invoke SendMessage, eax, WM_SETFONT, [MasonHFont], 1

    invoke CreateWindowEx, 0, MasonBtn, MasonC3, WS_CHILD or WS_VISIBLE or 0Bh,\
        560, 200, 100, 20, [MasonHWnd], Mason_ID_C3, [MasonHInst], 0
    mov [MasonHChk3], eax
    invoke SendMessage, eax, WM_SETFONT, [MasonHFont], 1

    invoke CreateWindowEx, 0, MasonBtn, 0, WS_CHILD or WS_VISIBLE or 0Bh,\
        220, 236, 268, 36, [MasonHWnd], Mason_ID_GO, [MasonHInst], 0

    invoke SendMessage, eax, 2001h, 0, MasonBgCol

    invoke CreateWindowEx, 0, MasonEdt, 0,\
        WS_CHILD or WS_VISIBLE or 804h or 100h,\
        12, 280, 686, 248, [MasonHWnd], Mason_ID_LOG, [MasonHInst], 0
    mov [MasonHEditLog], eax
    invoke SendMessage, eax, WM_SETFONT, [MasonHFontM], 1
    invoke SetWindowText, [MasonHEditLog], MasonSReady
    ret

MasonLogHex:
    pushad
    mov ecx, 8
    lea edi, [MasonHex + 10]
    mov byte [edi], 0
.MasonLH:
    dec edi
    mov edx, eax
    and edx, 0Fh
    cmp dl, 0Ah
    jb .MasonLD
    add dl, 7
.MasonLD:
    add dl, 30h
    mov [edi], dl
    shr eax, 4
    dec ecx
    jnz .MasonLH
    dec edi
    mov byte [edi], 'x'
    dec edi
    mov byte [edi], '0'
    mov esi, edi
    call MasonLog
    mov esi, MasonNL
    call MasonLog
    popad
    ret

MasonGenOutName:
    invoke lstrcpy, MasonPathOut, MasonPathIn
    invoke lstrlen, MasonPathOut
    lea edi, [MasonPathOut + eax]
.MasonGD:
    dec edi
    cmp edi, MasonPathOut
    jbe .MasonGN
    cmp byte [edi], '.'
    jne .MasonGD
    invoke lstrcpy, MasonTmpBuf, edi
    invoke lstrcpy, edi, MasonSuf
    invoke lstrcat, MasonPathOut, MasonTmpBuf
    ret
.MasonGN:
    invoke lstrcat, MasonPathOut, MasonSuf
    ret

MasonLog:
    cmp dword [MasonHEditLog], 0
    je .MasonR
    pushad
    xor ecx, ecx
.MasonLen:
    cmp byte [esi + ecx], 0
    je .MasonGL
    inc ecx
    jmp .MasonLen
.MasonGL:
    mov edi, [MasonUIPtr]
    lea eax, [edi + ecx]
    lea edx, [MasonUIBuf + 8000]
    cmp eax, edx
    jae .MasonSk
    rep movsb
    mov [MasonUIPtr], edi
.MasonSk:
    popad
.MasonR:
    ret

MasonFlush:
    cmp dword [MasonHEditLog], 0
    je .MasonR
    mov eax, [MasonUIPtr]
    cmp eax, MasonUIBuf
    je .MasonR
    mov byte [eax], 0
    invoke SetWindowText, [MasonHEditLog], MasonUIBuf
.MasonR:
    ret

MasonReset:
    lea eax, [MasonUIBuf]
    mov [MasonUIPtr], eax
    mov byte [eax], 0
    ret

MasonReadFlags:
    mov dword [MasonPFlags], 0
    cmp byte [MasonChkSt], 0
    jz @f
    or dword [MasonPFlags], Mason_FL_E
@@: cmp byte [MasonChkSt + 1], 0
    jz @f
    or dword [MasonPFlags], Mason_FL_D
@@: cmp byte [MasonChkSt + 2], 0
    jz @f
    or dword [MasonPFlags], Mason_FL_M
@@: cmp byte [MasonChkSt + 3], 0
    jz @f
    or dword [MasonPFlags], Mason_FL_V
@@: ret

MasonProtect:
    pushad
    push .MasonSEH
    push dword [fs:0]
    mov [fs:0], esp
    mov [MasonSEH], esp
    mov dword [MasonStep], 10

    call MasonReset

    invoke GetWindowText, [MasonHEditIn], MasonPathIn, 260
    test eax, eax
    jz .MasonNoIn
    invoke GetWindowText, [MasonHEditOut], MasonPathOut, 260
    test eax, eax
    jz .MasonNoIn

    call MasonReadFlags
    or dword [MasonPFlags], Mason_FL_E

    mov dword [MasonStep], 20
    mov esi, MasonS1
    call MasonLog

    invoke CreateFile, MasonPathIn, 80000000h, 1, 0, 3, 80h, 0
    cmp eax, -1
    je .MasonErrOpen
    mov [MasonHFIn], eax

    invoke GetFileSize, [MasonHFIn], 0
    cmp eax, 0FFFFFFFFh
    je .MasonErrSz
    mov [MasonFileSz], eax

    mov esi, MasonSFSz
    call MasonLog
    mov eax, [MasonFileSz]
    call MasonLogHex

    mov eax, [MasonFileSz]
    add eax, 10000h
    invoke VirtualAlloc, 0, eax, 3000h, 4
    test eax, eax
    jz .MasonErrMem
    mov [MasonPEBuf], eax

    invoke ReadFile, [MasonHFIn], [MasonPEBuf], [MasonFileSz], MasonBRead, 0
    invoke CloseHandle, [MasonHFIn]

    mov dword [MasonStep], 30
    mov esi, MasonS2
    call MasonLog

    mov esi, [MasonPEBuf]
    cmp word [esi], 5A4Dh
    jne .MasonErrPE

    mov eax, [esi + 3Ch]
    add eax, esi
    mov [MasonPNT], eax
    cmp dword [eax], 4550h
    jne .MasonErrPE

    movzx ecx, word [eax + 4]
    mov [MasonMach], ecx
    lea ebx, [eax + 18h]
    mov [MasonPOH], ebx

    cmp ecx, 14Ch
    je .MasonChk32
    cmp ecx, 8664h
    je .MasonChk64
    jmp .MasonErrNet

.MasonChk32:
    mov eax, [MasonPOH]
    mov ecx, [eax + 0D0h]
    test ecx, ecx
    jz .MasonErrNet
    movzx ecx, word [eax + 44h]
    mov [MasonSub], ecx
    jmp .MasonNetOK

.MasonChk64:
    mov eax, [MasonPOH]
    mov ecx, [eax + 0E0h]
    test ecx, ecx
    jz .MasonErrNet
    movzx ecx, word [eax + 44h]
    mov [MasonSub], ecx

.MasonNetOK:
    mov esi, MasonSNet
    call MasonLog

    mov dword [MasonStep], 40
    mov esi, MasonS3
    call MasonLog

    invoke GetTickCount
    mov [MasonSeed], eax
    lea edi, [MasonKeyBuf]
    mov ebp, 256
.MasonKG:
    mov eax, [MasonSeed]
    imul eax, 1103515245
    add eax, 12345
    mov [MasonSeed], eax
    shr eax, 16
    and eax, 0FFh
    test al, al
    jnz .MasonKS
    mov al, 42h
.MasonKS:
    stosb
    dec ebp
    jnz .MasonKG

    mov dword [MasonStep], 50
    mov esi, MasonS4
    call MasonLog

    mov esi, [MasonPEBuf]
    mov ecx, [MasonFileSz]
    xor edx, edx
.MasonEnc:
    mov al, [esi + edx]
    mov ebx, edx
    and ebx, 0FFh
    xor al, [MasonKeyBuf + ebx]
    mov [esi + edx], al
    inc edx
    cmp edx, ecx
    jb .MasonEnc

    mov dword [MasonStep], 60
    mov esi, MasonS5
    call MasonLog

    mov eax, MasonStubEnd - MasonStubBin
    mov [MasonStubSz], eax

    mov dword [MasonStep], 65
    invoke VirtualAlloc, 0, [MasonStubSz], 3000h, 4
    test eax, eax
    jz .MasonErrMem
    mov [MasonOutBuf], eax

    mov edi, eax
    mov esi, MasonStubBin
    mov ecx, [MasonStubSz]
    rep movsb

    mov dword [MasonStep], 70
    mov edi, [MasonOutBuf]
    mov eax, [edi + 3Ch]
    lea eax, [edi + eax]
    mov cx, word [MasonSub]
    mov word [eax + 5Ch], cx

    mov dword [MasonStep], 85
    mov esi, MasonS6
    call MasonLog
    mov esi, MasonSOutP
    call MasonLog
    mov esi, MasonPathOut
    call MasonLog
    mov esi, MasonNL
    call MasonLog
    call MasonFlush

    invoke CreateFile, MasonPathOut, 40000000h, 0, 0, 2, 80h, 0
    cmp eax, -1
    je .MasonErrWr1
    mov [MasonHFOut], eax

    invoke WriteFile, [MasonHFOut], [MasonOutBuf], [MasonStubSz], MasonBWr, 0
    invoke CloseHandle, [MasonHFOut]
    invoke VirtualFree, [MasonOutBuf], 0, 8000h

    mov dword [MasonStep], 90
    mov esi, MasonS7
    call MasonLog
    call MasonCopyRes

    invoke Sleep, 200

    mov dword [MasonStep], 95
    mov esi, MasonS8
    call MasonLog
    call MasonFlush

    mov dword [MasonRetry], 5
.MasonRetryOpen:
    invoke CreateFile, MasonPathOut, 40000000h or 80000000h, 3, 0, 3, 80h, 0
    cmp eax, -1
    jne .MasonOpenOK
    dec dword [MasonRetry]
    jz .MasonErrWr2
    invoke Sleep, 300
    jmp .MasonRetryOpen
.MasonOpenOK:
    mov [MasonHFOut], eax

    invoke GetFileSize, [MasonHFOut], 0
    mov [MasonNewStub], eax

    lea ecx, [MasonTrail]
    invoke ReadFile, [MasonHFOut], MasonTmpBuf, 256, ecx, 0
    mov esi, MasonTmpBuf
    mov eax, [esi + 3Ch]
    lea eax, [eax + 5Ch]
    invoke SetFilePointer, [MasonHFOut], eax, 0, 0
    mov cx, word [MasonSub]
    mov word [MasonTmpBuf], cx
    lea ecx, [MasonTrail]
    invoke WriteFile, [MasonHFOut], MasonTmpBuf, 2, ecx, 0

    invoke SetFilePointer, [MasonHFOut], 0, 0, 2
    invoke WriteFile, [MasonHFOut], [MasonPEBuf], [MasonFileSz], MasonBWr, 0

    lea edi, [MasonTrail]
    mov eax, [MasonNewStub]
    stosd
    mov eax, [MasonFileSz]
    stosd
    mov eax, [MasonPFlags]
    stosd
    lea esi, [MasonKeyBuf]
    mov ecx, 256
    rep movsb

    invoke WriteFile, [MasonHFOut], MasonTrail, 268, MasonBWr, 0
    invoke CloseHandle, [MasonHFOut]
    invoke VirtualFree, [MasonPEBuf], 0, 8000h

    mov esi, MasonSDone
    call MasonLog
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonMOK, MasonTitle, 40h
    jmp .MasonExit

.MasonNoIn:
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonMNoIn, MasonTitle, 30h
    jmp .MasonExit
.MasonErrOpen:
    mov esi, MasonEOpen
    call MasonLog
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonEOpen, MasonTitle, 10h
    jmp .MasonExit
.MasonErrSz:
    invoke CloseHandle, [MasonHFIn]
    jmp .MasonExit
.MasonErrMem:
    mov esi, MasonEMem
    call MasonLog
    call MasonFlush
    jmp .MasonExit
.MasonErrPE:
    invoke VirtualFree, [MasonPEBuf], 0, 8000h
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonEPE, MasonTitle, 10h
    jmp .MasonExit
.MasonErrNet:
    invoke VirtualFree, [MasonPEBuf], 0, 8000h
    mov esi, MasonENet
    call MasonLog
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonENet, MasonTitle, 10h
    jmp .MasonExit
.MasonErrWr1:
    invoke GetLastError
    push eax
    mov esi, MasonEWr1D
    call MasonLog
    pop eax
    call MasonLogHex
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonEWr, MasonTitle, 10h
    jmp .MasonExit
.MasonErrWr2:
    invoke GetLastError
    push eax
    mov esi, MasonEWr2D
    call MasonLog
    pop eax
    call MasonLogHex
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonEWr, MasonTitle, 10h
    jmp .MasonExit

.MasonExit:
    mov esp, [MasonSEH]
    pop dword [fs:0]
    add esp, 4
    popad
    ret

.MasonSEH:
    mov ecx, [esp + 12]
    mov dword [ecx + 0B8h], .MasonCrash
    mov eax, [MasonSEH]
    mov [ecx + 0C4h], eax
    xor eax, eax
    ret

.MasonCrash:
    pop dword [fs:0]
    add esp, 4
    cld
    mov esi, MasonECrash
    lea edi, [MasonCrBuf]
.MasonCC:
    lodsb
    stosb
    test al, al
    jnz .MasonCC
    dec edi
    mov eax, [MasonStep]
    xor edx, edx
    mov ecx, 100
    div ecx
    test al, al
    jz .MasonNH
    add al, '0'
    stosb
.MasonNH:
    mov eax, edx
    xor edx, edx
    mov ecx, 10
    div ecx
    add al, '0'
    stosb
    add dl, '0'
    mov [edi], dl
    mov byte [edi + 1], 0
    call MasonFlush
    invoke MessageBox, [MasonHWnd], MasonCrBuf, MasonTitle, 10h
    popad
    ret

MasonCopyRes:
    pushad

    invoke GetModuleHandle, MasonK32
    test eax, eax
    jz .MasonCRDone
    mov ebx, eax

    invoke GetProcAddress, ebx, MasonSBUR
    test eax, eax
    jz .MasonCRDone
    mov [MasonFnBUR], eax

    invoke GetProcAddress, ebx, MasonSUR
    test eax, eax
    jz .MasonCRDone
    mov [MasonFnUR], eax

    invoke GetProcAddress, ebx, MasonSEUR
    test eax, eax
    jz .MasonCRDone
    mov [MasonFnEUR], eax

    invoke GetProcAddress, ebx, MasonSERN
    test eax, eax
    jz .MasonCRDone
    mov [MasonFnERN], eax

    invoke LoadLibraryEx, MasonPathIn, 0, 22h
    test eax, eax
    jnz .MasonCRLoaded
    invoke LoadLibraryEx, MasonPathIn, 0, 2
    test eax, eax
    jz .MasonCRNoLib
.MasonCRLoaded:
    mov [MasonHResIn], eax

    push 0
    push MasonPathOut
    call [MasonFnBUR]
    test eax, eax
    jz .MasonCRFreeLib
    mov [MasonHUpd], eax

    mov dword [MasonResFound], 0
    mov dword [MasonGrpCount], 0

    push 0
    push MasonEnumCB
    push 14
    push [MasonHResIn]
    call [MasonFnERN]

    mov eax, [MasonGrpCount]
    test eax, eax
    jz .MasonCRNoGrp

    xor edi, edi
.MasonCRGrpLp:
    cmp edi, [MasonGrpCount]
    jge .MasonCRTryVer

    mov eax, [MasonGrpIds + edi * 4]
    mov [MasonCurGrpId], eax

    invoke FindResource, [MasonHResIn], [MasonCurGrpId], 14
    test eax, eax
    jz .MasonCRGrpNx
    mov [MasonHResF], eax

    invoke SizeofResource, [MasonHResIn], [MasonHResF]
    test eax, eax
    jz .MasonCRGrpNx
    mov [MasonResSz], eax

    invoke LoadResource, [MasonHResIn], [MasonHResF]
    test eax, eax
    jz .MasonCRGrpNx

    invoke LockResource, eax
    test eax, eax
    jz .MasonCRGrpNx
    mov [MasonResPtr], eax

    push [MasonResSz]
    push [MasonResPtr]
    push 0
    push [MasonCurGrpId]
    push 14
    push [MasonHUpd]
    call [MasonFnUR]
    test eax, eax
    jz .MasonCRGrpNx

    or dword [MasonResFound], 1

    mov esi, [MasonResPtr]
    movzx ecx, word [esi + 4]
    test ecx, ecx
    jz .MasonCRGrpNx
    mov [MasonIconCnt], ecx
    xor ebx, ebx

.MasonCRIcoLp:
    cmp ebx, [MasonIconCnt]
    jge .MasonCRGrpNx

    lea eax, [esi + 6]
    imul edx, ebx, 14
    add eax, edx
    movzx eax, word [eax + 12]
    mov [MasonIconId], eax

    invoke FindResource, [MasonHResIn], [MasonIconId], 3
    test eax, eax
    jz .MasonCRIcoNx
    mov [MasonHResF], eax

    invoke SizeofResource, [MasonHResIn], [MasonHResF]
    mov [MasonResSz], eax

    invoke LoadResource, [MasonHResIn], [MasonHResF]
    test eax, eax
    jz .MasonCRIcoNx
    invoke LockResource, eax
    test eax, eax
    jz .MasonCRIcoNx

    push [MasonResSz]
    push eax
    push 0
    push [MasonIconId]
    push 3
    push [MasonHUpd]
    call [MasonFnUR]

.MasonCRIcoNx:
    inc ebx
    mov esi, [MasonResPtr]
    jmp .MasonCRIcoLp

.MasonCRGrpNx:
    inc edi
    jmp .MasonCRGrpLp

.MasonCRNoGrp:
    mov esi, MasonSIcoNo
    call MasonLog
    jmp .MasonCRTryVer

.MasonCRTryVer:
    invoke FindResource, [MasonHResIn], 1, 16
    test eax, eax
    jz .MasonCRNoVrF
    mov [MasonHResF], eax

    invoke SizeofResource, [MasonHResIn], [MasonHResF]
    test eax, eax
    jz .MasonCREndUpd
    mov [MasonResSz], eax

    invoke LoadResource, [MasonHResIn], [MasonHResF]
    test eax, eax
    jz .MasonCREndUpd
    invoke LockResource, eax
    test eax, eax
    jz .MasonCREndUpd

    push [MasonResSz]
    push eax
    push 0
    push 1
    push 16
    push [MasonHUpd]
    call [MasonFnUR]
    test eax, eax
    jz .MasonCREndUpd

    or dword [MasonResFound], 2
    jmp .MasonCREndUpd

.MasonCRNoVrF:
    mov esi, MasonSVerNo
    call MasonLog

.MasonCREndUpd:
    push 0
    push [MasonHUpd]
    call [MasonFnEUR]
    test eax, eax
    jz .MasonCRFreeLib

    test dword [MasonResFound], 1
    jz .MasonCRChkVer
    mov esi, MasonSIcoOK
    call MasonLog
.MasonCRChkVer:
    test dword [MasonResFound], 2
    jz .MasonCRFreeLib
    mov esi, MasonSVerOK
    call MasonLog
    jmp .MasonCRFreeLib

.MasonCRNoLib:
    mov esi, MasonSResNoLib
    call MasonLog
    jmp .MasonCRDone

.MasonCRFreeLib:
    invoke FreeLibrary, [MasonHResIn]

.MasonCRDone:
    popad
    ret

proc MasonEnumCB hMod, lpType, lpName, lParam
    push ebx
    mov eax, [MasonGrpCount]
    cmp eax, 16
    jge .MasonECBDone
    mov ecx, [lpName]
    mov [MasonGrpIds + eax * 4], ecx
    inc dword [MasonGrpCount]
.MasonECBDone:
    mov eax, 1
    pop ebx
    ret
endp

MasonLogVal:
    pushad
    mov esi, [esp + 36]
    call MasonLog
    mov eax, [esp + 40]
    call MasonLogHex
    popad
    ret 8

MasonStubBin:
    file '../stub/stub.exe'
MasonStubEnd:

section '.MasonD' data readable writeable

MasonCls   db 'MasonWnd', 0
MasonTitle db 'MasonPatriot', 0
MasonFnt   db 'Segoe UI', 0
MasonFntM  db 'Consolas', 0
MasonEdt   db 'EDIT', 0
MasonBtn   db 'BUTTON', 0

MasonLI   db 'INPUT FILE', 0
MasonLO   db 'OUTPUT FILE', 0
MasonLOpt db 'PROTECTION', 0
MasonLBr  db '...', 0
MasonLGo  db 'PROTECT', 0
MasonTX   db 'X', 0

MasonC0 db 'Encrypt', 0
MasonC1 db 'Anti-Debug', 0
MasonC2 db 'Anti-Dump', 0
MasonC3 db 'Anti-VM', 0

MasonSuf db '_protected', 0
MasonNL db 13, 10, 0

MasonSReady db '[*] MasonPatriot .NET Protector', 13, 10, '[*] Select .NET assembly to protect', 13, 10, 0

MasonS1 db '[1/8] Loading file...', 13, 10, 0
MasonS2 db '[2/8] Parsing PE headers...', 13, 10, 0
MasonS3 db '[3/8] Generating encryption key...', 13, 10, 0
MasonS4 db '[4/8] Encrypting assembly...', 13, 10, 0
MasonS5 db '[5/8] Building native wrapper...', 13, 10, 0
MasonS6 db '[6/8] Writing stub...', 13, 10, 0
MasonS7 db '[7/8] Copying icon & version...', 13, 10, 0
MasonS8 db '[8/8] Appending payload...', 13, 10, 0
MasonSDone db 13, 10, '[+] PROTECTED SUCCESSFULLY!', 13, 10, 0

MasonSFSz   db '[+] File size: ', 0
MasonSOutP  db '[+] Output: ', 0
MasonSNet   db '[+] Valid .NET assembly', 13, 10, 0
MasonSIcoOK db '[+] Icon copied', 13, 10, 0
MasonSIcoNo db '[-] No icon found in original', 13, 10, 0
MasonSVerOK db '[+] Version info copied', 13, 10, 0
MasonSVerNo db '[-] No version info in original', 13, 10, 0
MasonSResNoLib db '[-] LoadLibraryEx failed on input', 13, 10, 0

MasonEOpen  db '[!] Cannot open input file', 0
MasonEMem   db '[!] Memory allocation failed', 0
MasonEPE    db '[!] Not a valid PE file', 0
MasonEWr    db '[!] Cannot create output file', 0
MasonEWr1D  db '[!] CreateFile#1 err: ', 0
MasonEWr2D  db '[!] CreateFile#2 err: ', 0
MasonECrash db '[!] Crashed at step ', 0
MasonENet   db '[!] Not a .NET assembly!', 0

MasonMOK   db 'Protected successfully!', 0
MasonMNoIn db 'Select input and output files first.', 0

MasonFilter db '.NET Executables (*.exe)', 0, '*.exe', 0, 'All (*.*)', 0, '*.*', 0, 0

MasonK32  db 'kernel32.dll', 0
MasonSBUR db 'BeginUpdateResourceA', 0
MasonSUR  db 'UpdateResourceA', 0
MasonSEUR db 'EndUpdateResourceA', 0
MasonSERN db 'EnumResourceNamesA', 0

MasonPathIn   rb 260
MasonPathOut  rb 260
MasonTmpBuf   rb 260
MasonHex      rb 16

MasonOFN dd 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

MasonWC  rb 48
MasonMSG rb 28
MasonPS  rb 64
MasonTmpRC dd 0, 0, 0, 0

MasonHInst     dd 0
MasonHWnd      dd 0
MasonHEditIn   dd 0
MasonHEditOut  dd 0
MasonHEditLog  dd 0
MasonHChk0     dd 0
MasonHChk1     dd 0
MasonHChk2     dd 0
MasonHChk3     dd 0
MasonHFontT    dd 0
MasonHFont     dd 0
MasonHFontM    dd 0
MasonHFontL    dd 0
MasonHBrBg     dd 0
MasonHBrEdit   dd 0
MasonHBrLog    dd 0

MasonHFIn      dd 0
MasonHFOut     dd 0
MasonFileSz    dd 0
MasonBRead     dd 0
MasonBWr       dd 0
MasonPEBuf     dd 0
MasonPNT       dd 0
MasonPOH       dd 0

MasonMach      dd 0
MasonSub       dd 0
MasonPFlags    dd 0
MasonKeyBuf    rb 256
MasonSeed      dd 0

MasonOutBuf    dd 0
MasonStubSz    dd 0
MasonNewStub   dd 0
MasonTrail     rb 268

MasonHResIn    dd 0
MasonHUpd      dd 0
MasonHResF     dd 0
MasonResSz     dd 0
MasonResPtr    dd 0
MasonIconCnt   dd 0
MasonIconId    dd 0
MasonFnBUR     dd 0
MasonFnUR      dd 0
MasonFnEUR     dd 0
MasonFnERN     dd 0
MasonResFound  dd 0
MasonGrpIds    rd 16
MasonGrpCount  dd 0
MasonCurGrpId  dd 0

MasonStep      dd 0
MasonRetry     dd 0

MasonChkSt     db 1, 1, 1, 0

MasonChkLabels dd MasonC0, MasonC1, MasonC2, MasonC3

MasonCBRc      dd 0, 0, 0, 0
MasonCBTRc     dd 0, 0, 0, 0
MasonCBLbl     dd 0
MasonCrBuf     rb 64
MasonSEH       dd 0

MasonUIBuf rb 8192
MasonUIPtr dd 0

section '.MasonR' resource data readable

  directory RT_GROUP_ICON, MasonGrpIcons,\
            RT_ICON, MasonRawIcons

  resource MasonGrpIcons,\
           1, LANG_NEUTRAL, MasonMainGrp

  resource MasonRawIcons,\
           1, LANG_NEUTRAL, MasonMainIco

  icon MasonMainGrp, MasonMainIco, 'icon.ico'
