@echo off

set pgdump="c:\Program Files\PostgreSQL\12.4-1.1C\bin\pg_dump.exe"
set logfile=pgbackup.log
set pguser=postgres
set PGPASSWORD=postgres
set dumppath=h:\backup\data\
set dumpname=%2-%date:~0,2%%date:~3,2%%date:~6,4%

IF [%1] == [] GOTO USAGE
if "%1" == "backup" GOTO BACKUP
if "%1" == "clean" GOTO CLEAN

:BACKUP
IF [%2] == [] GOTO USAGE
echo %date% %time% starting backup database %2 >>%logfile% 
%pgdump% --dbname=%2 --username=%pguser% --compress=9 --file=%dumppath%%dumpname%.sql.zip 2>>%logfile%
IF NOT %ERRORLEVEL%==0 GOTO ERROR
IF %ERRORLEVEL%==0 GOTO SUCCESS
goto END

:SUCCESS
echo %date% %time% backup database %2 succefully completed >>%logfile% 
echo Backup database %2 succefully completed
goto END

:USAGE
echo %date% %time% *** error required parameter not given  >>%logfile% 
echo Usage: pgbackup command [database]
echo Allowed commands: 
echo    backup database - for backup database
echo    clean - for clean old backup files
goto END

:CLEAN
echo %date% %time% clean old backup files in %dumppath% >>%logfile% 
forfiles /p %dumppath% /D -1 /C "cmd /c del /f /a /q @file"
goto END

:ERROR
echo %date% %time% *** error backup database %2 >>%logfile% 
echo Error cant backup database %2
goto END


:END
