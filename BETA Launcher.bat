@ECHO OFF
:: Reimagined BETA Launcher

:: Constants
:: Set to 1 for debugging, 0 to disable debug output
SET "debug=0"

:: find the location of the launcher script
SET "launcher=%~dp0"
IF "%launcher:~-1%"=="\" SET "launcher=%launcher:~0,-1%"

:: Query the registry for the install location
FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Diablo II Resurrected" /v InstallLocation 2^>nul`) DO (
    @SET "appdir=%%A %%B"
)

:: Verify D2R installation
IF NOT DEFINED appdir (
    CALL :ERROR_HANDLER "Diablo II Resurrected is not installed or the registry key is missing. Please ensure a licenced version of the game is installed before trying again." EXIT
)
IF NOT EXIST "%appdir%\D2R.exe" (
    CALL :ERROR_HANDLER "D2R.exe not found in '%appdir%'. Please ensure Diablo II Resurrected is installed correctly." EXIT
)

:: Debugging
IF "%debug%"=="1" (
    ECHO Debug: D2R Install Location="%appdir%"
    ECHO Debug: Launcher Location="%launcher%"
    PAUSE
)

:: Main Menu
:MAIN_MENU
CLS
ECHO ------------- REIMAGINED BETA LAUNCHER -------------
ECHO.
ECHO Welcome to the Reimagined BETA Launcher.
ECHO.
ECHO     [1] Play Reimagined
ECHO     [2] Install / Update
ECHO     [3] Advanced Options
ECHO     [4] Backup Save Files
ECHO     [5] Visit Reimagined Website
ECHO     [6] Visit Reimagined Wiki
ECHO     [7] Visit Reimagined Nexus Page
ECHO     [8] Visit Reimagined Discord Server
ECHO     [9] Exit
ECHO.
SET /P "menu_choice=What would you like to do: "
IF "%menu_choice%"=="1" GOTO PLAY_REIMAGINED
IF "%menu_choice%"=="2" GOTO INSTALL_UPDATE
IF "%menu_choice%"=="3" GOTO ADVANCED_OPTIONS
IF "%menu_choice%"=="4" GOTO BACKUP_SAVE_FILES
IF "%menu_choice%"=="5" CALL :OPEN_LINK "https://www.d2r-reimagined.com"
IF "%menu_choice%"=="6" CALL :OPEN_LINK "https://wiki.d2r-reimagined.com"
IF "%menu_choice%"=="7" CALL :OPEN_LINK "https://www.nexusmods.com/diablo2resurrected/mods/503"
IF "%menu_choice%"=="8" CALL :OPEN_LINK "https://discord.gg/5bbjneJCrr"
IF "%menu_choice%"=="9" EXIT /B
GOTO MAIN_MENU

:: Play Reimagined
:PLAY_REIMAGINED
CALL :CHECK_7Z_FILES
CALL :VERIFY_REIMAGINED_FOLDER
IF "%mod_checked%"=="0" (
    START "" "%appdir%\D2R.exe" -mod Reimagined -txt
    EXIT
) ELSE (
    CALL :ERROR_HANDLER "Reimagined mod folder is not found or is empty. Please ensure the mod is installed correctly." INSTALL_UPDATE
)
EXIT /B

:: Install / Update
:INSTALL_UPDATE
CALL :CHECK_7Z_FILES
CLS
ECHO.
ECHO ------------- INSTALL / UPDATE -------------
ECHO.
ECHO 7z File: %truncated_install_file_name%
ECHO.
SET /P "install_choice=Would you like to install this version now? (Y/N): "
IF /I "%install_choice%"=="Y" (
    :: Ensure the install_file variable is correctly expanded
    IF NOT DEFINED install_file (
        CALL :ERROR_HANDLER "Error: No installation file found. Please ensure the file exists." CHECK_7Z_FILES
    )
    :: Extract the 7z file using 7zr.exe and suppress output
    IF NOT EXIST "%launcher%\utils\7zr\7zr.exe" (
        CALL :ERROR_HANDLER "Error: 7zr.exe not found. Please ensure it is installed in the correct location." INSTALL_UPDATE
    )
    "%launcher%\utils\7zr\7zr.exe" x "%install_file%" -o"%appdir%" -y >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Error: Failed to extract the 7z file. Please ensure the file exists and is not corrupted." INSTALL_UPDATE
    )

    ECHO.
    ECHO Installing %truncated_install_file_name%...
    ECHO.
    ECHO Copying advanced files...

    CALL :COPY_FILES "%launcher%\utils\advanced" "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\"
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Error: Failed to copy advanced files. Please ensure the destination path exists and is writable." MAIN_MENU
    )

    ECHO.
    ECHO Installation completed successfully!
    ECHO.
    PAUSE
    GOTO MAIN_MENU
) ELSE IF /I "%install_choice%"=="N" (
    CALL :ERROR_HANDLER "Installation skipped. Returning to main menu..." MAIN_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." INSTALL_UPDATE
)
EXIT /B

