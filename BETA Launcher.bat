@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:                                              REIMAGINED BETA LAUNCHER                                              :
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:                                                  INITIALISATION                                                    :
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Constants
:: 0 = enabled, 1 = disabled
SET "debug=1"

:: find the location of the launcher script
SET "launcher=%~dp0"
IF "%launcher:~-1%"=="\" SET "launcher=%launcher:~0,-1%"

:: Query the registry for the install location
FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Diablo II Resurrected" /v InstallLocation 2^>nul`) DO (
    @SET "appdir=%%A %%B"
)

CALL :CREATE_CHECK_SETTINGS :: Check if the settings file exists, if not, create it
CALL :VERIFY_D2R_INSTALL :: Check Diablo II Resurrected installation
CALL :VERIFY_REIMAGINED_FOLDER :: Check Reimagined installation
CALL :FIND_OR_CREATE_SAVE_DIR :: Find Saved Games location
CALL :FIND_OR_CREATE_BACKUP_DIR :: Find Backup location
CALL :UPDATE_CHECK :: Check for Mod and Launcher Updates
:: Display current value of settings to help debug
IF "%debug%"=="0" ECHO. & CALL :DISPLAY_SETTINGS "%settings%" & ECHO. & PAUSE

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of initialisation
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:MAIN_MENU
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Main Menu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO ------------- REIMAGINED BETA LAUNCHER -------------
ECHO.
ECHO Welcome to the Reimagined BETA Launcher.
ECHO.
ECHO     [1] Play Reimagined
ECHO.
ECHO Mod Options:
ECHO     [2] Install / Update
ECHO     [3] Configuration Menu
ECHO     [4] Backup Save Files
ECHO     [5] Check For Updates

:: TODO
:: FLESH OUT MOD / LAUNCHER UPDATE CHECK FUNCTION

ECHO.
ECHO Community Links:
ECHO     [6] Visit Reimagined Website
ECHO     [7] Visit Reimagined Wiki
ECHO     [8] Visit Reimagined Nexus Page
ECHO     [9] Visit Reimagined Discord Server
ECHO.
ECHO     [X] Exit Launcher
ECHO.
SET /P "menu_choice=What would you like to do: "

IF "%menu_choice%"=="1" GOTO PLAY_REIMAGINED
IF "%menu_choice%"=="2" GOTO INSTALL_UPDATE
IF "%menu_choice%"=="3" GOTO CONFIGURATION_MENU
IF "%menu_choice%"=="4" GOTO BACKUP_FILES
IF "%menu_choice%"=="5" (
    CALL :UPDATE_MOD_CHECK
    CALL :UPDATE_LAUNCHER_CHECK
)
IF "%menu_choice%"=="6" CALL :OPEN_LINK "https://www.d2r-reimagined.com"
IF "%menu_choice%"=="7" CALL :OPEN_LINK "https://wiki.d2r-reimagined.com"
IF "%menu_choice%"=="8" CALL :OPEN_LINK "https://www.nexusmods.com/diablo2resurrected/mods/503"
IF "%menu_choice%"=="9" CALL :OPEN_LINK "https://discord.gg/5bbjneJCrr"
IF /I "%menu_choice%"=="X" EXIT

GOTO MAIN_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Main Menu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:PLAY_REIMAGINED
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Play Reimagined
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL :CHECK_7Z_FILES
CALL :VERIFY_REIMAGINED_FOLDER
IF "%mod_checked%"=="0" (

    :: TODO
    :: CHECK settings FOR BACKUP VARIABLE
    :: CHECK settings FOR BACKUP FORMAT VARIABLE
    :: IF ON_LAUNCH, BACKUP SAVE FILES ACCORDING TO BACKUP FORMAT VARIABLE, LAUNCH GAME, EXIT
    :: IF PER X MINUTES, KEEP LAUNCHER WINDOW OPEN, PERFORM BACKUP EVERY X MINUTES
    :: UPDATE START GAME CALL TO INCLUDE CUSTOM LAUNCH ARGUMENTS (IF SET)

    START "" "%appdir%\D2R.exe" -mod Reimagined -txt
    EXIT
) ELSE (
    CALL :ERROR_HANDLER "Reimagined mod folder is not found or is empty. Please ensure the mod is installed correctly." INSTALL_UPDATE
)
EXIT /B

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Play Reimagined
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:INSTALL_UPDATE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Utility to update the Reimagined mod using a 7z file
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL :CHECK_7Z_FILES
CLS
ECHO.
ECHO ------------- INSTALL / UPDATE -------------
ECHO.
ECHO 7z File: %truncated_install_file_name%
ECHO.
SET /P "install_choice=Would you like to install this version now? (Y/N): "

    ::TODO
    :: NEXUS MODS API INTEGRATION
    :: CHECK FOR UPDATES ON NEXUS MODS
    :: IF FOUND, PROMPT USER TO DOWNLOAD
    :: DOWNLOAD FROM NEXUS MODS
    :: CHECK LAUNCHER FOLDER FOR 7Z FILE - IF FOUND, REMOVE IT
    :: MOVE NEW 7Z FROM DOWNLOADS FOLDER TO LAUNCHER
    :: PROCEED WITH INSTALLATION

IF /I "%install_choice%"=="Y" (
    :: INSTALL REIMAGINED
    :INSTALL_REIMAGINED
        :: Ensure the install_file variable is correctly expanded
        IF NOT DEFINED install_file (
            CALL :ERROR_HANDLER "Error: No installation file found. Please ensure the file exists." CHECK_7Z_FILES
        )
        :: Extract the 7z file using 7zr.exe and suppress output
        IF NOT EXIST "%launcher%\utils\7zr\7zr.exe" (
            CALL :ERROR_HANDLER "Error: 7zr.exe not found. Please ensure it is installed in the correct location." INSTALL_UPDATE
        )
        ECHO.
        ECHO Installing %truncated_install_file_name%...
        ECHO.
        "%launcher%\utils\7zr\7zr.exe" x "%install_file%" -o"%appdir%" -y >nul 2>&1
        IF ERRORLEVEL 1 (
            CALL :ERROR_HANDLER "Error: Failed to extract the 7z file. Please ensure the file exists and is not corrupted." INSTALL_UPDATE
        )
        TIMEOUT /T 2 >nul
        ECHO Installation completed successfully!
        ECHO.
        ECHO Restarting the launcher...
        PAUSE
        START "" "%~f0"
        EXIT
) ELSE IF /I "%install_choice%"=="N" (
    CALL :VERIFY_REIMAGINED_FOLDER
    CALL :ERROR_HANDLER "Installation skipped. Returning to main menu..." MAIN_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." INSTALL_UPDATE
)
EXIT /B

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Install / Update
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:CONFIGURATION_MENU
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Configuration Menu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL :VERIFY_REIMAGINED_FOLDER

CLS
ECHO.
ECHO ------------- CONFIGURATION MENU -------------
ECHO.
ECHO Play Options: (coming soon)
ECHO    [1] Generate a shortcut to play Reimagined,
ECHO        Add more launch arguments, etc.
ECHO.
ECHO Modification Options:
ECHO    [2] Expand Shared Stash
ECHO    [3] Force Terror Zones
ECHO    [4] Remove Splash Charm Graphic Effect
ECHO    [5] Increase Level Up Stats
ECHO    [6] Letterbox Removal
ECHO    [7] CASC Fastloading
ECHO.
ECHO    [8] Reset Modifications (coming soon)
ECHO.
ECHO Launcher Preferences:
ECHO    [Q] View Current Settings
ECHO    [W] Restore Settings from Backup
ECHO.
ECHO    [E] Toggle Launcher Update Check
ECHO    [R] Toggle Mod Update Check
ECHO.
ECHO    [X] Back to Main Menu
ECHO.
SET /P "advoption_choice=What would you like to do: "

:: TODO
:: UPDATE EXPANDED STASH WITH settings CHECKS
:: UPDATE FORCED TERROR ZONES WITH ADDITIONAL OPTIONS
:: ADD LETTERBOX REMOVAL
:: ADD RESET ADVANCED OPTIONS
    :: CHECK settings FOR ADVANCED OPTIONS VARIABLES
    :: SET VARIABLES TO 1
    :: COPY DEFAULT MOD FILES FROM BACKUPS TO REIMAGINED MOD DIRECTORY

