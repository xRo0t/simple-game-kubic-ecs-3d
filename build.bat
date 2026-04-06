@echo off
setlocal enabledelayedexpansion

:: إعداد المسارات
set COMPILER=doletc
set ENTRY_FILE=src/main.dlt
set OUTPUT_DIR=bin
set OUTPUT_EXE=%OUTPUT_DIR%\main.exe

echo [INFO] Starting Dolet Build Process...

:: 1. التأكد من وجود مجلد bin، وإنشاؤه إذا كان مفقوداً
if not exist %OUTPUT_DIR% (
    echo [INFO] Creating directory: %OUTPUT_DIR%
    mkdir %OUTPUT_DIR%
)

:: 2. تنظيف النسخة القديمة (اختياري)
if exist %OUTPUT_EXE% (
    del /f /q %OUTPUT_EXE%
)

:: 3. عملية البناء (Build)
echo [BUILD] Compiling %ENTRY_FILE%...
%COMPILER% %ENTRY_FILE% -o %OUTPUT_EXE%

:: 4. التحقق من نجاح العملية
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Build completed successfully! 🚀
    echo [PATH] Saved to: %OUTPUT_EXE%
    
    :: تشغيل البرنامج مباشرة بعد البناء (اختياري، يمكنك حذف السطرين القادمين)
    echo [RUN] Launching application...
    %OUTPUT_EXE%
) else (
    echo.
    echo [ERROR] Compilation failed with error code: %ERRORLEVEL% ❌
    pause
)

endlocal