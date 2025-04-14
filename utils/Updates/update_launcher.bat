@ECHO OFF
ECHO.
ECHO Summoning Update Wizard...
ECHO.
ECHO TIMEOUT /T 2 >nul

SET "utils_launcher_dir=%~dp0"
SET "temp_folder=%utils_launcher_dir%\Launcher_Update"
SET "temp_zip=%utils_launcher_dir%\Launcher_Update.zip"
SET "temp_update_script=%utils_launcher_dir%\temp_update_launcher.bat"

:: Launcher files
SET "launcher_dir=%~dp0..\.."
SET "settings_file=%launcher_dir%\settings.txt"
SET "beta_launcher_file=%launcher_dir%\BETA Launcher.bat"

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
:: Backup the new BETA Launcher.bat file to a temporary file
SET "temp_beta_launcher_file=%utils_launcher_dir%\temp_BETA_Launcher.bat"
IF EXIST "%beta_launcher_file%" (
    TYPE "%beta_launcher_file%" > "%temp_beta_launcher_file%"
    IF ERRORLEVEL 1 (
        ECHO Error: Failed to create a backup of BETA Launcher.bat. Please check file permissions and try again.
        PAUSE
        EXIT /B 1
    )
    TIMEOUT /T 2 >nul
    :: Delete the new BETA Launcher.bat file
    DEL /Q "%beta_launcher_file%"
    IF ERRORLEVEL 1 (
        ECHO Error: Failed to delete old BETA Launcher.bat. Please check file permissions and try again.
        PAUSE
        EXIT /B 1
    )
    TIMEOUT /T 2 >nul
    :: Re-create the BETA Launcher.bat file from the temp file
    COPY "%temp_beta_launcher_file%" "%beta_launcher_file%" /Y >nul
    IF ERRORLEVEL 1 (
        ECHO Error: Failed to restore BETA Launcher.bat from backup. Please check file permissions and try again.
        PAUSE
        EXIT /B 1
    )
    TIMEOUT /T 2 >nul
    :: Delete the temp file
    DEL /Q "%temp_beta_launcher_file%"
    IF ERRORLEVEL 1 (
        ECHO Warning: Failed to delete temporary backup file. Please check file permissions and clean up manually.
    )
	TIMEOUT /T 2 >nul
)

:: Remove the launcher_version in settings.txt so that it can be updated by the new BETA Launcher.bat
IF EXIST "%settings_file%" (
    POWERSHELL -Command "$settingsFile = '%settings_file%'; (Get-Content -Path $settingsFile) -replace '^launcher_version=.*$', 'launcher_version=' | Set-Content -Path $settingsFile;"
    IF ERRORLEVEL 1 (
        ECHO Error: Failed to update launcher_version in settings.txt. Please check file permissions and try again.
        PAUSE
        EXIT /B 1
    )
) ELSE (
    ECHO Warning: settings.txt not found. Skipping launcher_version update.
)

:: Clean up temporary files
ECHO Now to clean up the Cube...
ECHO.

:: Delete temporary files and folders
IF EXIST "%temp_zip%" DEL /Q "%temp_zip%"
IF EXIST "%temp_folder%" RMDIR /S /Q "%temp_folder%"
TIMEOUT /T 2 >nul

:: Verify cleanup success
FOR %%F IN ("%temp_zip%" "%temp_folder%") DO (
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