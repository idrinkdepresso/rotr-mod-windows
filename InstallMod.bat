::Installmod.bat
::Mod injector for Rise of the Tomb Raider by alphaZomega
::Version 2.0
::September 23 2021
@echo off
setlocal enabledelayedexpansion
set file= & set injector= & set tiger= & set tigerTemp= & set yn= & set z= & set w= & set rootDir= & set txtf= & set extn= & set logfile= & set removeQuotes= & set lengthTest= & set fName=
set injector=%~dp0Tools\ROTTRtigetadd.exe
set file=%1
set fName=%~n1
::											USER SETTINGS											::
::
::Location of bigfile.tiger file (default is [current directory]\bigfile.update3.000.000.tiger):
set tiger=%~dp0bigfile.update3.000.000.tiger
::Set deepSearch to 1 to enable replacing ALL references to asset when injecting single-files:
set deepSearch=-1
::Name of DRM file to use when injecting single-files (default is [current directory]\drmfile.drm)
set drmFile=drmfile.drm


::Auto-detect DeepSearch by filename if -1:
if "%deepSearch%"=="-1" (
	for %%i in (%1) do if not exist %%~si\NUL do (
		if /I "!fName:~0,8!"=="Replace" do (
			set deepSearch=1
		) else set deepSearch=0
	)
)

:Start
cls
echo.
echo.
echo.
echo.
echo Rise of the Tomb Raider Asset Injector Script by alphaZomega
echo Version 2.0 -- September 23, 2021
echo Tools by aman, alphaZomega and Gh0stBlade
echo.
echo This tool injects assets into Rise of the Tomb Raider 
echo To inject an asset, drag and drop your asset file, named "Section XXXX.[extension]", onto this batch file.
echo Place the DRM file for the asset in your game directory as "drmfile.drm"
echo To inject a mod package, drag and drop the mod folder onto this batch file.
echo Run this file from within the game directory, and do not TOUCH Tools\tiger_patch.log
echo Run this batch file by itself to uninstall all mods.
echo.
echo.
set tigerTemp=%tiger%
if /I "%~n1"=="" goto:Uninstall
echo -Detected File: %file%
echo -Detected Section number: %fName:~8,4%
echo -DRM file: %drmFile%
echo -TIGER file: %tiger%
echo -Do Deep Search: %deepSearch%
echo.
echo Do you want to install? [Y/N]
echo You can also change Bigfile from [0-3] here:
set /p yn="--> "
if /I "%yn%"=="3" set tiger=%~dp0bigfile.update3.000.000.tiger & goto :Start
if /I "%yn%"=="2" set tiger=%~dp0bigfile.update2.000.000.tiger & goto :Start
if /I "%yn%"=="1" set tiger=%~dp0bigfile.update1.000.000.tiger & goto :Start
if /I "%yn%"=="0" set tiger=%~dp0bigfile.000.tiger & cls & goto :Start
if /I not "%yn%"=="Y" goto :clear
goto :Install

:Install
for %%i in (%1) do if not exist %%~si\NUL goto :SingleFile
set rootDir=%~dp0
set rootDir=%rootDir:~0,-1%
cd %1 & call :InjectFolder section 0
cd %1 & call :InjectFolder replace 1
goto :clear

:SingleFile
if not exist %drmFile% (
	:checkFile
	echo.
	echo DRM File %drmFile% not found, input a DRM file or type 'exit' to abort:
	set /p drmFile="--> "
	if "%drmFile%"=="exit" (goto :clear)
	if not exist %drmFile% (goto :checkFile)
)
echo xcopy %1 "%~dp0Tools\%~nx1*" /i /q /y
xcopy %1 "%~dp0Tools\%~nx1*" /i /q /y
.\tools\CDRM.exe ".\Tools\%~nx1"
echo .\Tools\ROTTRtigetadd.exe . %drmFile% %fName:~8,4% %1 ".\Tools\%~nx1" "%tiger%"
.\Tools\ROTTRtigetadd.exe . %drmFile% %fName:~8,4% %1 ".\Tools\%~nx1" "%tiger%" %deepSearch%
echo del "%~dp0Tools\%~nx1"
del "%~dp0Tools\%~nx1"
goto :clear

