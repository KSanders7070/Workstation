@ECHO OFF
setlocal enabledelayedexpansion

REM Set SCRIPT_NAME to the name of this batch file script
set "THIS_VERSION=1.0.a001"

REM Set SCRIPT_NAME to the name of this batch file script
set "SCRIPT_NAME=Workstation"

REM Set GH_USER_NAME to your GitHub username here
set "GH_USER_NAME=KSanders7070"

REM Set GH_REPO_NAME to your GitHub repository name here
set "GH_REPO_NAME=Workstation"

REM TODO add version check code prior to release here
:RestOfCode

:HELLO
REM TODO ask the user what they want to do.

:AppDirChk
REM Checks if the WorkstationBatch AppData directory for this batch script exists.
REM If not, it's likely the first time running and goes to the setup function.
set "BatchAppDataDir=%LocalAppdata%\WorkstationBatch"
if not exist "!BatchAppDataDir!" call :InitialSetup

:InitiateVariables
REM Set initial values for variables
set "NAME=NOT_YET_SET"
set "TYPE=NOT_YET_SET"
set "FULL_PATH=NOT_YET_SET"
set "URL=NOT_YET_SET"

:ValidateConfigFileData
REM Read the CSV file and ensure the data makes sense.

cd /d "!BatchAppDataDir!"

REM Skip the first line, as the first line only provides the user with header information when editing the file.
for /f "skip=1 tokens=1-5 delims=," %%a in (Workstation_Config.csv) do (
    
	REM NAME=%%a
		echo.
		echo.
		echo.
		echo ID "%%a"
    REM TYPE=%%b
		echo  TYPE "%%b"
    REM FULL_PATH=%%c
		echo   FULL_PATH "%%c"
    REM URL=%%d
		echo    URL "%%d"
    REM RunWithoutElevatedPermissions=%%e
		echo     RunWithoutElevatedPermissions "%%e"

    REM Check NAME
    if "%%a"=="" (
        call :NAME_NUL
    )

    REM if TYPE is not "PROGRAM"...
    if /i not "%%b"=="PROGRAM" (
        REM ...and it isn't "WEBSITE" then there is an issue.
        if /i not "%%b"=="WEBSITE" call :TYPE_NOT_VALID
    )

    REM if TYPE is "PROGRAM"...
    if /i "%%b"=="PROGRAM" (
        REM ...And the FULL_PATH is nul, there is an issue.
        if "%%c"=="" call :FULL_PATH_IS_NUL
		
        REM FULL_PATH is not null so check to see if the FULL_PATH
        REM is found, if not we have issues...
		if not exist "%%c" call :FULL_PATH_NOT_FOUND
        )

        REM If RunWithoutElevatedPermissions is null, the user needs to define Y or N.
        if /i "%%e"=="" call :ElvPerms_IS_NUL

    REM Check FULL_PATH if TYPE is PROGRAM
    if /i "%%b"=="PROGRAM" (
		REM if the PATH is Nul, there is an issue.
        if "%%c"=="" (
            call :FULL_PATH_IS_NUL
        ) else (
			
			REM If it is not Nul, check to see if the path exists.
            if not exist "%%c" (
                call :FULL_PATH_NOT_FOUND
            )
        )
    )

    REM Check RunWithoutElevatedPermissions is not blank and is Y or N if TYPE is PROGRAM
    if /i "%%b"=="PROGRAM" (
        if "%%e"=="" (
            call :ElvPerms_IS_NUL
        )
    )

    REM Check URL if TYPE is WEBSITE
    if /i "%%b"=="WEBSITE" (
        if "%%d"=="" (
            call :URL_IS_NUL
        ) else (
            REM TODO Find a way to make sure this is a valid website URL. Consider a silent CURL with an errorlevel check.
        )
    )
)
ECHO DONE with Config File validation.
PAUSE
EXIT

:LaunchWorkstation
REM TODO Begin the process again. Basically the same as above but now we actually start the data, and no error checking is required.

ECHO reached LaunchWorkstation, and there is work to be done.
PAUSE
EXIT

:CallFunctions

:InitialSetup
REM Creates a directory for this BATCH file to host data in like the config file and preferences.
md "!BatchAppDataDir!"

REM Creates a Config file for the user to be able to edit.
(
    echo NAME,TYPE,FULL_PATH,URL,RunWithoutElevatedPermissions
    echo GOOGLE SITE,WEBSITE,NA,WWW.GOOGLE.COM,N
    echo NOAA SITE,WEBSITE,NA,WWW.NOAA.GOV,N
    echo vATIS,PROGRAM,%LocalAppdata%\vATIS-4.0\Application\vATIS.exe,NA,N
    echo AFV,PROGRAM,C:\AudioForVATSIM\AudioForVATSIM.exe,NA,Y
    echo CRC,PROGRAM,%LocalAppdata%\CRC\Application\CRC.exe,NA,N
)>"!BatchAppDataDir!\Workstation_Config.csv"

(
    echo.
    echo.
    echo Thank you for using this Workstation Batch file.
    echo.
    echo It is meant to open all of your programs and websites that you want before getting to work on a project or playing a video game or anything that I can't think of right now.
    echo.
    echo In the same directory that you are viewing this .txt file is a .csv Config file for this BATCH file.
    echo Please open this file in a program that edits spreadsheets such as Excel.
    echo.
    echo Please edit this file to your liking as this is the information that the BATCH file will pull from when starting your Workstation.
    echo.
    echo Column explanations:
	echo      Note-No field can be left blank. Please place an NA in a field that should be blank.
    echo.
    echo “NAME”
    echo --This is any name you want to give the program and will only be used to help identify this program later if there is a problem.
    echo --Please try to avoid special characters.
    echo.
    echo “TYPE”
    echo --This can only be “PROGRAM” or “WEBSITE” without the quotes.
    echo ----If you can double click the file and it runs, it is a PROGRAM
    echo ----If it is something you visit in an internet web browser, it is a WEBSITE.
    echo ------yes, I have to spell this out to some people. lol
    echo.
    echo “FULL_PATH”
    echo --The directory where to find the file and including the file at the end.
    echo --Look at the examples provided for a better idea of what this is.
    echo --If the TYPE is a WEBSITE, type NA here.
    echo.
    echo “URL”
    echo --The Web Address of the website you want to open.
    echo --If the TYPE is a PROGRAM, type NA here.
    echo.
    echo “RunWithoutElevatedPermissions”
    echo --Unless you already understand what this is, just leave this field as N.
    echo --If you are a user of AudioForVATSIM “AFV”, you may want this field to be Y.
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

:NAME_NUL
REM TODO Finish this error screen.
echo NAME is null or has no value.
PAUSE
EXIT

:TYPE_NOT_VALID
REM TODO Finish this error screen.
echo TYPE is not valid.
PAUSE
EXIT

:FULL_PATH_IS_NUL
REM TODO Finish this error screen.
echo FULL_PATH is null or has no value, but TYPE is PROGRAM.
PAUSE
EXIT

:FULL_PATH_NOT_FOUND
REM TODO Finish this error screen.
echo FULL_PATH does not exist.
PAUSE
EXIT

:URL_IS_NUL
REM TODO Finish this error screen.
echo URL is null or has no value, but TYPE is WEBSITE.
PAUSE
EXIT

:ElvPerms_IS_NUL
REM TODO Finish this error screen.
echo URL is null or has no value, but TYPE is WEBSITE.
PAUSE
EXIT

pause
exit
