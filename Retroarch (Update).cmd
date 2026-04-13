@echo off
setlocal enabledelayedexpansion
cd /d %~dp0

:MENU
cls
echo RetroArch Manager
echo 1 - Update RetroArch Nightly
echo 2 - Update RetroArch Cores
echo 3 - Delete Retro Fighters Brawler64 Config
echo 4 - Exit
echo.
set /p choice=Choose an option (0-4): 
if "%choice%"=="1" goto UPDATE_NIGHTLY
if "%choice%"=="2" goto UPDATE_CORES
if "%choice%"=="3" goto DELETE_CONFIG
if "%choice%"=="4" exit /b
echo Invalid choice!&pause&goto MENU

:UPDATE_CORES
cls
cd /d %~dp0
set "SCRIPT_DIR=%~dp0"
set "CORES_FOLDER=%SCRIPT_DIR%RetroArch-Win64\cores"
set "CORES_URL=https://buildbot.libretro.com/nightly/windows/x86_64/latest/"
rem Dynamic path to 7za.exe
set "SEVENZIP=%SCRIPT_DIR%RetroArch-Win64\7z\7za.exe"
if not exist "%SEVENZIP%" echo 7za.exe not found!&pause&goto MENU
if not exist "%CORES_FOLDER%" echo Cores folder does not exist!&pause&goto MENU
cd /d "%CORES_FOLDER%"
echo Downloading core list...
curl -# -L "%CORES_URL%" -o "corelist.html" 2>nul
if errorlevel 1 echo Download failed!&pause&goto MENU
for %%F in ("*.dll") do (
 set "FILE_NAME=%%~nxF"
 set "CORE_NAME=%%~nF"
 set "SEARCH_NAME=!CORE_NAME!
 if "!CORE_NAME:~-8!"=="_libretro" set "SEARCH_NAME=!CORE_NAME:~0,-8!"
 findstr /i "!SEARCH_NAME!" "corelist.html" >nul 2>&1
 if !errorlevel! equ 0 (
  echo Updating !FILE_NAME!...
  curl -# -L "!CORES_URL!!FILE_NAME!.zip" -o "!FILE_NAME!.zip" 2>nul
  if not errorlevel 1 (
   "%SEVENZIP%" x -y -o".\" "!FILE_NAME!.zip" -bso0 -bse0 -mmt >nul 2>&1
   del "!FILE_NAME!.zip" 2>nul
   echo Updated !FILE_NAME!.
  )
 )
)
del "corelist.html" 2>nul
timeout /t 3 >nul
goto MENU

:UPDATE_NIGHTLY
cls
cd /d %~dp0
set "ZIP_URL=https://buildbot.libretro.com/nightly/windows/x86_64/RetroArch.7z"
set "RA_FILE=retroarch_nightly.7z"
set "MAIN_FOLDER=%~dp0"
if "%MAIN_FOLDER:~-1%"=="\" set "MAIN_FOLDER=%MAIN_FOLDER:~0,-1%"
rem Dynamic path to 7za.exe
set "SEVENZIP=%SCRIPT_DIR%RetroArch-Win64\7z\7za.exe"
if not exist "%SEVENZIP%" echo 7za.exe not found!&pause&goto MENU
for /f "delims=" %%D in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyy-MM-dd')"') do set "TODAY=%%D"
set "DOWNLOAD_NEEDED=1"
if exist "%RA_FILE%" (
 for /f "delims=" %%L in ('powershell -NoProfile -Command "(Get-Item '%RA_FILE%').LastWriteTime.ToString('yyyy-MM-dd')"') do set "FILE_DATE=%%L"
 if "!FILE_DATE!"=="!TODAY!" set "DOWNLOAD_NEEDED=0"
)
if "!DOWNLOAD_NEEDED!"=="1" (
 echo Downloading latest RetroArch nightly...
 curl -# -L "%ZIP_URL%" -o "%RA_FILE%" >nul 2>&1
 if errorlevel 1 echo Download failed!&pause&goto MENU
)
echo Extracting RetroArch silently...
"%SEVENZIP%" x -y -o"%MAIN_FOLDER%" "%RA_FILE%" -bso0 -bse0 -mmt >nul 2>&1
if errorlevel 1 (
    echo Extraction failed! Check that %RA_FILE% exists and %SEVENZIP% is correct.
) else (
    echo Extraction complete.
)
timeout /t 3 >nul
goto MENU

:DELETE_CONFIG
cls
cd /d %~dp0
set "SCRIPT_DIR=%~dp0"
set "CONFIG_FOLDER=%SCRIPT_DIR%RetroArch-Win64\autoconfig\xinput"
set "TARGET_FILE=Retro Fighters Brawler64 (USB).cfg"
if not exist "%CONFIG_FOLDER%" echo Folder not found!&pause&goto MENU
if exist "%CONFIG_FOLDER%\%TARGET_FILE%" (
 del "%CONFIG_FOLDER%\%TARGET_FILE%"
 echo File deleted.
) else echo File not found.
timeout /t 3 >nul
goto MENU