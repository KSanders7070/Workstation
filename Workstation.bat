@ECHO OFF
setlocal enabledelayedexpansion

	:: Set THIS_VERSION to the version of this batch file script
	set "THIS_VERSION=2.0.b03"
	
	REM Set SCRIPT_NAME to the name of this batch file script
	set "SCRIPT_NAME=Workstation"
	
	REM Set GH_USER_NAME to your GitHub username here
	set "GH_USER_NAME=KSanders7070"
	
	REM Set GH_REPO_NAME to your GitHub repository name here
	set "GH_REPO_NAME=Workstation"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

TITLE !SCRIPT_NAME! (v!THIS_VERSION!)

:SetUpTempDir

	:: Setting up the Temp Directory
	CD /D "%temp%"
		IF exist "!GH_REPO_NAME!-UDPATE" RD /S /Q "!GH_REPO_NAME!-UDPATE"
		MD "!GH_REPO_NAME!-UDPATE"
		
	CD /D "!GH_REPO_NAME!-UDPATE"

:GetLatestVerNum

	:: URL to fetch JSON data from GitHub API
	set "GH_LATEST_RLS_PAGE=https://api.github.com/repos/!GH_USER_NAME!/!GH_REPO_NAME!/releases/latest"
	::                      https://api.github.com/repos/KSanders7070/AUTO_UPDATE_BATCH_FILE/releases/latest
		set "URL_TO_DOWNLOAD=!GH_LATEST_RLS_PAGE!"
	set "LATEST_VERSION="
	
	:RedirectLooop

		if exist response.json del /Q response.json
		
		:: Use CURL to download the JSON data
		curl -s -o response.json !URL_TO_DOWNLOAD!
		
			if not exist "response.json" (
			
			ECHO.
			ECHO.
			ECHO -------
			ECHO  ERROR
			ECHO -------
			ECHO.
			ECHO Something went wrong with downloading the latest release information.
			ECHO.
			ECHO.
			ECHO Press any key to continue with this version of the batch file or
			ECHO just close this window...
			ECHO NOTE-I will open the releases page for you to see if there is a newer version.
			
			PAUSE>NUL
			START "" "!GH_LATEST_RLS_PAGE!"
			GOTO UpdateCleanUp
			)
		
		::Check if "exceeded" is present in the JSON, if so it likely means the API Call limit has been reached.
		findstr /C:"exceeded" response.json
			if "%errorlevel%"=="0" (
				ECHO.
				ECHO.
				ECHO -------
				ECHO  ERROR
				ECHO -------
				ECHO.
				ECHO While trying to get the latest version number for this batch file from GitHub,
				ECHO I found that the number of requests has been exceeded.
				ECHO You can try again in a while.
				ECHO.
				ECHO.
				ECHO Press any key to continue with this version of the batch file or
				ECHO just close this window...
				ECHO NOTE-I will open the releases page for you to see if there is a newer version.
				
				PAUSE>NUL
				START "" "!GH_LATEST_RLS_PAGE!"
				GOTO UpdateCleanUp
			)
				
		:: Check if "tag_name" is present in the JSON.
		findstr /C:"tag_name" response.json
			if "%errorlevel%"=="0" (
				:: tag_name Found in file which means there was no redirect or this is the final redirect
				:: page and has the version number on it.
				:: Extract the text between the second set of quotes and remove the first character (usually a lower case v).
				for /f "tokens=2 delims=:" %%a in ('findstr /C:"tag_name" response.json') do (
					set "LATEST_VERSION=%%~a"
					set "LATEST_VERSION=!LATEST_VERSION:~3,-2!"
				)
			) else (
				:: tag_name was not found which means that this is likely a redirect page.
				:: Extract the line that has "https://api." and grab the URL between the second set of quotes.
				:: Feed this URL back through the loop to see if this one redirects too. If it does, keep following until tag_name is found.
				for /f "tokens=1,* delims=" %%a in ('findstr /C:"https://api." response.json') do (
					set "URL_TO_DOWNLOAD=%%~a"
					set "URL_TO_DOWNLOAD=!URL_TO_DOWNLOAD:~10,-2!"
				)
				goto RedirectLooop
			)

