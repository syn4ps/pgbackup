@echo off

set pgbin=c:\Program Files\PostgreSQL\12.4-1.1C\bin\
set logfile=pgbackup.log
set pguser=postgres
set PGPASSWORD=*put your password here*
set dumppath=f:\backup\data\
set dumpname=%2-%date:~0,2%%date:~3,2%%date:~6,4%

IF [%1] == [] GOTO USAGE
if "%1" == "backup" GOTO BACKUP
if "%1" == "clean" GOTO CLEAN
if "%1" == "restore" GOTO RESTORE

:BACKUP
IF [%2] == [] GOTO USAGE
IF [%3] == [] GOTO CUSTOMBACKUP
IF "%3" == "sql" GOTO SQLBACKUP
GOTO USAGE
goto END

:CUSTOMBACKUP
echo %date% %time% starting custom format backup database %2 >>%logfile% 
"%pgbin%\pg_dump.exe" --format=c --dbname=%2 --username=%pguser% --compress=9 --file=%dumppath%%dumpname%.pgdump 2>>%logfile%
IF NOT %ERRORLEVEL%==0 GOTO ERROR
IF %ERRORLEVEL%==0 GOTO SUCCESS
goto END

:SQLBACKUP
echo %date% %time% starting plain sql format backup database %2 >>%logfile% 
"%pgbin%\pg_dump.exe" --dbname=%2 --username=%pguser% --compress=9 --file=%dumppath%%dumpname%.sql.gzip 2>>%logfile%
IF NOT %ERRORLEVEL%==0 GOTO ERROR
IF %ERRORLEVEL%==0 GOTO SUCCESS
goto END


:SUCCESS
echo %date% %time% %1 database %2 succefully completed >>%logfile% 
echo %1 database %2 succefully completed
goto END

:USAGE
echo %date% %time% *** error required parameter not given  >>%logfile% 
echo Usage: pgbackup command [database] [option]
echo:
echo Allowed commands: 
echo:
echo    backup database [sql]                                  
echo     - for backup database in custom format, 
echo       use sql option for plain sql backup
echo:
echo    restore database dumpfilename [tablespace] [overwrite]
echo     - for restore database from backup
echo       use overwrite option for silently 
echo       overwrite existing database, 
echo       optionally you can choose tablespace
echo:
echo    clean                                                  
echo      - for clean old backup files
goto END

:RESTORE
IF [%2] == [] GOTO USAGE
IF [%3] == [] GOTO USAGE
if not exist %3 (
   echo Error can't open dump file %3 for restore 
   echo Error can't open dump file %3 for restore >>%logfile%
   GOTO END
)

IF "%4" == "overwrite" GOTO OVERWRITERESTORE
IF [%5] == [] GOTO USUALRESTORE
IF "%5" == "overwrite" GOTO OVERWRITERESTORE
GOTO USAGE
goto END

:USUALRESTORE
echo %date% %time% restore database %2 >>%logfile% 
:USUALRESTOREASK
echo Warning if database %2 already exist it will be overwritten yes/no [no]:
set /p answer=""
if "%answer%" == "yes" GOTO OVERWRITERESTORE
echo %date% %time% restore database %2 from file %3 cancelled >>%logfile% 
goto END

:OVERWRITERESTORE
echo %date% %time% restore with overwrite database %2 from file %3 >>%logfile% 
echo %date% %time% try to kill connections to database %2 >>%logfile% 
"%pgbin%\psql.exe" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '%2';" >>%logfile% 
echo %date% %time% try to drop database %2 >>%logfile% 
"%pgbin%\dropdb.exe" --if-exists --username=%pguser% %2 2>>%logfile%
IF NOT %ERRORLEVEL%==0 GOTO ERROR
echo %date% %time% database %2 dropped succefully >>%logfile% 
echo %date% %time% try to create database %2 >>%logfile% 

IF [%4] == [] (
"%pgbin%\createdb.exe" --username=%pguser% %2 2>>%logfile%
) else (
"%pgbin%\createdb.exe" --username=%pguser% --tablespace=%4 %2 2>>%logfile%
)

IF NOT %ERRORLEVEL%==0 GOTO ERROR
echo %date% %time% database %2 created succefully >>%logfile% 
echo %date% %time% starting restore database %2 >>%logfile% 
"%pgbin%\pg_restore.exe" --dbname=%2 --username=%pguser% <%3 2>>%logfile%
IF NOT %ERRORLEVEL%==0 GOTO ERROR
IF %ERRORLEVEL%==0 GOTO SUCCESS
goto END

:CLEAN
echo %date% %time% clean old backup files in %dumppath% >>%logfile% 
forfiles /p %dumppath% /D -1 /C "cmd /c del /f /a /q @file"
goto END

:ERROR
echo %date% %time% *** error %1 database %2 >>%logfile% 
echo Error can't %1 database %2
goto END


:END
REM What's All Folks! :)
