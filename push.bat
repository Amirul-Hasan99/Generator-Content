@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo ERROR: Folder ini bukan repository Git.
    pause
    exit /b 1
)

for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if not defined BRANCH set "BRANCH=main"

echo Menambahkan perubahan...
git add -A
if errorlevel 1 goto :error

git diff --cached --quiet
if not errorlevel 1 (
    echo Tidak ada perubahan baru untuk di-commit.
) else (
    set "COMMIT_MESSAGE="
    set /p "COMMIT_MESSAGE=Pesan commit (kosong = Update %DATE% %TIME%): "
    if not defined COMMIT_MESSAGE set "COMMIT_MESSAGE=Update %DATE% %TIME%"
    git commit -m "!COMMIT_MESSAGE!"
    if errorlevel 1 goto :error
)

echo Mengirim branch %BRANCH% ke origin...
git push -u origin "%BRANCH%"
if errorlevel 1 goto :error

echo.
echo Push berhasil.
pause
exit /b 0

:error
echo.
echo ERROR: Proses push gagal. Periksa pesan Git di atas.
pause
exit /b 1