:DoYouHaveLatest
	
	:: If the current version matches the latest version available, contine on with normal code.
	if /i "!THIS_VERSION!"=="!LATEST_VERSION!" goto UpdateCleanUp

:UpdateAvailablePrompt

	cls
	
	ECHO.
	ECHO.
	ECHO * * * * * * * * * * * * *
	ECHO     UPDATE AVAILABLE
	ECHO * * * * * * * * * * * * *
	ECHO.
	ECHO.
	ECHO GITHUB VERSION: !LATEST_VERSION!
	ECHO YOUR VERSION:   !THIS_VERSION!
	ECHO.
	ECHO.
	ECHO.
	ECHO  CHOICES:
	ECHO.
	ECHO     U   -   MANUALLY DOWNLOAD THE NEWEST BATCH FILE UPDATE AND USE THAT FILE.
	ECHO.
	ECHO     C   -   CONTINUE USING THIS FILE.
	ECHO.
	ECHO.
	ECHO.

	SET UPDATE_CHOICE=NO_CHOICE_MADE

	SET /p UPDATE_CHOICE=Please type either M, or C and press Enter: 
		if /I %UPDATE_CHOICE%==U GOTO UPDATE
		if /I %UPDATE_CHOICE%==C GOTO UpdateCleanUp
		if /I %UPDATE_CHOICE%==NO_CHOICE_MADE GOTO UpdateAvailablePrompt
	
:UPDATE
	
	set GH_LATEST_RLS_PAGE=https://github.com/!GH_USER_NAME!/!GH_REPO_NAME!/releases/latest
	
	CLS
	
	START "" "!GH_LATEST_RLS_PAGE!"
	
	ECHO.
	ECHO.
	ECHO GO TO THE FOLLOWING WEBSITE, DOWNLOAD AND USE THE LATEST VERSION OF %~nx0
	ECHO.
	ECHO    !GH_LATEST_RLS_PAGE!
	ECHO.
	ECHO Press any key to exit...
	
	pause>nul
	
	exit

:UpdateCleanUp

	cls
	
	CD /D "%temp%"
		IF exist "!GH_REPO_NAME!-UDPATE" RD /S /Q "!GH_REPO_NAME!-UDPATE"
	
	:: Ensures the directory is back to where this batch file is hosted.
	CD /D "%~dp0"

:RestOfCode

:HELLO

	REM sets the variable to this BATCH file LocalAppData directory.
	REM At this point, it has not been created if this is the first time running the script.
	set "BatchAppDataDir=%LocalAppdata%\WorkstationBatch"

	cls

	echo.
	echo.
	echo  WHAT WOULD YOU LIKE TO DO?
	echo.
	echo.
	echo      C) CHECK FOR AN UPDATE.
	echo.
	echo              -You are currently running v!THIS_VERSION!.
	echo.
	echo              -This option will open the GitHub releases page for this program allowing you to
	echo               download the latest version. If you download another version of this BATCH files,
	echo               simply delete this file and run the new one.
	echo.
	echo.
	echo      H) HELP.
	echo.
	echo              -Option to reset this BATCH file like new.
	echo.
	echo              -Option to Edit the configuration file.
	echo.
	echo.
	echo To start up all of your pre-defined programs/websites, just hit your enter key.
	echo.
	echo.
	
	set WHAT_T0_DO_CHOICE=NO_INPUT_BY_USER
	
	set /P WHAT_T0_DO_CHOICE=Type associated letter option and press Enter, or just press Enter: 
		if /i "!WHAT_T0_DO_CHOICE!"=="C" GOTO CHECKUPDATE
		if /i "!WHAT_T0_DO_CHOICE!"=="H" GOTO HELP
		if /i "!WHAT_T0_DO_CHOICE!"=="NO_INPUT_BY_USER" GOTO AppDirChk
		
		echo.
		echo  *** !WHAT_T0_DO_CHOICE! *** is NOT a recognized response. Try again...
		echo.
		echo Press any key to try again...
		
		pause>nul
		
		goto HELLO

:CHECKUPDATE

	START "" https://github.com/!GH_USER_NAME!/!GH_REPO_NAME!/releases/

	GOTO HELLO

:AppDirChk
	REM Checks if the WorkstationBatch AppData directory for this batch script exists.
	REM If not, it's likely the first time running and goes to the setup function.
	if not exist "!BatchAppDataDir!" call :InitialSetup

