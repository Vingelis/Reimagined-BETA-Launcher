@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Update Launcher Script
:: This script applies the launcher update and updates the launcher_version in settings.txt.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO.
ECHO Summoning Update Wizard...
ECHO.
TIMEOUT /T 2 >nul

:: Define paths
:: Launcher update utility files
SET "utils_launcher_dir=%~dp0"
SET "temp_folder=%utils_launcher_dir%\Launcher_Update"
SET "temp_zip=%utils_launcher_dir%\Launcher_Update.zip"
SET "version_file=%utils_launcher_dir%\launcher_version.txt"
SET "beta_launcher_file=%launcher_dir%\BETA Launcher.bat"

:: Launcher files
SET "launcher_dir=%~dp0..\.."
SET "settings_file=%launcher_dir%\settings.txt"

:: Ensure the main launcher script is no longer running
:WAIT_FOR_LAUNCHER_EXIT
TASKLIST | FIND /I "BETA Launcher.bat" >nul
IF NOT ERRORLEVEL 1 (
    TIMEOUT /T 2 >nul
    GOTO WAIT_FOR_LAUNCHER_EXIT
)

:: Check if the update files exist
IF NOT EXIST "%temp_zip%" (
    ECHO Error: Update package not found. Aborting update.
    PAUSE
    EXIT /B 1
)

IF NOT EXIST "%temp_folder%" (
    ECHO Error: Extracted update folder not found. Aborting update.
    PAUSE
    EXIT /B 1
)

:: Apply the update by copying files
ECHO Reciting the update incantation... 
ECHO.
:: Delete the old BETA Launcher.bat file if it exists
IF EXIST "%beta_launcher_file%" (
    DEL /Q "%beta_launcher_file%"
    IF ERRORLEVEL 1 (
        ECHO Error: Failed to delete old BETA Launcher.bat. Please check file permissions and try again.
        PAUSE
        EXIT /B 1
    )
)
TIMEOUT /T 2 >nul
XCOPY "%temp_folder%\Reimagined-BETA-Launcher-main\*" "%launcher_dir%\" /E /H /C /Y >nul 2>&1
IF ERRORLEVEL 1 (
    ECHO Error: Failed to update launcher files. Please check file permissions and try again.
    PAUSE
    EXIT /B 1
)
TIMEOUT /T 2 >nul

:: Update launcher_version in settings.txt
IF EXIST "%version_file%" (
    FOR /F "tokens=*" %%A IN ('TYPE "%version_file%"') DO SET "new_version=%%A"
    IF NOT DEFINED new_version (
        ECHO Error: Failed to read launcher version from "%version_file%".
        PAUSE
        EXIT /B 1
    )
    ECHO Transmuting Horadric Cube...
    ECHO.
    Powershell -NoProfile -Command "(Get-Content '%settings_file%') -replace '^\s*launcher_version\s*=.*', 'launcher_version=%new_version%' | Set-Content '%settings_file%'"
    IF ERRORLEVEL 1 (
        ECHO Error: Failed to update launcher_version in settings.txt.
        PAUSE
        EXIT /B 1
    )
    ECHO Transmutation successful...
    ECHO.
) ELSE (
    ECHO Error: Version file "%version_file%" not found. Skipping version update.
    ECHO.
)
TIMEOUT /T 2 >nul

:: Clean up temporary files
ECHO Now to clean up the Cube...
ECHO.

:: Delete temporary files and folders
IF EXIST "%temp_zip%" DEL /Q "%temp_zip%"
IF EXIST "%temp_folder%" RMDIR /S /Q "%temp_folder%"
IF EXIST "%version_file%" DEL /Q "%version_file%"
TIMEOUT /T 2 >nul

:: Verify cleanup success
FOR %%F IN ("%temp_zip%" "%temp_folder%" "%version_file%") DO (
    IF EXIST %%F (
        ECHO Error: Failed to delete %%F. Please check file permissions and try again.
        PAUSE
        EXIT /B 1
    )
)

ECHO Cube has been emptied of its contents...
ECHO.
TIMEOUT /T 2 >nul

:: Confirm update success
ECHO Looks like everything went well...
ECHO.
ECHO Restarting the launcher...
ECHO.
TIMEOUT /T 2 >nul

:: Restart the launcher
PUSHD "%launcher_dir%"
START "" "BETA Launcher.bat"
POPD

EXIT