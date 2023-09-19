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
	if not exist "!BatchAppDataDir!" md "!BatchAppDataDir!"
	
	cd /d "!BatchAppDataDir!"























pause

exit





















