:InitiateVariables
	REM Set initial values for variables
	set "NAME=NOT_YET_SET"
	set "TYPE=NOT_YET_SET"
	set "FULL_PATH=NOT_YET_SET"
	set "URL=NOT_YET_SET"
	set "RunWithoutElevatedPermissions=NOT_YET_SET"

:ValidateConfigFileData
	REM Read the CSV file and ensure the data makes sense.
	
	cls
	
	echo.
	echo.
	echo Checking your Workstation_Config.csv for errors...
	echo.
	
	cd /d "!BatchAppDataDir!"
	
	REM Skip the first line, as the first line only provides the user with header information when editing the file.
	REM Then investigate the values of each line.
	for /f "skip=1 tokens=1-6 delims=," %%a in (Workstation_Config.csv) do (
		
		REM These variables can only be used for IF comparison commands outside of this loop such as calling a function
		REM That is why you will see the %%@ being used within this for loop.
		set NAME=%%a
		set TYPE=%%b
		set URL=%%c
		set FULL_PATH=%%d
		set FILE_ARGS=%%e
		set RunWithoutElevatedPermissions=%%f
		
		REM See if any values return NUL, if so display an error to the user.
		set ThereIsANulField=false
		Set /a COUNT=0
			if "%%a"=="" set ThereIsANulField=true
			if "%%b"=="" set ThereIsANulField=true
			if "%%c"=="" set ThereIsANulField=true
			if "%%d"=="" set ThereIsANulField=true
			if "%%e"=="" set ThereIsANulField=true
			if "%%f"=="" set ThereIsANulField=true
			if not "!ThereIsANulField!"=="false" call :ConfigHasNulValues
	
		REM Check NAME and if it is "NA", then have the user change it.
		if "%%a"=="NA" (
			call :NAME_IS_NA
		)
	
		REM if TYPE is not "PROGRAM"...
		if /i not "%%b"=="PROGRAM" (
			REM ...and it isn't "WEBSITE" then there is an issue.
			if /i not "%%b"=="WEBSITE" call :TYPE_NOT_VALID
		)
	
		REM if TYPE is "PROGRAM"...
		if /i "%%b"=="PROGRAM" (
			REM ...And the FULL_PATH is NA, there is an issue.
			if "%%d"=="NA" call :FULL_PATH_IS_NA
			
			REM Check to see if the FULL_PATH is found, if not we have issues...
			if not exist "%%d" call :FULL_PATH_NOT_FOUND
		)

		REM if TYPE is "WEBSITE"...
		if /i "%%b"=="WEBSITE" (
			REM ...And the URL is NA, there is an issue.
			if "%%c"=="NA" call :URL_IS_NA
		)
		
		REM DEV NOTE: I have decide not to a validation on the URL prior to running the full script.

		echo.
		echo Passed:
		echo 	NAME: 			%%a
		echo 	TYPE:			%%b
		echo 	URL:			%%c
		echo 	FULL_PATH:		%%d
		echo 	FILE_ARGS:		%%e
		echo 	W/O Elv Perms:		%%f
	)

	echo.
	echo.
	echo Config File validated.
	echo 	Note-URLs are not checked for validitiy except for making sure it is not NA when TYPE=WEBSITE.
	echo.
	echo.
	echo.
	echo.
	echo.
	echo.

:LaunchWorkstation
	REM TODO Begin the process again. Basically the same as above but now we actually start the data, and no error checking is required.
	echo.
	echo.
	echo LAUNCHING WEBSITES AND PROGRAMS...
	
	for /f "skip=1 tokens=1-6 delims=," %%a in (Workstation_Config.csv) do (
		REM These variables can only be used for IF comparison commands outside of this loop such as calling a function
		REM That is why you will see the %%@ being used within this for loop.
		set NAME=%%a
		set TYPE=%%b
		set URL=%%c
		set FULL_PATH=%%d
		set FILE_ARGS=%%e
		set RunWithoutElevatedPermissions=%%f
		
		if "%%b"=="WEBSITE" (
			call :LAUNCH_WEBSITE
		)
		
		if "%%b"=="PROGRAM" (
			call :LAUNCH_PROGRAM
		)
	)

	echo.
	echo.
	echo All Websites and Programs should be launched.
	echo.
	echo.
	echo.
	echo Press any key to exit this batch file script...
	
	pause>nul
	
	exit

