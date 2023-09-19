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


:DIRSETUP
	
	cls
	
	set "BatchAppDataDir=%LocalAppdata%\WorkstationBatch"
	if not exist "!BatchAppDataDir!" call :InitialSetup
	
	
	cd /d "!BatchAppDataDir!"



:CallFunctions

:InitialSetup
	
	:: Creates a directory for this BATCH file to host data in like the config file and preferences.
	md "!BatchAppDataDir!"
	
	:: Creates a Config file for the user to be able to edit.
	(
		echo Common Name,Type (program/website),PATH,URL
		echo GOOGLE SITE,WEBSITE,,WWW.GOOGLE.COM
		echo NOAA SITE,WEBSITE,,WWW.NOAA.GOV
		echo vATIS,PROGRAM,%LocalAppdata%\vATIS-4.0\Application\vATIS.exe,
		echo AFV,PROGRAM,C:\AudioForVATSIM\AudioForVATSIM.exe,
		echo CRC,PROGRAM,%LocalAppdata%\CRC\Application\CRC.exe --debug,

	)>Workstation_Config.csv












pause

exit





















