:: Advanced Options
:ADVANCED_OPTIONS

CALL :VERIFY_REIMAGINED_FOLDER
:: Check for the existence of the advanced folder
IF NOT EXIST "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\" (
    CALL :COPY_FILES "%launcher%\utils\advanced" "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\"
)

CLS
ECHO.
ECHO ------------- ADVANCED OPTIONS -------------
ECHO.
ECHO    [1] Expanded Stash
ECHO    [2] Forced Terror Zones
ECHO    [3] Splash Charm Graphic Effect Removal
ECHO    [4] Two Skill Points Per Level
ECHO    [5] CASC Fastloading
ECHO    [6] Back to Main Menu
ECHO.
SET /P "advoption_choice=What would you like to do: "
IF "%advoption_choice%"=="1" GOTO EXPANDED_STASH
IF "%advoption_choice%"=="2" GOTO FORCED_TERROR_ZONES
IF "%advoption_choice%"=="3" GOTO SPLASH_CHARM_REMOVAL
IF "%advoption_choice%"=="4" GOTO TWO_SKILL_POINTS
IF "%advoption_choice%"=="5" GOTO CASC_FASTLOADING
IF "%advoption_choice%"=="6" GOTO MAIN_MENU
GOTO ADVANCED_OPTIONS

:: Expanded Stash
:EXPANDED_STASH
CLS
ECHO ------------- Expanded Shared Stash Tabs -------------
ECHO.
ECHO This mod expands your shared stash tabs from 4 to 8
ECHO.
ECHO    [1] Re-install Expanded Stash
ECHO    [2] New install of Expanded Stash
ECHO        You will be asked to confirm this action.
ECHO    [3] Exit to Advanced Options
ECHO.
SET "stash_choice="
SET "stash_choice_affirm="
SET /P "stash_choice=What would you like to do? "
IF "%stash_choice%"=="1" (
    ECHO.
    TIMEOUT /T 1 >nul
    CALL :COPY_FILES "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\Expanded Stash Mod Directory\mods\" "%appdir%\mods\"
    ECHO Expanded Stash re-installed successfully
    ECHO.
) ELSE IF "%stash_choice%"=="2" (
    CLS
    color 0C
    ECHO.
    ECHO WARNING: This change overwrites your existing Shared Stash Tabs.
    ECHO.
    ECHO You must move all items and gold from Shared Stash Tabs to your character's inventory,
    ECHO to your personal stash, or to a mule character before proceeding.
    ECHO.
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET "stash_choice_affirm="
    SET /P "stash_choice_affirm=Do you wish to proceed? (Y/N): "
    IF /I "!stash_choice_affirm!"=="Y" (
        color 07
        ECHO.
        ECHO Expanding your stash...
        ECHO.
        ECHO Items going poof in shared stash tabs...
        ECHO.
        TIMEOUT /T 2 >nul
        CALL :COPY_FILES "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\Expanded Stash Mod Directory\mods\" "%appdir%\mods\"
        IF ERRORLEVEL 1 (
            CALL :ERROR_HANDLER "Failed to copy Expanded Stash Mod Directory files." ADVANCED_OPTIONS
        )
        CALL :COPY_FILES "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\Expanded Stash Saved Game\Diablo II Resurrected\" "%USERPROFILE%\Saved Games\Diablo II Resurrected\"
        IF ERRORLEVEL 1 (
            CALL :ERROR_HANDLER "Failed to copy Expanded Stash Saved Game files." ADVANCED_OPTIONS
        )   
        ECHO Upgrade complete
        ECHO.
        ENDLOCAL
    ) ELSE IF /I "!stash_choice_affirm!"=="N" (
        color 07
        ENDLOCAL
        CALL :ERROR_HANDLER "Stash remains smol..." ADVANCED_OPTIONS
    ) ELSE (
        color 07
        ENDLOCAL
        CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." EXPANDED_STASH
    )
) ELSE IF "%stash_choice%"=="3" (
    GOTO ADVANCED_OPTIONS
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter a valid number." EXPANDED_STASH
)
PAUSE
GOTO ADVANCED_OPTIONS