:CallFunctions

:LAUNCH_WEBSITE

	START "" "!URL!"
	
	goto :EOF

:LAUNCH_PROGRAM

	for %%F in ("!FULL_PATH!") do (
		set "DIRECTORY=%%~dpF"
		set "FILE_AND_EXTENSION=%%~nxF"
	)
	
	cd /d "!DIRECTORY!"

	if /i "!RunWithoutElevatedPermissions!"=="Y" (
		if /i not "!FILE_ARGS!"=="NA" (
			cmd /min /C "set __COMPAT_LAYER=RUNASINVOKER && start "" "!FILE_AND_EXTENSION!" !FILE_ARGS!"
		)
		
		if /i "!FILE_ARGS!"=="NA" (
			cmd /min /C "set __COMPAT_LAYER=RUNASINVOKER && start "" "!FILE_AND_EXTENSION!""
		)
	) else (
		if /i not "!FILE_ARGS!"=="NA" (
			start "" "!FILE_AND_EXTENSION!" !FILE_ARGS!
		)
		
		if /i "!FILE_ARGS!"=="NA" (
			start "" "!FILE_AND_EXTENSION!"
		)	
	)
	
	goto :EOF

:InitialSetup
	REM Creates a directory for this BATCH file to host data in like the config file and preferences.
	md "!BatchAppDataDir!"
	
	REM Creates an example Config file for the user to be able to edit.
	(
		ECHO NAME,TYPE,URL,FULL_PATH,FILE_ARGS,RunWithoutElevatedPermissions
		ECHO Pret-Duty Wx,WEBSITE,https://www.weather.gov/zlc/predutyweatherbriefing,NA,NA,NA
		ECHO Facility TAFs,WEBSITE,https://www.aviationweather.gov/taf/data?ids=KBIL+KBOI+KBZN+KSUN+KGPI+KGTF+KHLN+KIDA+KJAC+KTWF+KMSO+KOGD+KPIH+KPVU+KSLC,NA,NA,NA
		ECHO vSTRIPS,WEBSITE,https://virtualnas.net/vstrips,NA,NA,NA
		ECHO vTDLS,WEBSITE,https://virtualnas.net/vtdls,NA,NA,NA
		ECHO vATIS,PROGRAM,NA,%LocalAppdata%\vATIS-4.0\Application\vATIS.exe,NA,NA
		ECHO AFV,PROGRAM,NA,C:\AudioForVATSIM\AudioForVATSIM.exe,NA,Y
		ECHO CRC,PROGRAM,NA,%LocalAppdata%\CRC\Application\CRC.exe,NA,NA
		ECHO Discord,PROGRAM,NA,%LocalAppdata%\Discord\Update.exe,--processStart Discord.exe,NA
	)>"!BatchAppDataDir!\Workstation_Config.csv"
	
	(
		echo.
		echo.
		echo Thank you for using this Workstation Batch file.
		echo.
		echo It is meant to open all of your programs and websites that you want before getting to work on a project or playing
		echo a video game or anything that I can't think of right now.
		echo.
		echo In the same directory that you are viewing this .txt file is a Workstation_Config.csv Config file for this BATCH file.
		echo This file most likely needs to be edited by you so feel free to open it in a spreadsheet program such as Excel or edit
		echo it manually if you feel more comfortable with that.
		echo.
		echo.
		echo Column explanations:
		echo      Note-No field can be left blank. Please place an NA in a field that should be blank.
		echo.
		echo “NAME”
		echo --This is any name you want to give the program and will only be used to help identify this program later if there is a problem.
		echo --Please try to avoid special characters. 
		echo --This cannot be "NA".
		echo.
		echo “TYPE”
		echo --This can only be “PROGRAM” or “WEBSITE” without the quotes.
		echo ----If you can double click a file and it runs, it is a PROGRAM.
		echo ----If it is something you visit in an internet web browser, it is a WEBSITE.
		echo.
		echo “URL”
		echo --The Web Address of the website you want to open in your default web browser.
		echo --If the TYPE is a PROGRAM, type NA here.
		echo.
		echo “FULL_PATH”
		echo --The directory where to find the file and including the file at the end.
		echo --Look at the examples provided in the .csv file for a better idea of what this is.
		echo --The easiest way to get this path is to right click on the shortcut of the program,
		echo   if you have a shortcut and copy/paste the data that is in the "TARGET" field.
		echo ---If you have anything like "--debug" after the extention, those are called arguments
		echo    and they are covered in the next field description. For now, just grab everything up
		echo    until the extension such as ".exe" and paste it here.
		echo --Be sure to remove any spaces at the end of the path.
		echo --If the TYPE is a WEBSITE, type NA here.
		echo.
		echo “FILE_ARGS”
		echo --If in the previous field you encountered any Arguements after the file extension,
		echo   copy/paste that arguement in this field without any prefixing spaces before the dash.
		echo --Look at the examples provided in the .csv file for a better idea of what this is.
		echo --If the TYPE is a WEBSITE, type NA here.
		echo.
		echo “RunWithoutElevatedPermissions”
		echo --Unless you already understand what this is, just leave this field as NA.
		echo --If you are a user of AudioForVATSIM “AFV”, you may want this field to be Y.
		echo.
		echo.
		echo.
	)>"!BatchAppDataDir!\ReadMe.txt"
	
	cls
	
	echo.
	echo                            --------------
	echo                               STOP^^!^^!^^!^^!^^!
	echo                            --------------
	echo.
	echo            THIS IS THE ONLY TIME YOU WILL GET THIS MESSAGE
	echo                  YOU NEED TO READ THIS PART CAREFULLY
	echo.
	echo A configuration file and a ReadMe.txt file has been created for you here:
	echo 	!BatchAppDataDir!
	echo.
	echo    Please read the ReadMe.txt file first to understand what you need to
	echo    do with the Workstation_Config.csv
	echo.
	echo.
	echo Press any key to open the directory where these files are, and this
	echo CMD Prompt window will close. When done editing this file, feel free to
	echo restart this BATCH file.
	
	pause>nul
	
	START /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	exit

