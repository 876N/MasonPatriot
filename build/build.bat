@echo off
setlocal enabledelayedexpansion

set "LOG=%~dp0build_log.txt"

echo ============================================ > "%LOG%"
echo  MasonPatriot Build Log >> "%LOG%"
echo  %date% %time% >> "%LOG%"
echo ============================================ >> "%LOG%"

echo.
echo  ============================================
echo   MasonPatriot .NET Protector - Build
echo  ============================================
echo.

set "FASM_EXE="

where fasm.exe >nul 2>&1
if not errorlevel 1 (
    set "FASM_EXE=fasm"
    goto :found
)

for %%P in (
    "%~dp0fasm.exe"
    "%~dp0..\fasm\fasm.exe"
    "C:\fasm\fasm.exe"
    "%USERPROFILE%\fasm\fasm.exe"
    "%USERPROFILE%\Desktop\fasm\fasm.exe"
    "%USERPROFILE%\Downloads\fasm\fasm.exe"
) do (
    if exist %%~P (
        set "FASM_EXE=%%~P"
        goto :found
    )
)

echo  [!] FASM not found >> "%LOG%"
echo  [!] FASM not found
echo  Download: https://flatassembler.net/download.php
pause
exit /b 1

:found
echo  [*] FASM: %FASM_EXE% >> "%LOG%"
echo  [*] FASM: %FASM_EXE%

for %%F in ("%FASM_EXE%") do set "FASM_DIR=%%~dpF"
if exist "%FASM_DIR%INCLUDE" (
    set "INCLUDE=%FASM_DIR%INCLUDE"
    echo  [*] INCLUDE: %FASM_DIR%INCLUDE >> "%LOG%"
    echo  [*] INCLUDE: %FASM_DIR%INCLUDE
)
echo.

if not exist "%~dp0output" mkdir "%~dp0output"

echo  [1/2] Compiling native stub... >> "%LOG%"
echo  [1/2] Compiling native stub...

cd /d "%~dp0..\stub"

if exist stub.exe del /f stub.exe

"%FASM_EXE%" stub.asm stub.exe >> "%LOG%" 2>&1
if errorlevel 1 (
    echo  [FAIL] Stub compilation failed >> "%LOG%"
    echo  [FAIL] Stub compilation failed
    echo.
    type "%LOG%"
    pause
    exit /b 1
)

for %%F in (stub.exe) do (
    echo  [OK] stub.exe ^(%%~zF bytes^) >> "%LOG%"
    echo  [OK] stub.exe ^(%%~zF bytes^)
)

echo.
echo  [2/2] Compiling main... >> "%LOG%"
echo  [2/2] Compiling main...

cd /d "%~dp0..\src"

"%FASM_EXE%" main.asm "%~dp0output\MasonPatriot.exe" >> "%LOG%" 2>&1
if errorlevel 1 (
    echo  [FAIL] Main compilation failed >> "%LOG%"
    echo  [FAIL] Main compilation failed
    echo.
    type "%LOG%"
    pause
    exit /b 1
)

for %%F in ("%~dp0output\MasonPatriot.exe") do (
    echo  [OK] MasonPatriot.exe ^(%%~zF bytes^) >> "%LOG%"
    echo  [OK] MasonPatriot.exe ^(%%~zF bytes^)
)

echo.
echo  ============================================
echo   BUILD OK
echo   %~dp0output\MasonPatriot.exe
echo  ============================================
echo.
pause