IF "%advoption_choice%"=="1" GOTO PLAY_OPTIONS
IF "%advoption_choice%"=="2" GOTO EXPANDED_STASH
IF "%advoption_choice%"=="3" GOTO FORCE_TERROR_ZONES
IF "%advoption_choice%"=="4" GOTO SPLASH_CHARM_GRAPHIC
IF "%advoption_choice%"=="5" GOTO INCREASE_LEVEL_STATS
IF "%advoption_choice%"=="6" GOTO LETTERBOX_REMOVAL
IF "%advoption_choice%"=="7" GOTO CASC_FASTLOADING
IF "%advoption_choice%"=="8" (
    ::CALL :RESET_MODIFICATIONS
    GOTO CONFIGURATION_MENU
)
IF /I "%advoption_choice%"=="Q" (
    CLS
    CALL :DISPLAY_SETTINGS "%settings%"
    PAUSE 
    GOTO CONFIGURATION_MENU
)
IF /I "%advoption_choice%"=="E" (
    CALL :TOGGLE_LAUNCHER_UPDATE_CHECK
    GOTO CONFIGURATION_MENU
)
IF /I "%advoption_choice%"=="R" (
    CALL :TOGGLE_MOD_UPDATE_CHECK
    GOTO CONFIGURATION_MENU
)
IF /I "%advoption_choice%"=="W" (
    CALL :RESTORE_SETTINGS_FROM_BACKUP
    GOTO CONFIGURATION_MENU
)
IF /I "%advoption_choice%"=="X" GOTO MAIN_MENU
CALL :ERROR_HANDLER "Invalid choice. Please try again." CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Advanced Options
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:PLAY_OPTIONS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Play Options
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: TODO
:: ADD PLAY OPTIONS
    :: GENERATE SHORTCUT (/W BACKUP OPTION)
    :: ADD MORE LAUNCH ARGUMENTS (REGEN SHORTCUT)
GOTO CONFIGURATION_MENU

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Play Options
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:EXPANDED_STASH
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Increases player Shared Stash Tabs from 3 to 7
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO ------------- Expanded Shared Stash Tabs -------------
ECHO.
ECHO Expands your Shared Stash Tabs from 3 to 7
ECHO.
ECHO    [1] Re-install Expanded Stash
ECHO    [2] New install of Expanded Stash
ECHO        You will be asked to confirm this action.
ECHO.
ECHO    [X] Back to Configuration Menu
ECHO.
SET "stash_choice="
SET "stash_choice_affirm="
SET /P "stash_choice=What would you like to do? "

:: TODO
:: CHECK SETTINGS FOR EXPANDED STASH / STASH NAMES VARIABLES
:: IF NOT EXIST, ADD THEM TO SETTINGS

:: CHECK SETTINGS IF EXPANDED STASH IS INSTALLED
:: IF INSTALLED, GO TO OPTION 1
:: IF NOT INSTALLED, GO TO OPTION 2
:: CONFIRM WITH USER IF THEY WANT TO PROCEED WITH INSTALLATION
:: IF YES, INSTALL EXPANDED STASH
:: IF NO, GO BACK TO CONFIGURATION MENU

:: RENAME SHARED STASH TABS
:: CHECK SETTINGS IF EXPANDED STASH IS INSTALLED
:: IF INSTALLED, ALLOW RENAMING OF ALL 7 TABS
:: IF NOT INSTALLED, ALLOW RENAMING OF 3 TABS ONLY
:: UPDATE SETTINGS WITH NEW NAMES

:: TODO ADD THE BELOW WHEN ENABLING EXPANDED STASH
::expanded_stash=1
::expanded_stash_rename=1
::shared_stash_tab_1=Shared
::shared_stash_tab_2=Shared
::shared_stash_tab_3=Shared
::shared_stash_tab_4=Shared
::shared_stash_tab_5=Shared
::shared_stash_tab_6=Shared
::shared_stash_tab_7=Shared

IF "%stash_choice%"=="1" (
    ECHO.
    TIMEOUT /T 1 >nul
    CALL :COPY_FILES "%launcher%\utils\mods\Expanded Stash Mod Directory\mods\" "%appdir%\mods\"
    CALL :SET_FILE_VALUE "%settings%" "expanded_stash" "0"
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
        CALL :COPY_FILES "%launcher%\utils\mods\Expanded Stash Mod Directory\mods\" "%appdir%\mods\"
        IF ERRORLEVEL 1 (
            CALL :ERROR_HANDLER "Failed to copy Expanded Stash Mod Directory files." CONFIGURATION_MENU
        )
        CALL :COPY_FILES "%launcher%\utils\mods\Expanded Stash Saved Game\Reimagined\" "%save_location%"
        IF ERRORLEVEL 1 (
            CALL :ERROR_HANDLER "Failed to copy Expanded Stash Saved Game files." CONFIGURATION_MENU
        )
        ENDLOCAL
        CALL :SET_FILE_VALUE "%settings%" "expanded_stash" "0"
        ECHO Upgrade complete
        ECHO.
    ) ELSE IF /I "!stash_choice_affirm!"=="N" (
        color 07
        ENDLOCAL
        CALL :ERROR_HANDLER "Stash remains smol..." CONFIGURATION_MENU
    ) ELSE (
        color 07
        ENDLOCAL
        CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." EXPANDED_STASH
    )
) ELSE IF /I "%stash_choice%"=="X" (
    GOTO CONFIGURATION_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter a valid number." EXPANDED_STASH
)
PAUSE
GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Expanded Stash
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:FORCE_TERROR_ZONES
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Forces Terror Zones to be a fixed, permanent list of zones
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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

:: TODO
:: CHECK settings FOR FORCED TERROR ZONES VARIABLES
:: IF NOT FOUND, ADD THEM TO settings

:: IF INSTALLING, SET settings VARIABLE TO 0

:: ADD NEW FORCED TERROR ZONE CONFIGURATION OPTIONS

:: ADD UNINSTALL OPTION