:NAME_IS_NA

	cls
				
	echo.
	echo.
	echo                       ---------
	echo                        WARNING
	echo                       ---------
	echo.
	echo A name column is set to "!NAME!" and that is not a valid name.
	echo.
	echo Selecting ENTER will close this CMD Prompt window and launch
	echo the folder hosting the configuration file allowing you to
	echo investigate the issue and resolve it prior to running this
	echo BATCH file again.
	
	pause>nul
	
	start /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	EXIT

:TYPE_NOT_VALID

	cls
				
	echo.
	echo.
	echo                       ---------
	echo                        WARNING
	echo                       ---------
	echo.
	echo The TYPE column for "!NAME!" is set to "!TYPE!" and that is not a valid TYPE.
	echo.
	echo It must be either PROGRAM or WEBSITE.
	echo.
	echo Selecting ENTER will close this CMD Prompt window and launch
	echo the folder hosting the configuration file allowing you to
	echo investigate the issue and resolve it prior to running this
	echo BATCH file again.
	
	pause>nul
	
	start /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	EXIT

:FULL_PATH_IS_NA

	cls
				
	echo.
	echo.
	echo                       ---------
	echo                        WARNING
	echo                       ---------
	echo.
	echo The "!NAME!" FULL_PATH column is set to "!FULL_PATH!".
	echo.
	echo Programs require a full path to the file in order to launch it.
	echo.
	echo Selecting ENTER will close this CMD Prompt window and launch
	echo the folder hosting the configuration file allowing you to
	echo investigate the issue and resolve it prior to running this
	echo BATCH file again.
	
	pause>nul
	
	start /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	EXIT

:FULL_PATH_NOT_FOUND

	cls
				
	echo.
	echo.
	echo                       ---------
	echo                        WARNING
	echo                       ---------
	echo.
	echo The "!NAME!" FULL_PATH column is set to "!FULL_PATH!".
	echo.
	echo This path could not be found.
	echo.
	echo Selecting ENTER will close this CMD Prompt window and launch
	echo the folder hosting the configuration file allowing you to
	echo investigate the issue and resolve it prior to running this
	echo BATCH file again.
	
	pause>nul
	
	start /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	EXIT

