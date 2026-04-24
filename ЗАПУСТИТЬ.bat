@echo off
title Payroll System - Docker

echo.
echo ============================================================
echo   Sistema nachisleniya zarplaty
echo   Zapusk cherez Docker
echo ============================================================
echo.

set "SCRIPT_DIR=%~dp0"
set "APP_DIR=%SCRIPT_DIR%winforms-prototype\bin\Release\net8.0-windows"
set "APP_EXE=%APP_DIR%\PayrollWinFormsPrototype.exe"

echo [1/5] Proverka Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Docker ne najden!
    echo     https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)
echo     Docker OK
echo.

echo [2/5] Zapusk MySQL v Docker...
cd /d "%SCRIPT_DIR%"
docker compose up -d
if %errorlevel% neq 0 (
    docker-compose up -d
    if %errorlevel% neq 0 (
        echo [!] Oshibka docker compose. Zapustite Docker Desktop!
        pause
        exit /b 1
    )
)
echo     Kontejner zapushchen.
echo.

echo [3/5] Ozhidaem MySQL (do 60 sek)...
set /a COUNT=0
:wait_loop
set /a COUNT+=1
if %COUNT% gtr 12 (
    echo [!] MySQL ne otvechaet. Proverite Docker Desktop.
    pause
    exit /b 1
)
docker exec payroll_mysql mysqladmin ping -h localhost -u root -proot --silent >nul 2>&1
if %errorlevel% neq 0 (
    echo     Ozhidaem... %COUNT%/12
    timeout /t 5 /nobreak >nul
    goto :wait_loop
)
echo     MySQL gotov!
echo.

echo [4/5] Sborka prilozheniya (dotnet build)...
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] dotnet ne najden: https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)
cd /d "%SCRIPT_DIR%winforms-prototype"
dotnet build -c Release
if %errorlevel% neq 0 (
    echo [!] Oshibka sborki!
    pause
    exit /b 1
)
echo     Sborka OK
echo.

echo [5/5] Zapusk...
start "" "%APP_EXE%"
echo     Prilozhenie zapushcheno!

:end
echo.
echo ============================================================
echo   Gotovo!
echo   Chtoby ostanovit BD: docker compose down
echo ============================================================
echo.
pause