IF /I "%terror_choice%"=="Y" (
    ECHO.
    ECHO Terrorizing Sanctuary...
    TIMEOUT /T 2 >nul
    CALL :COPY_FILES "%launcher%\utils\mods\Force Terror Zones\mods" "%appdir%\mods\"
    CALL :SET_FILE_VALUE "%settings%" "forced_terror_zones" "0"
    ECHO.
    ECHO Evil has spread across Sanctuary...
    ECHO.
    PAUSE
    GOTO CONFIGURATION_MENU
) ELSE IF /I "%terror_choice%"=="N" (
    CALL :ERROR_HANDLER "Sanctuary remains safe for now..." CONFIGURATION_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." FORCE_TERROR_ZONES
)
PAUSE
GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Forced Terror Zones
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:SPLASH_CHARM_GRAPHIC
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Removes the graphical effect of the Splash Charm (Collin's Charm)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO.
ECHO ------------- Splash Charm Graphic Effect Removal -------------
ECHO.
ECHO Removes the particle effect when using the Splash Charm (Collin's Charm).
ECHO.
SET /P "splash_choice=Do you wish to proceed? (Y/N): "

:: TODO
:: CHECK settings FOR SPLASH CHARM VARIABLES
:: IF NOT FOUND, ADD THEM TO settings

:: IF INSTALLING, SET settings VARIABLE TO 0

:: ADD UNINSTALL OPTION

IF /I "%splash_choice%"=="Y" (
    ECHO.
    ECHO Cleaning up Collin's mess...
    ECHO.
    TIMEOUT /T 2 >nul
    CALL :COPY_FILES "%launcher%\utils\mods\Splash Charm Graphic\mods" "%appdir%\mods\"
    CALL :SET_FILE_VALUE "%settings%" "splash_charm_graphic_removed" "0"
    ECHO There, all clean now.
    ECHO.
    PAUSE
    GOTO CONFIGURATION_MENU
) ELSE IF /I "%splash_choice%"=="N" (
    CALL :ERROR_HANDLER "Tsk Tsk Collin, you really should clean up after yourself" CONFIGURATION_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." SPLASH_CHARM_GRAPHIC
)
PAUSE
GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Splash Charm Graphic Effect Removal
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:INCREASE_LEVEL_STATS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Updates characters to gain 2 Skill Points and 8 Attribute Points per level
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO.
ECHO ------------- Increase Level Up Stats -------------
ECHO.
ECHO Updates characters to gain 2 Skill Points and 8 Attribute Points per level.
ECHO.
ECHO Disclaimers:
ECHO    These change do not work retroactively.
ECHO    Skill and Attribute Points already earned cannot be modified.
ECHO    If you uninstall this change characters will return to earning 1 Skill Point and 5 Attribute Points per level.
ECHO    Using a Token of Absolution to reset your character will refund all accumulated Skill Points and Attribute Points
ECHO    earned up to that point.
ECHO.
SET /P "skill_choice=Do you wish to proceed? (Y/N): "

:: TODO
:: CHECK settings FOR TWO SKILL POINTS VARIABLES
:: IF NOT FOUND, ADD THEM TO settings

:: IF INSTALLING, SET settings VARIABLE TO 0

:: ADD UNINSTALL OPTION

IF /I "%skill_choice%"=="Y" (
    ECHO.
    ECHO Applying cheat codes...
    TIMEOUT /T 2 >nul
    CALL :COPY_FILES "%launcher%\utils\mods\Increase Level Stats\mods\" "%appdir%\mods\"
    CALL :SET_FILE_VALUE "%settings%" "increased_level_stats" "0"
    ECHO.
    ECHO You're now a 'super' Sorceress.
    ECHO.
    PAUSE
    GOTO CONFIGURATION_MENU
) ELSE IF /I "%skill_choice%"=="N" (
    CALL :ERROR_HANDLER "So close to being a 'super' Sorceress, but you chose wisely." CONFIGURATION_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." INCREASE_LEVEL_STATS
)
PAUSE
GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Two Skill Points
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:LETTERBOX_REMOVAL
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Removes the letterbox effect from the game
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO.
ECHO ------------- Letterbox Removal -------------
ECHO.
ECHO Removes the letterbox effect from the game, providing a more immersive experience.
ECHO.
SET /P "letterbox_choice=Do you wish to proceed? (Y/N): "
IF /I "%letterbox_choice%"=="Y" (
    ECHO.
    ECHO Broadening your horizons...
    TIMEOUT /T 2 >nul
    CALL :COPY_FILES "%launcher%\utils\mods\Letterbox\mods\" "%appdir%\mods\"
    CALL :SET_FILE_VALUE "%settings%" "letterbox_removal" "0"
    ECHO.
    ECHO You can now teleport *slightly* farther than before. Fancy that.
    ECHO.
    PAUSE
    GOTO CONFIGURATION_MENU
) ELSE IF /I "%letterbox_choice%"=="N" (
    CALL :ERROR_HANDLER "How narrow-minded of you." CONFIGURATION_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." LETTERBOX_REMOVAL
)
PAUSE
GOTO CONFIGURATION_MENU

:: TODO
:: CHECK settings FOR LETTERBOX VARIABLES
:: IF NOT FOUND, ADD THEM TO settings
:: IF INSTALLING, SET settings VARIABLE TO 0

:: ADD UNINSTALL OPTION

GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Letterbox Removal
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:CASC_FASTLOADING
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Unpack game files for faster load times, requires 41GB of free space
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO.
ECHO ------------- CASC Fastloading -------------
ECHO.
ECHO Unpacks all game files for faster load times, reduced latency,
ECHO snappier controls, and increased in-game FPS.
ECHO.
ECHO This process takes roughly 5-10 minutes to complete, and will reinstall the mod automatically.
ECHO.
ECHO This change has no impact on your character save files.
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
IF "%debug%"=="0" (
    ECHO Debug: Free space in GB=%free_space_gb%
    ECHO Debug: Required space in bytes=%required_space_gb%
    PAUSE
)

:: Error handling for undefined variables
IF NOT DEFINED free_space (
    CALL :ERROR_HANDLER "Failed to retrieve free disk space. Please check your system." CONFIGURATION_MENU
)
:: Ensure free_space is numeric
FOR /F "delims=0123456789" %%B IN ("%free_space_gb%") DO (
    CALL :ERROR_HANDLER "Invalid free space value retrieved: '%free_space_gb%'. Please check your system." CONFIGURATION_MENU
)
IF NOT DEFINED required_space_gb (
    CALL :ERROR_HANDLER "Failed to calculate required disk space. Please check your system." CONFIGURATION_MENU
)

:: Compare free space with required space
IF %free_space_gb% LSS %required_space_gb% (
    CALL :ERROR_HANDLER "Not enough available space on disk to perform this action. Please ensure you have at least 41GB free before trying again." CONFIGURATION_MENU
)

ECHO Free space on %appdir:~0,1%: Drive (D2R Install Location): %free_space_gb% GB
ECHO.

SET /P "casc_choice=Would you like to proceed? (Y/N): "

:: TODO
:: CHECK settings FOR CASC FASTLOADING VARIABLES
:: IF NOT FOUND, ADD THEM TO settings

:: IF INSTALLING, SET settings VARIABLE TO 0

:: IF USER TRIES TO INSTALL AGAIN ONCE settings IS SET, PROMPT USER TO CONFIRM

:: ADD UNINSTALL OPTION
:: ADD NOTE TO UNINSTALL THAT USER SHOULD EMPTY RECYCLE BIN UPON COMPLETION

IF /I "%casc_choice%"=="Y" (
    ECHO.
    ECHO This process will take 5-10 minutes to complete.
    ECHO Please do not close this window until the process is finished.
    ECHO.
    MD "%appdir%\casctemp" >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Failed to create temporary directory '%appdir%\casctemp'. Please check permissions or the path." CONFIGURATION_MENU
    )
    IF NOT EXIST "%launcher%\utils\Casc\CASCConsole.exe" (
        CALL :ERROR_HANDLER "Error: CASCConsole.exe not found at '%launcher%\utils\Casc\CASCConsole.exe'. Please ensure it is installed in the correct location." CONFIGURATION_MENU
    )
    ECHO Extracting game files...
    "%launcher%\utils\Casc\CASCConsole.exe" -l None -d "%appdir%\casctemp" -s "%appdir%" -m Pattern -e data/data/*.* -p osi >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Failed to extract game files using CASCConsole.exe. Please check the logs for details." CONFIGURATION_MENU
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
        CALL :SET_FILE_VALUE "%settings%" "casc_fastloading" "0"
        ECHO Reinstalling Reimagined, please wait...
        CALL :CHECK_7Z_FILES
        TIMEOUT /T 2 >nul
        :: Reinstall Reimagined, restart launcher
        CALL :INSTALL_REIMAGINED
    ) ELSE (
        CALL :ERROR_HANDLER "Failed to find extracted game files in '%appdir%\casctemp'. Please check the extraction process." CONFIGURATION_MENU
    )
) ELSE IF /I "%casc_choice%"=="N" (
    CALL :ERROR_HANDLER "Not enough space with all that 'science' material, eh?" CONFIGURATION_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." CASC_FASTLOADING
)

PAUSE
GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of CASC Fastloading
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RESET_MODIFICATIONS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Resets modifications to their default values
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO.
ECHO ------------- Reset Advanced Options -------------
ECHO.
ECHO.
ECHO This will reset all advanced options to their default values.
ECHO.

:: TODO
:: CHECK settings FOR ADVANCED OPTIONS VARIABLES
:: SHOW USER CURRENT VALUES
:: ASK FOR CONFIRMATION
:: SET VARIABLES TO 1

GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Reset Modifications
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:TOGGLE_LAUNCHER_UPDATE_CHECK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Toggle the launcher update check on or off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL :GET_FILE_VALUE "%settings%" "launcher_auto_update" launcher_auto_update

IF "%launcher_auto_update%"=="1" (
    CALL :SET_FILE_VALUE "%settings%" "launcher_auto_update" "0"
    CALL :ERROR_HANDLER "Enabled launcher update check on startup." CONFIGURATION_MENU
) ELSE (
    CALL :SET_FILE_VALUE "%settings%" "launcher_auto_update" "1"
    CALL :ERROR_HANDLER "Disabled launcher update check on startup." CONFIGURATION_MENU
)
GOTO CONFIGURATION_MENU

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Toggle Launcher Update Check
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:TOGGLE_MOD_UPDATE_CHECK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Toggle the mod update check on or off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL :GET_FILE_VALUE "%settings%" "mod_auto_update" mod_auto_update

IF "%mod_auto_update%"=="1" (
    CALL :SET_FILE_VALUE "%settings%" "mod_auto_update" "0"
    CALL :ERROR_HANDLER "Enabled mod update check on startup." CONFIGURATION_MENU
) ELSE (
    CALL :SET_FILE_VALUE "%settings%" "mod_auto_update" "1"
    CALL :ERROR_HANDLER "Disabled mod update check on startup." CONFIGURATION_MENU
)

GOTO CONFIGURATION_MENU

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Toggle Mod Update Check
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RESTORE_SETTINGS_FROM_BACKUP
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Restore settings from backup
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS

:: Check for backup files and folders
IF NOT DEFINED d2r_mod_saves CALL :FIND_OR_CREATE_SAVE_DIR
IF NOT EXIST "%backup_location%" (
    ECHO Error: Couldn't find a backup directory.
    CALL :ERROR_HANDLER "Try creating a backup first." BACKUP_FILES
)
IF NOT EXIST "%backup_location%\settings.txt" (
    ECHO Error: Couldn't find a backup file to restore from in %backup_Location%
    CALL :ERROR_HANDLER "Try creating a backup first." BACKUP_FILES
)
CLS
ECHO.
ECHO ------------- Restore Settings from Backup -------------
ECHO.
ECHO Retrieves settings from a backup file and overwrites existing settings.
ECHO.
ECHO Backup file location: "%backup_location%\settings.txt"
ECHO.
SET /P "restore_choice=Do you wish to proceed? (Y/N): "
IF /I "%restore_choice%"=="Y" (
    CALL :COPY_FILE "%backup_location%\settings.txt" "%settings%"
    CALL :ERROR_HANDLER "Settings restored from backup." CONFIGURATION_MENU
) ELSE IF /I "%restore_choice%"=="N" (
    CALL :ERROR_HANDLER "Settings remain unchanged." CONFIGURATION_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." RESTORE_SETTINGS_FROM_BACKUP
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Restore Settings from Backup
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BACKUP_FILES
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Finds the most recently updated Reimagined folder that contains character files, and creates a backup using tar
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF NOT DEFINED d2r_mod_saves OR "%d2r_mod_saves%"=="" (
    CALL :FIND_OR_CREATE_SAVE_DIR
)

:: Initialise backup variables
:: Ensure tar is available
WHERE tar >nul 2>&1
IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Error: tar is not available on this system. Please install it or use a different backup method." MAIN_MENU
)
:: Ensure the backup directory exists
IF NOT EXIST "%backup_location%" MD "%backup_location%" >nul 2>&1
IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Error: Failed to create backup directory. Please check permissions or the path." BACKUP_FILES
)
:: Set the backup file name with the current date
SET "current_date="
:: Get the current date in YYYYMMDD format
FOR /F "tokens=*" %%A IN ('powershell -Command "Get-Date -Format yyyyMMdd"') DO SET "current_date=%%A"

IF EXIST "%backup_location%" SET "backup_file_name=%backup_location%\%current_date%.zip"
:: End initialise backup variables

CLS
ECHO.
ECHO ------------- BACKUP FILES -------------
ECHO.
ECHO Save Location: "%save_location%"
ECHO Backup Location: "%backup_location%"
ECHO.
ECHO    [1] Create Backup
ECHO            Will prompt to overwrite if a backup file already exists.
ECHO    [2] Open Backup Folder
ECHO.
ECHO Preferences:
ECHO    [3] Change Backup Frequency (coming soon)
ECHO    [4] Change Backup Format (Date vs Date + Time) (coming soon)
ECHO    [5] Change Save Location (coming soon)
ECHO    [6] Change Backup Location (coming soon)
ECHO.
ECHO    [X] Back to Main Menu
ECHO.

SET "backup_choice="
SET /P "backup_choice=What would you like to do? "

:: TODO
:: CHECK settings FOR SAVE AND BACKUP VARIABLES
:: IF NOT FOUND, ADD THEM TO settings

:: ADD CONFIGURE AUTO BACKUP
    :: CHECK settings FOR BACKUP FREQUENCY VARIABLE
    :: IF NOT FOUND, ADD IT TO settings
        :: SET BACKUP FREQUENCY TO ON LAUNCH AS DEFAULT
    :: IF FOUND, 
:: ADD CHANGE BACKUP FORMAT
:: ADD CHANGE SAVE LOCATION
    :: IF USER CHANGES SAVE LOCATION, SET settings VARIABLE, PROMPT COPY OF REIMAGINED FOLDER TO NEW LOCATION, PROMPT DELETE OLD REIMAGINED FOLDER
:: ADD CHANGE BACKUP LOCATION
   :: IF USER CHANGES BACKUP LOCATION, SET settings VARIABLE, PROMPT COPY settings TO NEW LOCATION, PROMPT DELETE OLD settings

IF "%backup_choice%"=="1" (
    CALL :CREATE_BACKUP
) ELSE IF "%backup_choice%"=="2" (
    START "" "%backup_location%"
    GOTO BACKUP_FILES
) ELSE IF "%backup_choice%"=="3" (
    GOTO MAIN_MENU
) ELSE IF "%backup_choice%"=="4" (
    GOTO MAIN_MENU
) ELSE IF "%backup_choice%"=="5" (
    GOTO MAIN_MENU
) ELSE IF "%backup_choice%"=="6" (
    GOTO MAIN_MENU
)ELSE IF /I "%backup_choice%"=="X" (
    GOTO MAIN_MENU
) ELSE (
    CALL :ERROR_HANDLER "Invalid choice." BACKUP_FILES
)

:CREATE_BACKUP
    SETLOCAL ENABLEDELAYEDEXPANSION
    :: Check if the backup file already exists
    IF EXIST "%backup_file_name%" (
        ECHO A backup file already exists.
        ECHO.
        SET /P "overwrite_choice=Do you want to overwrite it? (Y/N): "

        :: Validate the input
        IF /I "!overwrite_choice!"=="Y" (
            ECHO Overwriting existing backup file...
        ) ELSE IF /I "!overwrite_choice!"=="N" (
            CALL :ERROR_HANDLER "Backup operation canceled." BACKUP_FILES
        ) ELSE (
            CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." BACKUP_FILES
        )
    )
    :: Disable delayed variable expansion
    ENDLOCAL

    :: Perform character backup
    tar -a -c -f "%backup_file_name%" -C "%d2r_mod_saves%" "Reimagined" >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Error: Failed to create the backup. Please check if the save files exist and try again." BACKUP_FILES
    )
    IF NOT EXIST "%backup_file_name%" (
        CALL :ERROR_HANDLER "Could not create backup file. Please check for issues and try again." BACKUP_FILES
    )
    IF EXIST "%settings%" (
        CALL :COPY_FILE "%settings%" "%backup_location%"
        IF ERRORLEVEL 1 (
            CALL :CREATE_CHECK_SETTINGS
            CALL :COPY_FILE "%settings%" "%backup_location%"
        )
    )

    ECHO Backup completed successfully!
    ECHO.
    PAUSE
    GOTO BACKUP_FILES

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Backup Save Files
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:UPDATE_CHECK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check whether there are updates available for the launcher or Reimagined
IF "%debug%"=="0" ECHO Entering UPDATE_CHECK... & ECHO. & PAUSE
IF "%debug%"=="0" ECHO Initial values, mod: "%mod_auto_update%", launcher: "%launcher_auto_update%" & ECHO. & PAUSE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF NOT DEFINED mod_auto_update (
    IF "%debug%"=="0" ECHO mod auto update not defined, setting now & ECHO. & PAUSE
    CALL :SET_FILE_VALUE "%settings%" "mod_auto_update" "0"
) ELSE (
    IF "%mod_auto_update%"=="" (
        IF "%debug%"=="0" ECHO mod auto update not set, setting now & ECHO. & PAUSE
        CALL :SET_FILE_VALUE "%settings%" "mod_auto_update" "0"
    )
)

IF NOT DEFINED launcher_auto_update (
    IF "%debug%"=="0" ECHO launcher auto update not defined, setting now & ECHO. & PAUSE
    CALL :SET_FILE_VALUE "%settings%" "launcher_auto_update" "0"
) ELSE (
    IF "%launcher_auto_update%"=="" (
        IF "%debug%"=="0" ECHO mod auto update not set, setting now & ECHO. & PAUSE
        CALL :SET_FILE_VALUE "%settings%" "launcher_auto_update" "0"
    )
)

IF "%debug%"=="0" ECHO Current values, mod: "%mod_auto_update%", launcher: "%launcher_auto_update%" & ECHO. & PAUSE

IF "%mod_auto_update%"=="0" CALL :UPDATE_MOD_CHECK
IF "%launcher_auto_update%"=="0" CALL :UPDATE_LAUNCHER_CHECK

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Update Check
IF "%debug%"=="0" ECHO Exiting UPDATE_CHECK... & ECHO. & PAUSE

EXIT /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:UPDATE_MOD_CHECK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check Nexus Mods for updates, if available, prompt user to update
IF "%debug%"=="0" ECHO Entering UPDATE_MOD_CHECK... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO Checking for buffs and nerfs...
ECHO.
TIMEOUT /T 2 >nul

:: TODO
:: CHECK NEXUS MODS FOR UPDATES
:: IF UPDATES AVAILABLE, PROMPT USER TO DOWNLOAD
:: IF USER CHOOSES TO DOWNLOAD, OPEN NEXUS MODS PAGE
:: PROMPT USER TO CONFIRM WHEN DOWNLOAD IS COMPLETE
:: PROMPT USER IF THEY WANT TO MAKE A BACKUP
:: IF USER CHOOSES TO MAKE A BACKUP, CALL BACKUP_FILES SUBROUTINE
:: MOVE NEW 7Z FILE FROM DOWNLOADS FOLDER TO LAUNCHER FOLDER
:: RUN INSTALL/UPDATE PROCESS
:: IF USER CHOOSES NOT TO DOWNLOAD, PROCEED TO MAIN MENU

ECHO Nothing to see here, move along...
ECHO.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Update Mod Check
IF "%debug%"=="0" ECHO Exiting UPDATE_MOD_CHECK... & ECHO. & PAUSE

TIMEOUT /T 1 >nul
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:UPDATE_LAUNCHER_CHECK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check GitHub for the last commit date/time and compare with launcher_version in settings.txt
IF "%debug%"=="0" ECHO Entering UPDATE_LAUNCHER_CHECK... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO Checking Horadric Cube recipes for launcher upgrades...
ECHO.

:: Define the base URL of the GitHub repository
SET "base_url=https://api.github.com/repos/Vingelis/Reimagined-BETA-Launcher/commits/main"

:: Read the launcher_version from the settings.txt file
FOR /F "tokens=2 delims==" %%A IN ('FINDSTR /I "^launcher_version=" "%settings%"') DO SET "launcher_version=%%A"

IF "%debug%"=="0" ECHO Debug: Launcher Version = "%launcher_version%" & ECHO. & PAUSE

SETLOCAL ENABLEDELAYEDEXPANSION
:: Make the API request and save the response to a temporary file
curl -s -H "Accept: application/vnd.github.v3+json" %base_url% > response.txt

:: Extract the datetime of the last commit using jq
FOR /F "tokens=*" %%I IN ('powershell -Command "(Get-Content response.txt | ConvertFrom-Json).commit.committer.date"') DO SET LAST_COMMIT_DATETIME=%%I
:: Clean up the temporary file
DEL response.txt

ENDLOCAL & SET "github_last_commit=%LAST_COMMIT_DATETIME%"

:: Parse the GitHub datetime into a comparable format (yyyyMMddHHmmss)
FOR /F "tokens=*" %%B IN ('powershell -Command "[datetime]::ParseExact('%github_last_commit%', 'yyyy-MM-ddTHH:mm:ssZ', $null).ToString('yyyyMMddHHmmss')"') DO SET "github_last_commit_parsed=%%B"

IF "%debug%"=="0" ECHO Debug: GitHub last commit datetime = "%github_last_commit_parsed%" & ECHO. & PAUSE

:: If launcher_version is blank, update it with the GitHub datetime
IF "%launcher_version%"=="" (
    CALL :SET_FILE_VALUE "%settings%" "launcher_version" "%github_last_commit_parsed%"
    IF "%debug%"=="0" ECHO Debug: No Launcher Version detected, settings Launcher Version = "%launcher_version%" & ECHO. & PAUSE
    SET "launcher_version=%github_last_commit_parsed%"
)

:: Debugging output
IF "%debug%"=="0" (
    ECHO.
    ECHO Debug: Current launcher_version = "%launcher_version%"
    PAUSE
    ECHO Debug: GitHub last commit datetime = "%github_last_commit_parsed%"
    PAUSE
)

:: Compare last GitHub commit datetime with launcher_version
:: If launcher version is older, prompt the user to update
IF "%github_last_commit_parsed%" GTR "%launcher_version%" (
    ECHO The launcher has some juicy upgrades available...
    ECHO.
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET /P "update_choice=Would you like to update the launcher now? (Y/N): "
    IF /I "!update_choice!"=="Y" (
        ENDLOCAL
        ECHO.
        GOTO PERFORM_LAUNCHER_UPDATE
    ) ELSE IF /I "!update_choice!"=="N" (
        ENDLOCAL
        CALL :ERROR_HANDLER "Skipping update..." MAIN_MENU
    ) ELSE (
        ENDLOCAL
        CALL :ERROR_HANDLER "Invalid choice. Please enter Y or N." UPDATE_LAUNCHER_CHECK
    )
) ELSE (
    :: No updates available, proceed to main menu
    ECHO Launcher still Best In Slot...
    ECHO.
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Update Launcher Check
IF "%debug%"=="0" ECHO Exiting UPDATE_LAUNCHER_CHECK... & ECHO. & PAUSE

TIMEOUT /T 2 >nul
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:PERFORM_LAUNCHER_UPDATE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Update the launcher by downloading the latest version from GitHub
IF "%debug%"=="0" ECHO Entering PERFORM_LAUNCHER_UPDATE... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO Fetching Deckard Cain, sit tight...
ECHO.
TIMEOUT /T 2 >nul

SET "utils_launcher_dir=%launcher%\utils\Updates"

:: Clean the Updates folder before checking for updates
IF EXIST "%utils_launcher_dir%" (
    RMDIR /S /Q "%utils_launcher_dir%" >nul 2>&1
    MD "%utils_launcher_dir%" >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Failed to clear or recreate the utils_launcher_dir. Please check permissions or the path." MAIN_MENU
    )
)
TIMEOUT /T 2 >nul

:: Define the GitHub URL for the latest release
SET "github_latest_release_url=https://github.com/Vingelis/Reimagined-BETA-Launcher/archive/refs/heads/main.zip"

:: Download the updated launcher zip file
ECHO Pouring over the sacred Github Texts...
ECHO.
curl -s -L -o "%temp_zip%" "%github_latest_release_url%" >nul 2>&1
IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Failed to download the updated launcher files. Please check your internet connection or the GitHub URL." MAIN_MENU
)
TIMEOUT /T 2 >nul

:: Check if the download was successful
IF NOT EXIST "%temp_zip%" (
    CALL :ERROR_HANDLER "Failed to download the updated launcher files. Please check your internet connection or the GitHub URL." MAIN_MENU
)

:: Extract the downloaded zip file
ECHO Decyphering runes with Akara...
ECHO.
powershell -Command "Expand-Archive -Path '%temp_zip%' -DestinationPath '%temp_folder%' -Force" >nul 2>&1
IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Failed to extract the updated launcher files. Please ensure PowerShell is available and try again." MAIN_MENU
)
TIMEOUT /T 2 >nul

:: Check if the extraction was successful
IF NOT EXIST "%temp_folder%" (
    CALL :ERROR_HANDLER "Failed to extract the updated launcher files. Please ensure PowerShell is available and try again." MAIN_MENU
)

:: Store new launcher version in temp file for later use
ECHO launcher_version=%github_last_commit_parsed% > "%new_launcher_version%"

:: Schedule the update script to run after the current script exits
ECHO Proceeding to update Horadric Cube recipes... Let Deckard do his thing...
ECHO.
PAUSE
CALL :UPDATE_LAUNCHER_SCRIPT

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Update Launcher Process
IF "%debug%"=="0" ECHO Exiting PERFORM_LAUNCHER_UPDATE ... & ECHO. & PAUSE

EXIT
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                  SUBROUTINES                                                      :
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:CHECK_7Z_FILES
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check for 7z files in the launcher folder
IF "%debug%"=="0" ECHO Entering CHECK_7Z_FILES... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "file_count=0"
SET "install_file="

:: Debugging: Check the launcher path
IF "%debug%"=="0" (
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
    CALL :ERROR_HANDLER "No Reimagined 7z file found in Launcher folder. Please download the latest version from Nexus Mods." MAIN_MENU
) ELSE IF %file_count% GTR 1 (
    CALL :ERROR_HANDLER "Multiple 7z files found in Launcher folder. Please ensure only one 7z file is present." INSTALL_UPDATE
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
IF "%debug%"=="0" (
    ECHO Debug: install_file="%install_file%"
    ECHO Debug: file_count="%file_count%"
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Check for 7z files
IF "%debug%"=="0" ECHO Entering CHECK_7Z_FILES... & ECHO. & PAUSE

EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:FIND_OR_CREATE_SAVE_DIR
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Search for the most recently updated "Reimagined" folder containing .d2s files, ignoring directories named "Backup"
IF "%debug%"=="0" ECHO Entering FIND_OR_CREATE_SAVE_DIR... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Finding save location
IF "%debug%"=="0" ECHO Checking if we have a custom save location & ECHO. & PAUSE
IF DEFINED custom_save IF "%custom_save%"=="1" (
    IF "%debug%"=="0" ECHO No custom save location, proceeding with FIND_OR_CREATE_SAVE_DIR & ECHO. & PAUSE
    ECHO Searching Sanctuary for worthy heroes...
    ECHO.
) ELSE (
    IF DEFINED save_location IF NOT "%save_location%"=="" (
        IF "%debug%"=="0" ECHO Found a custom save location, returning to initialisation & ECHO. & PAUSE
        ECHO Found heroes in the tavern...
        ECHO.
        TIMEOUT /T 2 >nul
        EXIT /B
    )
)

:: Recursively search for the most recently updated "Reimagined" folder containing .d2s files
FOR /F "tokens=*" %%A IN ('powershell -Command "Get-ChildItem -Path $env:USERPROFILE -Recurse -Directory -Filter 'Reimagined' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\Backup(\\|$)' -and (Get-ChildItem -Path $_.FullName -Filter '*.d2s' -File -ErrorAction SilentlyContinue).Count -gt 0 } | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"') DO (
    SET "save_location=%%A"
)

:: Debugging output
IF "%debug%"=="0" ECHO Debug: Save Location in FIND_OR_CREATE_SAVE_DIR = "%save_location%" & ECHO. & PAUSE

:: Couldn't find any .d2s files, so create a backup directory in the most likely place
IF "%save_location%"=="" (
    ECHO Creating a safe haven for your heroes...
    MD "%USERPROFILE%\Saved Games\Diablo II Resurrected\mods\Reimagined" >nul 2>&1
    SET "save_location=%USERPROFILE%\Saved Games\Diablo II Resurrected\mods\Reimagined"
    :: Unable to create the directory, so prompt the user for a manual location
    IF "%save_location%"=="" (
        CALL :ERROR_HANDLER "Error: Failed to create a Saved Games directory."
        ECHO.
        SET /P "manual_choice=Would you like to manually define one? (Y/N): "
        IF /I "%manual_choice%"=="Y" (
            SET /P "usersavelocation=Enter the full path to your preferred directory: "
            IF NOT EXIST "%usersavelocation%" (
                CALL :ERROR_HANDLER "Error: The specified directory does not exist. Please check the path." FIND_OR_CREATE_SAVE_DIR
            )
            SET "save_location=%usersavelocation%"
        ) ELSE (
            CALL :ERROR_HANDLER "No valid Saved Games directory found. Let's try again..." FIND_OR_CREATE_SAVE_DIR
        )
    )
)

:: Find the parent directory of the Reimagined folder
:: e.g. "C:\Users\YourName\Saved Games\Diablo II Resurrected\mods\Reimagined\" becomes "C:\Users\YourName\Saved Games\Diablo II Resurrected\mods\"
FOR %%I IN ("%save_location%") DO SET "d2r_mod_saves=%%~dpI"
:: Remove trailing backslash if it exists to make the path cleaner
IF "%d2r_mod_saves:~-1%"=="\" SET "d2r_mod_saves=%d2r_mod_saves:~0,-1%"

:: Ensure the path exists
IF NOT EXIST "%d2r_mod_saves%" (
    CALL :ERROR_HANDLER "Error: Failed to find or create a Saved Games directory. You can manually define one under the Configuration Menu." MAIN_MENU
)

:: Debugging output
IF "%debug%"=="0" ECHO. & ECHO Debug: Trimmed Saved Games Directory = "%d2r_mod_saves%" & ECHO. & PAUSE

::CALL :GET_FILE_VALUE "%settings%" "custom_save" custom_save
::IF "%debug%"=="0" ECHO Debug: Getting custom save settings: "%custom_save%" & ECHO. & PAUSE
::IF "%custom_save%"=="1" CALL :SET_FILE_VALUE "%settings%" "save_location" "%save_location%"
CALL :SET_FILE_VALUE "%settings%" "save_location" "%save_location%"
IF "%debug%"=="0" ECHO Debug: Setting new save location = "%save_location%" & ECHO. & PAUSE

ECHO Found some heroes, getting them back to town...
ECHO.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Locate Saved Games Directory
IF "%debug%"=="0" ECHO Exiting FIND_OR_CREATE_SAVE_DIR... & ECHO. & PAUSE

TIMEOUT /T 2 >nul
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:FIND_OR_CREATE_BACKUP_DIR
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Find or create the backup directory
IF "%debug%"=="0" ECHO Entering FIND_OR_CREATE_BACKUP_DIR... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF "%debug%"=="0" ECHO Check if we have a custom backup location & ECHO. & PAUSE
IF DEFINED custom_backup IF "%custom_backup%"=="1" (
    IF "%debug%"=="0" ECHO No custom backup location, proceeding with FIND_OR_CREATE_BACKUP_DIR & ECHO. & PAUSE
    ECHO Locating a safe haven for your heroes...
    ECHO.
) ELSE (
    IF DEFINED backup_location IF NOT "%backup_location%"=="" (
        IF "%debug%"=="0" ECHO Found a custom backup location, returning to initialisation & ECHO. & PAUSE
        ECHO Furnishing the hideout...
        ECHO.
        TIMEOUT /T 2 >nul
        EXIT /B
    )
)

IF "%backup_location%"=="" (
    IF "%debug%"=="0" ECHO Debug: No Backup Location set in settings & ECHO. & PAUSE
    IF NOT EXIST "%d2r_mod_saves%\Reimagined Backups" (
        IF "%debug%"=="0" ECHO Debug: No Backup folder exists, creating a new one & ECHO. & PAUSE
        MD "%d2r_mod_saves%\Reimagined Backups" >nul 2>&1
        IF ERRORLEVEL 1 (
            CALL :ERROR_HANDLER "Failed to create backup directory in '%d2r_mod_saves%'. Please check permissions or the path." FIND_OR_CREATE_SAVE_DIR
        )
    )
    SET "backup_location=%d2r_mod_saves%\Reimagined Backups"
)

:: Debugging output
IF "%debug%"=="0" ECHO. & ECHO Debug: backup location = "%backup_location%" & ECHO. & PAUSE

::CALL :GET_FILE_VALUE "%settings%" "custom_backup" custom_backup
::IF "%debug%"=="0" ECHO Debug: Getting custom backup settings: "%custom_backup%" & ECHO. & PAUSE
::IF "%custom_backup%"=="1" CALL :SET_FILE_VALUE "%settings%" "backup_location" "%backup_location%"
CALL :SET_FILE_VALUE "%settings%" "backup_location" "%backup_location%"
IF "%debug%"=="0" ECHO Debug: Setting new backup location = "%backup_location%" & ECHO. & PAUSE

ECHO Hideout established, heroes can rest easy...
ECHO.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Find or Create Backup Directory
IF "%debug%"=="0" ECHO. & ECHO Exiting FIND_OR_CREATE_BACKUP_DIR... & ECHO. & PAUSE

TIMEOUT /T 2 >nul
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:VERIFY_D2R_INSTALL
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Verify the Resurrected folder and its contents
IF "%debug%"=="0" ECHO. & ECHO Entering VERIFY_D2R_INSTALL... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO Looking under the bed for the Dark Wanderer...
ECHO.

IF NOT DEFINED appdir (
    CALL :ERROR_HANDLER "Diablo II Resurrected is not installed or the registry key is missing. Please ensure a licenced version of the game is installed before trying again." EXIT
)
IF NOT EXIST "%appdir%\D2R.exe" (
    CALL :ERROR_HANDLER "D2R.exe not found in '%appdir%'. Please ensure Diablo II Resurrected is installed correctly." EXIT
)

ECHO No lurking nightmares found... This time...
ECHO.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Verify D2R Install
IF "%debug%"=="0" ECHO. & ECHO Exiting VERIFY_D2R_INSTALL... & ECHO. & PAUSE

TIMEOUT /T 2 >nul
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:VERIFY_REIMAGINED_FOLDER
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Verify the Reimagined folder and its contents
IF "%debug%"=="0" ECHO Entering VERIFY_REIMAGINED_FOLDER & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO Reimagining Diablo...
ECHO.

TIMEOUT /T 2 >nul

SET "mod_checked=1"  :: mod isn't considered installed until we check the folder
IF NOT EXIST "%appdir%\mods\Reimagined\" (
    CALL :ERROR_HANDLER "Looks like Reimagined isn't installed yet. Let's install the mod before proceeding further." INSTALL_UPDATE
) ELSE (
    DIR /B "%appdir%\mods\Reimagined" >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ERROR_HANDLER "Looks like Reimagined isn't installed yet. Let's install the mod before proceeding further." INSTALL_UPDATE
    )
)
:: Mod confirmed as installed and not empty
SET "mod_checked=0"

ECHO Diablo's looking good...
ECHO.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Verify Reimagined folder
IF "%debug%"=="0" ECHO Exiting VERIFY_REIMAGINED_FOLDER & ECHO. & PAUSE

TIMEOUT /T 2 >nul
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ERROR_HANDLER
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: %1 = Error message, %2 = EXIT (optional)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO.
ECHO %~1
ECHO.

IF NOT "%~2"=="" (
    PAUSE
    GOTO %~2
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Error Handler
PAUSE
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:COPY_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copy a single file from source to destination
:: %1 = Source, %2 = Destination
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

copy "%~1" "%~2" >nul 2>&1

IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Failed to copy file from '%~1' to '%~2'." EXIT
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Copy File
EXIT /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:COPY_FILES
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copy files and folders from source to destination
:: %1 = Source, %2 = Destination
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

xcopy /e /r /y "%~1" "%~2" >nul 2>&1

IF ERRORLEVEL 1 (
    CALL :ERROR_HANDLER "Failed to copy files from '%~1' to '%~2'." EXIT
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Copy Files
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OPEN_LINK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: %1 = URL
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

START "" "%~1"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Open Link
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:CREATE_CHECK_SETTINGS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Creates a settings.txt file if it doesn't exist with a pre-determined list of key-value pairs
IF "%debug%"=="0" ECHO Entering CREATE_CHECK_SETTINGS... & ECHO. & PAUSE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: If settings.txt doesn't exist, create it with default values
IF NOT EXIST "%launcher%\settings.txt" (
    SET "settings="
    ECHO.
    ECHO Oh greetings stranger, stay a while and listen...
    ECHO.
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET "settings=%launcher%\settings.txt"
    (
        ECHO launcher_version=
        ECHO launcher_auto_update=0
        ECHO mod_auto_update=0
        ECHO save_location=
        ECHO backup_location=
        ECHO backup_frequency=1
        ECHO backup_format=date
        ECHO custom_save=1
        ECHO custom_backup=1
        ECHO expanded_stash=1
        ECHO expanded_stash_rename=1
        ECHO shared_stash_tab_1=Shared
        ECHO shared_stash_tab_2=Shared
        ECHO shared_stash_tab_3=Shared
        ECHO shared_stash_tab_4=Shared
        ECHO shared_stash_tab_5=Shared
        ECHO shared_stash_tab_6=Shared
        ECHO shared_stash_tab_7=Shared
        ECHO forced_terror_zones=1
        ECHO splash_charm_graphic_removed=1
        ECHO increased_level_stats=1
        ECHO letterbox_removal=1
        ECHO casc_fastloading=1
    ) > "!settings!"
    ENDLOCAL & SET "settings=%launcher%\settings.txt"
    IF "%debug%"=="0" ECHO Created new settings file & ECHO. & PAUSE
) ELSE (
    SET "settings=%launcher%\settings.txt"
    ECHO.
    ECHO Welcome back hero...
    ECHO.
)

:: Get settings from file, set environment variables
CALL :GET_SET_SETTINGS "%settings%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Create Config File
IF "%debug%"=="0" ECHO Exiting CREATE_CHECK_SETTINGS... & ECHO. & PAUSE

TIMEOUT /T 2 >nul
EXIT /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:SET_FILE_VALUE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Updates or adds a key-value pair in a text file using PowerShell
:: %1 = File path (e.g., settings.txt)
:: %2 = Key to update (e.g., launcher_version)
:: %3 = Value to set (e.g., 20250406, or C:\Path\To\Your\Game)
IF "%debug%"=="0" ECHO Entering SET_FILE_VALUE... & ECHO. & PAUSE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Ensure the file exists, create it if it doesn't
IF NOT EXIST "%~1" (
    ECHO %~2=%~3>"%~1"
    SET "%~2=%~3"
    EXIT /B
)

:: Step 1: Check if the key exists
Powershell -NoProfile -Command "if ((Get-Content '%~1') -match '^\s*%~2\s*=') { exit 0 } else { exit 1 }"
IF ERRORLEVEL 1 (
    :: Step 2: Key does not exist, append it to the file
    Powershell -NoProfile -Command "Add-Content -Path '%~1' -Value '%~2=%~3'"
) ELSE (
    :: Step 3: Key exists, update it
    Powershell -NoProfile -Command "(Get-Content '%~1') -replace '^\s*%~2\s*=.*', '%~2=%~3' | Set-Content '%~1'"
)

:: Remove blank lines from the file
Powershell -NoProfile -Command "(Get-Content '%~1') | Where-Object { $_.Trim() -ne '' } | Set-Content '%~1'"

:: Set the global variable
SET "%~2=%~3"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Set File Value
IF "%debug%"=="0" ECHO Exiting SET_FILE_VALUE... & ECHO. & PAUSE

EXIT /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:GET_FILE_VALUE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get the value of a key-value pair from a text file using PowerShell
:: %1 = File path (e.g., settings.txt)
:: %2 = Key to search for (e.g., launcher_version)
:: %3 = Variable to store the result (e.g., launcher_version)
IF "%debug%"=="0" ECHO Entering GET_FILE_VALUE... & ECHO. & PAUSE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Clear the output variable to avoid retaining a previous value
SET "%~3="

:: Check if the file exists
IF NOT EXIST "%~1" (
    ECHO Error: File "%~1" does not exist.
    EXIT /B 1
)

:: Use PowerShell to retrieve the value of the specified key
FOR /F "usebackq tokens=*" %%A IN (`Powershell -NoProfile -Command "Select-String -Path '%~1' -Pattern '^\s*%~2\s*=' | ForEach-Object { ($_ -split '=', 2)[1].Trim() }"`) DO SET "%~3=%%A"

:: Debugging output
IF "%debug%"=="0" (
    IF DEFINED %~3 (
        ECHO Found key %~2 in file %~1 with value "%~3" & ECHO. & PAUSE
    ) ELSE (
        ECHO Key %~2 not found in file %~1 & ECHO. & PAUSE
    )
)

:: If the variable is not set, the key was not found
IF NOT DEFINED %~3 (
    ECHO Error: Key "%~2" not found in file "%~1".
    EXIT /B 1
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Get File Value
IF "%debug%"=="0" ECHO Exiting GET_FILE_VALUE... & ECHO. & PAUSE

EXIT /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:GET_SET_SETTINGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get settings from a text file and set each as an environment variable for the current session
:: %1 = File path (e.g., settings.txt)
IF "%debug%"=="0" ECHO Entering GET_SET_SETTINGS... & ECHO. & PAUSE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check if the file exists
IF NOT EXIST "%~1" (
    ECHO Error: File "%~1" does not exist.
    EXIT /B 1
)

:: Read each line from the file and set each key-value pair as an environment variable
FOR /F "tokens=1,2 delims==" %%A IN ('FINDSTR "=" "%~1"') DO (
    SET "%%A=%%B"
    IF "%debug%"=="0" ECHO Setting new variable: %%A = %%B
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Get and Set Settings
IF "%debug%"=="0" ECHO Exiting GET_SET_SETTINGS... & ECHO. & PAUSE

EXIT /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DISPLAY_SETTINGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get settings from a text file and output them as readable key-value pairs
:: %1 = File path (e.g., settings.txt)
IF "%debug%"=="0" ECHO Entering DISPLAY_SETTINGS... & ECHO. & PAUSE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check if the file exists
IF NOT EXIST "%~1" (
    ECHO Error: File "%~1" does not exist.
    EXIT /B 1
)

:: Read each line from the file and output key-value pairs in a readable format
FOR /F "tokens=1,2 delims==" %%A IN ('FINDSTR "=" "%~1"') DO (
    ECHO %%A = %%B
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Display Settings
IF "%debug%"=="0" ECHO Exiting DISPLAY_SETTINGS... & ECHO. & PAUSE

EXIT /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of subroutines
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:UPDATE_LAUNCHER_SCRIPT
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Create a temporary script that performs the launcher update, and deletes itself when finished
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "temp_update_script=%launcher%\utils\Updates\update_launcher.bat"
(
    ECHO @ECHO OFF
    ECHO ECHO.
    ECHO ECHO Summoning Update Wizard...
    ECHO ECHO.
    ECHO ECHO TIMEOUT /T 2 >nul

    :: Define paths
    :: Launcher update utility files
    ECHO SET "utils_launcher_dir=%~dp0"
    ECHO SET "temp_folder=%utils_launcher_dir%\Launcher_Update"
    ECHO SET "temp_zip=%utils_launcher_dir%\Launcher_Update.zip"
    ECHO SET "version_file=%utils_launcher_dir%\launcher_version.txt"

    :: Launcher files
    ECHO SET "launcher_dir=%~dp0..\.."
    ECHO SET "settings_file=%launcher_dir%\settings.txt"
    ECHO SET "beta_launcher_file=%launcher_dir%\BETA Launcher.bat"

    :: Ensure the main launcher script is no longer running
    ECHO :WAIT_FOR_LAUNCHER_EXIT
    ECHO TASKLIST | FIND /I "BETA Launcher.bat" >nul
    ECHO IF NOT ERRORLEVEL 1 (
    ECHO     TIMEOUT /T 2 >nul
    ECHO     GOTO WAIT_FOR_LAUNCHER_EXIT
    ECHO )

    :: Check if the update files exist
    ECHO IF NOT EXIST "%temp_zip%" (
    ECHO     ECHO Error: Update package not found. Aborting update.
    ECHO     PAUSE
    ECHO     EXIT /B 1
    ECHO )

    ECHO IF NOT EXIST "%temp_folder%" (
    ECHO     ECHO Error: Extracted update folder not found. Aborting update.
    ECHO     PAUSE
    ECHO     EXIT /B 1
    ECHO )

    :: Apply the update by copying files
    ECHO ECHO Reciting the update incantation... 
    ECHO ECHO.
    :: Delete the old BETA Launcher.bat file if it exists
    ECHO IF EXIST "%beta_launcher_file%" (
    ECHO     DEL /Q "%beta_launcher_file%"
    ECHO     IF ERRORLEVEL 1 (
    ECHO         ECHO Error: Failed to delete old BETA Launcher.bat. Please check file permissions and try again.
    ECHO         PAUSE
    ECHO         EXIT /B 1
    ECHO     )
    ECHO )
    ECHO TIMEOUT /T 2 >nul
    ECHO XCOPY "%temp_folder%\Reimagined-BETA-Launcher-main\*" "%launcher_dir%\" /E /H /C /Y >nul 2>&1
    ECHO IF ERRORLEVEL 1 (
    ECHO     ECHO Error: Failed to update launcher files. Please check file permissions and try again.
    ECHO     PAUSE
    ECHO     EXIT /B 1
    ECHO )
    ECHO TIMEOUT /T 2 >nul

    :: Update launcher_version in settings.txt
    ECHO IF EXIST "%version_file%" (
    ECHO     FOR /F "tokens=*" %%A IN ('TYPE "%version_file%"') DO SET "new_version=%%A"
    ECHO     IF NOT DEFINED new_version (
    ECHO         ECHO Error: Failed to read launcher version from "%version_file%".
    ECHO         PAUSE
    ECHO         EXIT /B 1
    ECHO     )
    ECHO     ECHO Transmuting Horadric Cube...
    ECHO     ECHO.
    ECHO     Powershell -NoProfile -Command "(Get-Content '%settings_file%') -replace '^\s*launcher_version\s*=.*', 'launcher_version=%new_version%' | Set-Content '%settings_file%'"
    ECHO     IF ERRORLEVEL 1 (
    ECHO         ECHO Error: Failed to update launcher_version in settings.txt.
    ECHO         PAUSE
    ECHO         EXIT /B 1
    ECHO     )
    ECHO     ECHO Transmutation successful...
    ECHO     ECHO.
    ECHO ) ELSE (
    ECHO     ECHO Error: Version file "%version_file%" not found. Skipping version update.
    ECHO     ECHO.
    ECHO )
    ECHO TIMEOUT /T 2 >nul

    :: Clean up temporary files
    ECHO ECHO Now to clean up the Cube...
    ECHO ECHO.

    :: Delete temporary files and folders
    ECHO IF EXIST "%temp_zip%" DEL /Q "%temp_zip%"
    ECHO IF EXIST "%temp_folder%" RMDIR /S /Q "%temp_folder%"
    ECHO IF EXIST "%version_file%" DEL /Q "%version_file%"
    ECHO TIMEOUT /T 2 >nul

    :: Verify cleanup success
    ECHO FOR %%F IN ("%temp_zip%" "%temp_folder%" "%version_file%") DO (
    ECHO     IF EXIST %%F (
    ECHO         ECHO Error: Failed to delete %%F. Please check file permissions and try again.
    ECHO         PAUSE
    ECHO         EXIT /B 1
    ECHO     )
    ECHO )

    ECHO ECHO Cube has been emptied of its contents...
    ECHO ECHO.
    ECHO TIMEOUT /T 2 >nul

    :: Confirm update success
    ECHO ECHO Looks like everything went well...
    ECHO ECHO.
    ECHO ECHO Restarting the launcher...
    ECHO ECHO.
    ECHO TIMEOUT /T 2 >nul

    :: Restart the launcher
    ECHO PUSHD "%launcher_dir%"
    ECHO START "" "BETA Launcher.bat"
    ECHO POPD

    ECHO EXIT & DEL /Q "%temp_update_script%"
    ECHO IF ERRORLEVEL 1 (
    ECHO     ECHO Warning: Failed to delete temporary script "%temp_update_script%". Please delete it manually.
    ECHO )
) > "%temp_update_script%"

START "" "%temp_update_script%"
EXIT /B

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of Update Launcher Script
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of script
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::