:URL_IS_NA

	cls
				
	echo.
	echo.
	echo                       ---------
	echo                        WARNING
	echo                       ---------
	echo.
	echo The "!NAME!" URL column is set to "!URL!".
	echo.
	echo Websites require a URL in order to launch it.
	echo.
	echo Selecting ENTER will close this CMD Prompt window and launch
	echo the folder hosting the configuration file allowing you to
	echo investigate the issue and resolve it prior to running this
	echo BATCH file again.
	
	pause>nul
	
	start /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	EXIT


:ConfigHasNulValues

	cls
				
	echo.
	echo.
	echo                       ---------
	echo                        WARNING
	echo                       ---------
	echo.
	echo Somewhere in the Workstation_Config.csv file there is a blank value.
	echo.
	echo If editing with a spreadsheet program:
	echo 	This means a cell is blank and that needs to be fixed.
	echo 	Place NA in any of the blank cells within the array.
	echo.
	echo If editing without a spreadsheet program:
	echo 	This means there are two commas next to each other with nothing between them.
	echo 	This needs to be resolved and if the value is not applicable,
	echo 	place NA in between the commas.
	echo.
	echo Selecting ENTER will close this CMD Prompt window and launch
	echo the folder hosting the configuration file allowing you to
	echo investigate the issue and resolve it prior to running this
	echo BATCH file again.
	
	pause>nul
	
	start /B /WAIT explorer.exe "!BatchAppDataDir!"
	
	EXIT

:HELP
	
	cls
	
	echo.
	echo.
	echo WHAT DO NEED TO DO?
	echo.
	echo    R) Resetting all preferences; Making it like the first time you ran this script.
	echo            -Be careful, as this will also delete your saved directories and websites.
	echo.
	echo    E) I want to edit the Workstation_Config.csv file.
	echo.
	echo.
	
	set RESET_QUERY=NO_INPUT_BY_USER
	
	set /P HELP_QUERY=Type one of the letters associated with your options and press Enter: 
		if /i "!HELP_QUERY!"=="R" GOTO HelpResetBatch
		if /i "!HELP_QUERY!"=="E" GOTO HelpEditConfigFile
		
		echo.
		echo  *** !RESET_QUERY! *** is NOT a recognized response. Try again...
		echo.
		echo Press any key to try again...
		
		pause>nul
		
		goto HELP

:HelpResetBatch

	cls
	
	echo.
	echo.
	echo Typing "Y" without quotes will delete all previously
	echo saved data such as directories and websites.
	echo.
	echo 	-Any other action will just return you to the main menu.
	echo.
	
	:: If user types Y (regardless of case), the %LocalAppdata%\WorkstationBatch
	:: folder and all contents will be removed which will require the user to set
	:: it up again on the next run of this script.
	:: Typing anything else or nothing at all will return to the beginning of this script.
	set RESET_QUERY=NO_INPUT_BY_USER
	
	set /P RESET_QUERY=To reset preferences type Y, and press Enter: 
		if /i not "!RESET_QUERY!"=="Y" GOTO HELLO
		
		cd /d "%LocalAppdata%"
		
		if exist "!BatchAppDataDir!" (
			RD /S /Q "!BatchAppDataDir!"
			cls
			echo.
			echo.
			echo This BATCH file has been reset as if it is the first time you are running it.
			echo.
			echo Press any key to return to the main menu...
			pause>nul
			goto HELLO
		) else (
			cls
			echo.
			echo.
			echo Looks like there was no Configuration files to delete/reset.
			echo.
			echo To have one set up for you, return to the main menu and then press
			echo Enter to "Start your workstation".
			echo.
			echo Press any key to return to the main menu...
			pause>nul
			goto HELLO
		)

:HelpEditConfigFile

	cls
	
	echo.
	echo.
	
	if exist "!BatchAppDataDir!" (
		echo Press any key to open the directory with your configuration file...
		
		pause>nul
		
		start /B /WAIT explorer.exe "!BatchAppDataDir!"
		
		exit
	) else (
		echo Looks like you do not yet have a Configuration file.
		echo.
		echo To have one set up for you, return to the main menu and then press
		echo Enter to "Start your workstation".
		echo.
		echo.
		echo Press any key to return to the main menu...
		
		pause>nul
		
		goto HELLO
	)