:Uninstall
set rootDir=%~dp0
set rootDir=%rootDir:~0,-1%
echo.
echo No file was detected. Do you want to uninstall all mods? [Y/N]
set /P yn="--> "
if /I not "%yn%"=="Y" goto :clear
echo.
if exist "!rootdir!\Tools\tiger_patch.log" (
	echo .\Tools\ROTTRtigetadd.exe . tiger_patch.log
	.\Tools\ROTTRtigetadd.exe . tiger_patch.log
	echo.
)
goto :clear

:clear
set file= & set injector= & set tiger= & set tigerTemp= & set yn= & set z= & set w= & set rootDir= & set txtf= & set extn= & set logfile= & set removeQuotes= & set lengthTest= & set fName=
endlocal
pause
goto :eof

:InjectFolder
for /D %%a in (*) do (
	cd "%%a"
	for /f "usebackq delims=|" %%f in (`dir /b "%cd%\%%a\" ^| findstr /i %1`) do (
		set txtf=%%f
		set extn=!txtf:~12,4!
		set w=!txtf:~8,4!
		rem echo extn is "!extn!" and section is !w!
		if "!extn!" == ".txt" for /F "usebackq tokens=*" %%i in ("%cd%\%%a\!txtf!") do (
			set txtf=%%i
			echo Found link in txt file from Section !w! to %%i
		)
		set z=!txtf!
		if exist "%cd%\%%a\bigfile.update3.000.000.tiger.txt" (
			set tiger=!rootdir!\bigfile.update3.000.000.tiger
			echo Changed to injecting !tiger!
		) else if exist "%cd%\%%a\bigfile.update2.000.000.tiger.txt" (
			set tiger=!rootdir!\bigfile.update2.000.000.tiger
			echo Changed to injecting !tiger!
		) else if exist "%cd%\%%a\bigfile.update1.000.000.tiger.txt" (
			set tiger=!rootdir!\bigfile.update1.000.000.tiger
			echo Changed to injecting !tiger!
		) else if exist "%cd%\%%a\bigfile.000.tiger.txt" (
			set tiger=!rootdir!\bigfile.000.tiger
			echo Changed to injecting !tiger!
		) else set tiger=!tigerTemp!
		rem echo xcopy "%cd%\%%a\!z!" "!rootDir!\Tools\!z!*" /i /q /y
		xcopy "%cd%\%%a\!z!" "!rootDir!\Tools\!z!*" /i /q /y
		echo.
		rem echo !rootDir!\tools\CDRM.exe "!rootDir!\Tools\!z!"
		"!rootDir!\tools\CDRM.exe" "!rootDir!\Tools\!z!"
		echo.
		echo !rootDir!\Tools\ROTTRtigetadd.exe "%rootDir%" "%cd%\%%a\%%a.drm" !w! "%cd%\%%a\!z!" "!rootDir!\Tools\!z!" "!tiger!" %2 
		"!rootDir!\Tools\ROTTRtigetadd.exe" "%rootDir%" "%cd%\%%a\%%a.drm" !w! "%cd%\%%a\!z!" "!rootDir!\Tools\!z!" "!tiger!" %2
		echo.
		echo del "!rootDir!\Tools\!z!"
		if exist "!rootDir!\Tools\!z!" del "!rootDir!\Tools\!z!"
		call :GetLogFile "!rootDir!\Tools\" "%cd%\%%a"
		echo.
	)
	cd ..
)

goto :eof
:GetLogFile
for /f %%i in ('dir /b/a-d/od/t:c %1') do set logfile=%%i
set extn=!logfile:~0,11!
if "!extn!" == "tiger_patch" (
	call :RemoveQuotes %2
	if not exist "!removeQuotes!\!logfile!" (
		rem echo xcopy /i /q /y /f "!rootdir!\Tools\!logfile!" "!removeQuotes!\!w!.log*"
		xcopy /i /q /y /f "!rootdir!\Tools\!logfile!" "!removeQuotes!\!w!.log*" 
	)
)

goto :eof
:RemoveQuotes
FOR /F "delims=" %%I IN (%1) DO SET removeQuotes=%%I