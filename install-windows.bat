@echo off
REM ChatModes System - Windows Batch Installer
REM ==========================================

echo.
echo   ╔═══════════════════════════════════════╗
echo   ║    ChatModes System Installer        ║
echo   ║         Windows Batch                ║
echo   ╚═══════════════════════════════════════╝
echo.

echo Escolha o método de instalação:
echo.
echo [1] PowerShell (Recomendado)
echo [2] Git Bash (Bash Script)
echo [3] Cancelar
echo.

set /p choice="Digite sua opção (1-3): "

if "%choice%"=="1" goto powershell
if "%choice%"=="2" goto gitbash
if "%choice%"=="3" goto cancel
goto invalid

:powershell
echo.
echo Executando instalador PowerShell...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1"
goto end

:gitbash
echo.
echo Verificando Git Bash...
where bash >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: Git Bash não encontrado
    echo Por favor, instale o Git for Windows ou use a opção PowerShell
    pause
    goto end
)

echo Executando instalador Bash...
echo.
bash "%~dp0install.sh"
goto end

:cancel
echo.
echo Instalação cancelada.
goto end

:invalid
echo.
echo Opção inválida. Tente novamente.
pause
goto start

:end
echo.
pause
