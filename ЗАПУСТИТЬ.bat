@echo off
chcp 65001 > nul
title Система начисления зарплаты — автозапуск

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║     Система начисления и выплаты зарплаты               ║
echo ║     Автозапуск базы данных и приложения                  ║
echo ║     Бойченко Сергей Петрович                             ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM ─── Пути ───────────────────────────────────────────────────────────────────
set "SCRIPT_DIR=%~dp0"
set "SQL_DIR=%SCRIPT_DIR%sql"
set "APP_DIR=%SCRIPT_DIR%winforms-prototype\bin\Release\net8.0-windows"
set "APP_EXE=%APP_DIR%\PayrollWinFormsPrototype.exe"
set "MYSQL_BIN="

REM ─── Поиск MySQL в стандартных местах ───────────────────────────────────────
echo [1/5] Поиск MySQL...

for %%D in (
    "C:\Program Files\MySQL\MySQL Server 8.0\bin"
    "C:\Program Files\MySQL\MySQL Server 8.4\bin"
    "C:\Program Files\MySQL\MySQL Server 9.0\bin"
    "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin"
    "C:\xampp\mysql\bin"
    "C:\wamp64\bin\mysql\mysql8.0\bin"
    "C:\wamp\bin\mysql\mysql8.0\bin"
    "C:\laragon\bin\mysql\mysql-8.0\bin"
) do (
    if exist "%%~D\mysql.exe" (
        set "MYSQL_BIN=%%~D"
        goto :found_mysql
    )
)

REM Попробовать найти через where
where mysql >nul 2>&1
if %errorlevel% == 0 (
    set "MYSQL_BIN="
    goto :found_mysql
)

REM MySQL не найден
echo.
echo [!] MySQL не найден на этом компьютере!
echo.
echo     Установите MySQL Community Server (бесплатно):
echo     https://dev.mysql.com/downloads/mysql/
echo.
echo     После установки снова запустите этот файл.
echo.
echo     ЛИБО: если MySQL установлен в нестандартную папку,
echo     добавьте путь к папке bin в переменную PATH.
echo.
pause
exit /b 1

:found_mysql
if defined MYSQL_BIN (
    echo     Найден: %MYSQL_BIN%
    set "MYSQL=%MYSQL_BIN%\mysql.exe"
    set "MYSQLADMIN=%MYSQL_BIN%\mysqladmin.exe"
    set "MYSQLSERVICE_BIN=%MYSQL_BIN%"
) else (
    echo     Найден в PATH
    set "MYSQL=mysql"
    set "MYSQLADMIN=mysqladmin"
)
echo     OK
echo.

REM ─── Запуск службы MySQL ────────────────────────────────────────────────────
echo [2/5] Запуск службы MySQL...

REM Попробовать запустить службу (несколько возможных имён)
net start MySQL80 >nul 2>&1
if %errorlevel% == 0 goto :service_ok

net start MySQL84 >nul 2>&1
if %errorlevel% == 0 goto :service_ok

net start MySQL >nul 2>&1
if %errorlevel% == 0 goto :service_ok

REM Служба уже запущена — проверим пингом
"%MYSQL%" -u root --connect-timeout=3 -e "SELECT 1;" >nul 2>&1
if %errorlevel% == 0 (
    echo     Служба уже была запущена.
    goto :service_ok
)

REM Пробуем без пароля на root (свежая установка)
"%MYSQL%" -u root --password= --connect-timeout=3 -e "SELECT 1;" >nul 2>&1
if %errorlevel% == 0 (
    echo     Служба уже была запущена (пустой пароль root).
    goto :service_ok
)

echo.
echo [!] Не удалось запустить службу MySQL автоматически.
echo     Попробуйте запустить вручную:
echo       Пуск → Службы → найдите MySQL80 → Запустить
echo     Или откройте MySQL Workbench и убедитесь что сервер работает.
echo.
pause
exit /b 1

:service_ok
echo     OK
echo.

REM ─── Проверка подключения с паролем payroll_admin ───────────────────────────
echo [3/5] Проверка подключения к базе данных...