:: Forced Terror Zones
:FORCED_TERROR_ZONES
CLS
ECHO.
ECHO ------------- Forced Terror Zones -------------
ECHO.
ECHO Permanently terrorizes a pre-selected list of popular areas.
ECHO Zones will no longer cycle every hour.
ECHO.
ECHO Areas terrorized:
ECHO    Abandoned Tower (Countess)
ECHO    Catacombs (Andariel)
ECHO    Arcane Sanctuary (Summoner)
ECHO    Durance of Hate (Mephisto)
ECHO    Chaos Sanctuary (Diablo)
ECHO    Nihlathak's Temple (Nihlathak)
ECHO    Throne of Destruction
ECHO    Worldstone Chamber (Baal)
ECHO    Moo Moo Farm (Cows)
ECHO.
SET /P "terror_choice=Do you wish to proceed? (Y/N): "
IF /I "%terror_choice%"=="Y" (
    ECHO.
    ECHO Terrorizing Sanctuary...
    TIMEOUT /T 2 >nul
    CALL :COPY_FILES "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\Forced Terror Zones\desecratedzones.json" "%appdir%\mods\Reimagined\Reimagined.mpq\data\hd\global\excel\desecratedzones.json"
    ECHO.
    ECHO Evil has spread across Sanctuary...
    ECHO.
    PAUSE
    GOTO ADVANCED_OPTIONS
) ELSE IF /I "%terror_choice%"=="N" (
    CALL :ERROR_HANDLER "Sanctuary remains safe for now..." ADVANCED_OPTIONS
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." FORCED_TERROR_ZONES
)
PAUSE
GOTO ADVANCED_OPTIONS

