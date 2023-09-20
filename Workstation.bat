@ECHO OFF

setlocal enabledelayedexpansion

:: Set SCRIPT_NAME to the name of this batch file script
	set THIS_VERSION=1.0.a001

:: Set SCRIPT_NAME to the name of this batch file script
	set SCRIPT_NAME=Workstation

:: Set GH_USER_NAME to your GitHub username here
	set GH_USER_NAME=KSanders7070

:: Set GH_REPO_NAME to your GitHub repository name here
	set GH_REPO_NAME=Workstation


:: TODO add version check code prior to release here
:RestOfCode

:HELLO
	:: TODO ask the user what they want to do.

:AppDirChk
	:: Checks if the WorkstationBatch AppData directory for this batch script exists.
	:: If not, its likely the first time running and goes to the setup function.
	set "BatchAppDataDir=%LocalAppdata%\WorkstationBatch"
	if not exist "!BatchAppDataDir!" call :InitialSetup

:InitiateVariables
	:: Set initial values for variables
	set "COMMON_NAME=NOT_YET_SET"
	set "PROGRAM_TYPE=NOT_YET_SET"
	set "FULL_FILE_PATH=NOT_YET_SET"
	set "URL=NOT_YET_SET"
	
:ValidateConfigFileData
	:: Read the CSV file and ensure the data makes sense.
	:: Skip the first line, as the first line only provides the user with header information when editing the file.
	for /f "skip=1 tokens=1-4 delims=," %%a in (Workstation_Config.csv) do (
		set "COMMON_NAME=%%a"
		set "PROGRAM_TYPE=%%b"
		set "FULL_FILE_PATH=%%c"
		set "URL=%%d"
	
		:: Check COMMON_NAME
		if "!COMMON_NAME!"=="" (
			call :COMMON_NAME_NUL
		)
	
		:: Check PROGRAM_TYPE
		if not /i "!PROGRAM_TYPE!"=="PROGRAM" (
			if not /i "!PROGRAM_TYPE!"=="WEBSITE" (
				call :PROGRAM_TYPE_NOT_VALID
			)
		)
	
		:: Check FULL_FILE_PATH if PROGRAM_TYPE is PROGRAM
		if /i "!PROGRAM_TYPE!"=="PROGRAM" (
			if "!FULL_FILE_PATH!"=="" (
				call :FULL_FILE_PATH_NOT_VALID
			) else (
				if not exist "!FULL_FILE_PATH!" (
					call :FULL_FILE_PATH_NOT_FOUND
				)
			)
		)
	
		:: Check URL if PROGRAM_TYPE is WEBSITE
		if /i "!PROGRAM_TYPE_LOWERCASE!"=="WEBSITE" (
			if "!URL!"=="" (
				call :URL_NOT_NUL
			) else (
				:: TODO Find a way to make sure this is a valid website URL. Consider a slient CURL with a errorlevel check.
			)
		)
	)
ECHO DONE with Config File validation.
PAUSE

:LaunchWorkstation
	:: TODO Begin the process again. Basically the same as above but now we actually start the data and no error checking is required.



ECHO DONE.
PAUSE

EXIT

:CallFunctions

:InitialSetup
	:: Creates a directory for this BATCH file to host data in like the config file and preferences.
	md "!BatchAppDataDir!"
	
	:: Creates a Config file for the user to be able to edit.
	(
		echo Common Name,Type program/website,Full File Path,URL
		echo GOOGLE SITE,WEBSITE,,WWW.GOOGLE.COM
		echo NOAA SITE,WEBSITE,,WWW.NOAA.GOV
		echo vATIS,PROGRAM,%%LocalAppdata%%\vATIS-4.0\Application\vATIS.exe,
		echo AFV,PROGRAM,C:\AudioForVATSIM\AudioForVATSIM.exe,
		echo CRC,PROGRAM,%%LocalAppdata%%\CRC\Application\CRC.exe --debug,
	)>"!BatchAppDataDir!\Workstation_Config.csv"
	
	echo.
	echo.
	echo A configuration file has been created for you here:
	echo 	!BatchAppDataDir!\Workstation_Config.csv
	echo.
	echo 	This file is where this script gets the information about what programs or websites
	echo 	to open and is formatted as a .CSV.
	echo.	
	echo 	If you are familiar with .csv files and comfortable editing them, feel free to edit
	echo 	the file directly in a text editor;
	echo 	If not, open it in a spreadsheet program such as Excel and edit it there.
	echo.	
	echo 	The format of the values is pretty self-explanatory but if you have issues, reach out to the developer.
	echo.
	echo.
	echo Press any key to open the directory where the Workstation_Config.csv is and this CMD Prompt window will close.
	echo 	When done editing this file, feel free to restart this BATCH file.
	
	pause>nul
	
	START /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	exit

:COMMON_NAME_NUL
	:: TODO Finish this error screen.
	echo COMMON_NAME is null or has no value.
	PAUSE
	EXIT
	
:PROGRAM_TYPE_NOT_VALID
	:: TODO Finish this error screen.
	echo PROGRAM_TYPE is not valid.
	PAUSE
	EXIT
	
:FULL_FILE_PATH_NOT_VALID
	:: TODO Finish this error screen.
	echo FULL_FILE_PATH is null or has no value, but PROGRAM_TYPE is PROGRAM.
	PAUSE
	EXIT
	
:FULL_FILE_PATH_NOT_FOUND
	:: TODO Finish this error screen.
	echo FULL_FILE_PATH does not exist.
	PAUSE
	EXIT
	
:URL_NOT_NUL
	:: TODO Finish this error screen.
	echo URL is null or has no value, but PROGRAM_TYPE is WEBSITE.
	PAUSE
	EXIT








pause

exit





















