REM Сначала пробуем как payroll_admin (если база уже создана)
"%MYSQL%" -u payroll_admin -pAdmin#2026 --connect-timeout=5 salary_payroll_db -e "SELECT 1;" >nul 2>&1
if %errorlevel% == 0 (
    echo     База уже существует, пользователь payroll_admin найден.
    echo     Пропускаем создание базы.
    goto :db_ready
)

REM Пробуем как root (без пароля) — создаём базу
echo     Подключение как root (без пароля)...
"%MYSQL%" -u root --password= --connect-timeout=5 -e "SELECT 1;" >nul 2>&1
if %errorlevel% == 0 (
    set "ADMIN_CMD=%MYSQL% -u root --password="
    goto :create_db
)

REM Пробуем как root с паролем из диалога
echo.
echo     MySQL найден, но нужен пароль root.
echo     (Если пароль не задавали при установке — просто нажмите Enter)
echo.
set /p "ROOT_PASS=     Введите пароль root: "

"%MYSQL%" -u root -p%ROOT_PASS% --connect-timeout=5 -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] Неверный пароль root. Запуск прерван.
    echo     Если забыли пароль — переустановите MySQL.
    pause
    exit /b 1
)
set "ADMIN_CMD=%MYSQL% -u root -p%ROOT_PASS%"

:create_db
echo     Создание базы данных...
echo.

if not exist "%SQL_DIR%\01_schema.sql" (
    echo [!] Файл sql\01_schema.sql не найден!
    echo     Убедитесь что структура папок не изменена.
    pause
    exit /b 1
)

echo     Шаг 1: Создание таблиц (01_schema.sql)...
%ADMIN_CMD% < "%SQL_DIR%\01_schema.sql"
if %errorlevel% neq 0 (
    echo [!] Ошибка при выполнении 01_schema.sql
    pause
    exit /b 1
)

echo     Шаг 2: Загрузка тестовых данных (02_seed.sql)...
%ADMIN_CMD% < "%SQL_DIR%\02_seed.sql"
if %errorlevel% neq 0 (
    echo [!] Ошибка при выполнении 02_seed.sql
    pause
    exit /b 1
)

echo     Шаг 3: Представления и процедуры (03_queries.sql)...
%ADMIN_CMD% < "%SQL_DIR%\03_queries.sql"
if %errorlevel% neq 0 (
    echo [!] Ошибка при выполнении 03_queries.sql
    pause
    exit /b 1
)

echo     Шаг 4: Пользователи и права доступа (04_security.sql)...
%ADMIN_CMD% < "%SQL_DIR%\04_security_and_backup.sql"
if %errorlevel% neq 0 (
    echo [!] Ошибка при выполнении 04_security_and_backup.sql
    pause
    exit /b 1
)

echo.
echo     База данных salary_payroll_db успешно создана!

:db_ready
echo     OK
echo.

REM ─── Запуск приложения ───────────────────────────────────────────────────────
echo [4/5] Поиск исполняемого файла приложения...

if exist "%APP_EXE%" (
    echo     Найден скомпилированный exe: %APP_EXE%
    goto :launch_exe
)

REM exe не найден — пробуем dotnet run
echo     Скомпилированный exe не найден.
echo     Попытка запустить через dotnet run...

where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] dotnet SDK не установлен и exe не найден.
    echo     Установите .NET 8 SDK: https://dotnet.microsoft.com/download/dotnet/8.0
    echo     Или скомпилируйте проект: dotnet build -c Release
    echo.
    pause
    exit /b 1
)

echo     dotnet найден. Сборка и запуск (может занять минуту)...
echo.
echo [5/5] Запуск приложения...
cd /d "%SCRIPT_DIR%winforms-prototype"
dotnet run -c Release
goto :end

:launch_exe
echo     OK
echo.
echo [5/5] Запуск приложения...
start "" "%APP_EXE%"
echo     Приложение запущено!
echo.

:end
echo ══════════════════════════════════════════════════════════
echo  Готово! Если окно приложения не появилось — проверьте
echo  что MySQL запущен и повторите запуск этого файла.
echo ══════════════════════════════════════════════════════════
echo.
pause