:: Splash Charm Grahphic Effect Removal
:SPLASH_CHARM_REMOVAL
CLS
ECHO.
ECHO ------------- Splash Charm Graphic Effect Removal -------------
ECHO.
ECHO Removes the particle effect when using the Splash Charm (Collin's Charm).
ECHO.
SET /P "splash_choice=Do you wish to proceed? (Y/N): "
IF /I "%splash_choice%"=="Y" (
    ECHO.
    ECHO Cleaning up Collin's mess...
    ECHO.
    TIMEOUT /T 2 >nul
    CALL :COPY_FILES "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\Splash Charm Effect Graphic Removal\missiles.json" "%appdir%\mods\Reimagined\Reimagined.mpq\data\hd\missiles\missiles.json"
    ECHO There, all clean now.
    ECHO.
    PAUSE
    GOTO ADVANCED_OPTIONS
) ELSE IF /I "%splash_choice%"=="N" (
    CALL :ERROR_HANDLER "Tsk Tsk Collin, you really should clean up after yourself" ADVANCED_OPTIONS
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." SPLASH_CHARM_REMOVAL
)
PAUSE
GOTO ADVANCED_OPTIONS

:: Two Skill Points Per Level
:TWO_SKILL_POINTS
CLS
ECHO.
ECHO ------------- Two Skill Points Per Level -------------
ECHO.
ECHO Characters gain 2 skill points per level instead of 1.
ECHO.
ECHO Disclaimers:
ECHO    This change does not work retroactively.
ECHO    Skill points already earned cannot be modified.
ECHO    If you uninstall this change characters will return to earning 1 skill point per level.
ECHO    Using a Token of Absolution to reset your character will refund all skill points
ECHO    earned up to that point (whether 1 or 2 points).
ECHO.
SET /P "skill_choice=Do you wish to proceed? (Y/N): "
IF /I "%skill_choice%"=="Y" (
    ECHO.
    ECHO Applying cheat codes...
    TIMEOUT /T 2 >nul
    CALL :COPY_FILES "%appdir%\mods\Reimagined\Reimagined.mpq\advanced\Two Skills Per Level\charstats.txt" "%appdir%\mods\Reimagined\Reimagined.mpq\data\global\excel\charstats.txt"
    ECHO.
    ECHO You're now a 'super' Sorceress.
    ECHO.
    PAUSE
    GOTO ADVANCED_OPTIONS
) ELSE IF /I "%skill_choice%"=="N" (
    CALL :ERROR_HANDLER "So close to being a 'super' Sorceress, but you chose wisely." ADVANCED_OPTIONS
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." TWO_SKILL_POINTS
)
PAUSE
GOTO ADVANCED_OPTIONS

:: CASC Fastloading
:CASC_FASTLOADING
CLS
ECHO.
ECHO ------------- CASC Fastloading -------------
ECHO.
ECHO Unpacks all game files for faster load times, reduced latency, 
ECHO snappier controls, and increased in-game FPS.
ECHO.
ECHO NOTE: This change requires 41GB of additional disk space to complete.
ECHO.

:: Check for enough free disk space using PowerShell
FOR /F "tokens=*" %%A IN ('powershell -Command "(Get-PSDrive -Name %appdir:~0,1%).Free"') DO SET "free_space=%%A"

:: Remove commas and spaces from the free space value
SET "free_space=%free_space:,=%"
SET "free_space=%free_space: =%"

:: Use PowerShell to calculate free space in GB and compare with required space
FOR /F "tokens=*" %%B IN ('powershell -Command "[math]::Floor(%free_space% / 1GB)"') DO SET "free_space_gb=%%B"
SET "required_space_gb=41"

:: Debugging output
IF "%debug%"=="1" (
    ECHO Debug: Free space in GB=%free_space_gb%
    ECHO Debug: Required space in bytes=%required_space_gb%
    PAUSE
)

:: Error handling for undefined variables
IF NOT DEFINED free_space (
    CALL :ERROR_HANDLER "Failed to retrieve free disk space. Please check your system." ADVANCED_OPTIONS
)
:: Ensure free_space is numeric
FOR /F "delims=0123456789" %%B IN ("%free_space_gb%") DO (
    CALL :ERROR_HANDLER "Invalid free space value retrieved: '%free_space_gb%'. Please check your system." ADVANCED_OPTIONS
)
IF NOT DEFINED required_space_gb (
    CALL :ERROR_HANDLER "Failed to calculate required disk space. Please check your system." ADVANCED_OPTIONS
)

:: Compare free space with required space
IF %free_space_gb% LSS %required_space_gb% (
    CALL :ERROR_HANDLER "Not enough available space on disk to perform this action. Please ensure you have at least 41GB free before trying again." ADVANCED_OPTIONS
)

ECHO Free space on %appdir:~0,1%: Drive (D2R Install Location): %free_space_gb% GB
ECHO.

SET /P "casc_choice=Would you like to proceed? (Y/N): "
IF /I "%casc_choice%"=="Y" (
    ECHO.
    ECHO This process will take 5-10 minutes to complete.
    ECHO Please do not close this window until the process is finished.
    ECHO.
    MD "%appdir%\casctemp" >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Failed to create temporary directory '%appdir%\casctemp'. Please check permissions or the path." ADVANCED_OPTIONS
    )
    IF NOT EXIST "%launcher%\utils\Casc\CASCConsole.exe" (
        CALL :ERROR_HANDLER "Error: CASCConsole.exe not found at '%launcher%\utils\Casc\CASCConsole.exe'. Please ensure it is installed in the correct location." ADVANCED_OPTIONS
    )
    ECHO Extracting game files...
    "%launcher%\utils\Casc\CASCConsole.exe" -l None -d "%appdir%\casctemp" -s "%appdir%" -m Pattern -e data/data/*.* -p osi >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Failed to extract game files using CASCConsole.exe. Please check the logs for details." ADVANCED_OPTIONS
    )
    IF EXIST "%appdir%\casctemp\data\data" (
        rmdir /s /q "%appdir%\mods\Reimagined\Reimagined.mpq\data" >nul 2>&1
        ECHO.
        ECHO Moving extracted game files to Reimagined mod folder...
        move /Y "%appdir%\casctemp\data\data" "%appdir%\mods\Reimagined\Reimagined.mpq\data" >nul 2>&1
        rmdir /s /q "%appdir%\casctemp" >nul 2>&1
        rm %launcher%\
        ECHO.
        ECHO Cleaning up the mess...
        TIMEOUT /T 2 >nul
        ECHO.
        ECHO Power overwhelming...
        ECHO.
        PAUSE
        GOTO ADVANCED_OPTIONS
    ) ELSE (
        CALL :ERROR_HANDLER "Failed to find extracted game files in '%appdir%\casctemp'. Please check the extraction process." ADVANCED_OPTIONS
    )
) ELSE IF /I "%casc_choice%"=="N" (
    CALL :ERROR_HANDLER "Not enough space with all that 'science' material, eh?" ADVANCED_OPTIONS
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." CASC_FASTLOADING
)
PAUSE
GOTO ADVANCED_OPTIONS

:: Backup Save Files
:BACKUP_SAVE_FILES
ECHO.
ECHO Finding your Reimagined Saved Games directory...
CALL :LOCATE_SAVED_GAMES_DIR
IF NOT EXIST "%savedir%" (
    CALL :ERROR_HANDLER "No Save files found in "%savedir%"." MAIN_MENU
)

:: Initialise backup variables
:: Ensure tar is available
WHERE tar >nul 2>&1
IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Error: tar is not available on this system. Please install it or use a different backup method." MAIN_MENU
)
:: Ensure the backup directory exists
IF NOT EXIST "%savedir%\Reimagined Backups\" MD "%savedir%\Reimagined Backups\" >nul 2>&1
IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Error: Failed to create backup directory. Please check permissions or the path." BACKUP_SAVE_FILES
)
:: Set the backup file name with the current date
SET "current_date="
:: Get the current date in YYYYMMDD format
FOR /F "tokens=*" %%A IN ('powershell -Command "Get-Date -Format yyyyMMdd"') DO SET "current_date=%%A"

IF EXIST "%savedir%\Reimagined Backups\" SET "backup_file_name=%savedir%\Reimagined Backups\%current_date%.zip"
:: End initialise backup variables

CLS
ECHO ------------- BACKUP SAVE FILES -------------
ECHO.
ECHO    [1] Backup Save Files
ECHO        Create a new backup, or overwrite an existing one.
ECHO    [2] Open Backup Folder
ECHO        Open the folder where backups are stored to manage them.
ECHO    [3] Back to Main Menu
ECHO.
ECHO    Save File Location: "%savedir%\Reimagined"
ECHO    Save File location is chosen based on the most recently updated "Reimagined" folder containing .d2s files.
ECHO.

SET /P "backup_choice=What would you like to do? "
IF "%backup_choice%"=="1" (
    ECHO.
    ECHO Backing up save files...
    TIMEOUT /T 2 >nul
    ECHO.
    tar -a -c -f "%backup_file_name%" -C "%savedir%" "Reimagined" >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Error: Failed to create the backup. Please check if the save files exist and try again." BACKUP_SAVE_FILES
    )
    IF NOT EXIST "%backup_file_name%" (
        CALL :ERROR_HANDLER "Backup file was not created. Please check for issues and try again." BACKUP_SAVE_FILES
    )
    ECHO Backup completed successfully!
    ECHO.
    PAUSE
    GOTO BACKUP_SAVE_FILES
) ELSE IF "%backup_choice%"=="2" (
    START "" "%savedir%\Reimagined Backups"
    GOTO BACKUP_SAVE_FILES
) ELSE IF "%backup_choice%"=="3" (
    GOTO MAIN_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter 1, 2 or 3." BACKUP_SAVE_FILES
)
PAUSE
GOTO ADVANCED_OPTIONS

:: Subroutines
:: Check for 7z files in the launcher folder
:CHECK_7Z_FILES
SET "file_count=0"
SET "install_file="

:: Debugging: Check the launcher path
IF "%debug%"=="1" (
    ECHO Debug: launcher="%launcher%"
    DIR "%launcher%" /B
)

SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%F IN ("%launcher%\*D2R Reimagined - *.7z") DO (
    SET /A file_count+=1
    IF "!file_count!"=="1" SET "install_file=%%~F"
)
ENDLOCAL & SET "install_file=%install_file%" & SET "file_count=%file_count%"

:: Handle cases where no or multiple files are found
IF %file_count% EQU 0 (
    CALL :ERROR_HANDLER "No Reimagined 7z files found in Launcher folder. Please download the latest version from Nexus Mods." MAIN_MENU
) ELSE IF %file_count% GTR 1 (
    CALL :ERROR_HANDLER "Multiple 7z files found in Launcher folder. Please ensure only one 7z file is present." MAIN_MENU
)

:: Extract truncated file name
SETLOCAL ENABLEDELAYEDEXPANSION
SET "truncated_install_file_name="
FOR %%I IN ("%install_file%") DO (
    SET "install_file_name=%%~nI"
    FOR /F "tokens=1,2 delims=-" %%A IN ("!install_file_name!") DO (
        SET "truncated_install_file_name=%%A-%%B"
    )
)
ENDLOCAL & SET "truncated_install_file_name=%truncated_install_file_name%"

:: Debugging output
IF "%debug%"=="1" (
    ECHO Debug: install_file="%install_file%"
    ECHO Debug: file_count="%file_count%"
)
EXIT /B

:LOCATE_SAVED_GAMES_DIR
:: Search for the most recently updated "Reimagined" folder containing .d2s files, ignoring directories named "Backup"
SET "savedir="
FOR /F "tokens=*" %%A IN ('powershell -Command "Get-ChildItem -Path $env:USERPROFILE -Recurse -Directory -Filter 'Reimagined' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\Backup(\\|$)' -and (Get-ChildItem -Path $_.FullName -Filter '*.d2s' -File -ErrorAction SilentlyContinue).Count -gt 0 } | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"') DO (
    SET "savedir=%%A"
)

:: Set savedir without the 'Reimagined' folder
SET "savedir=%savedir%"
IF /I "%savedir:~-10%"=="Reimagined" (
    SET "savedir=%savedir:~0,-10%"
) ELSE IF /I "%savedir:~-11%"=="Reimagined\" (
    SET "savedir=%savedir:~0,-11%"
)

:: Ensure the path does not end with a trailing backslash
IF "%savedir:~-1%"=="\" SET "savedir=%savedir:~0,-1%"

:: Ensure the path exists
IF NOT EXIST "%savedir%" (
    CALL :ERROR_HANDLER "Error: The parent directory of the Reimagined folder does not exist. Please check the path or reinstall Reimagined." INSTALL_UPDATE
)

:: Debugging output
IF "%debug%"=="1" (
    ECHO Debug: Trimmed Saved Games Directory="%savedir%"
    ECHO Debug: Locate Saved Games Directory function completed successfully.
    PAUSE
)
EXIT /B

:: Verify the Reimagined folder and its contents
:VERIFY_REIMAGINED_FOLDER
SET "mod_checked=1"  :: mod isn't considered installed until we check the folder
IF NOT EXIST "%appdir%\mods\Reimagined\" (
    CALL :ERROR_HANDLER "Reimagined mod folder does not exist. Let's install the mod before proceeding further." INSTALL_UPDATE
) ELSE (
    DIR /B "%appdir%\mods\Reimagined" >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Reimagined mod folder is empty. Let's install the mod before proceeding further." INSTALL_UPDATE
    )
)
:: Mod confirmed as installed and not empty
SET "mod_checked=0"

:: Debugging output
IF "%debug%"=="1" (
    ECHO Debug: Reimagined folder exists and is not empty.
)
EXIT /B

:ERROR_HANDLER
:: %1 = Error message, %2 = EXIT (optional)
ECHO.
ECHO %~1
ECHO.
IF NOT "%~2"=="" (
    PAUSE
    GOTO %~2
)
PAUSE
EXIT /B

:COPY_FILES
:: %1 = Source, %2 = Destination
xcopy /e /r /y "%~1" "%~2" >nul 2>&1
IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Failed to copy files from '%~1' to '%~2'." EXIT
)
EXIT /B

:OPEN_LINK
:: %1 = URL
START "" "%~1"
EXIT /B
:: End of subroutines

:: End of script