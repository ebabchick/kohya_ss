@echo off
setlocal enabledelayedexpansion

rem Define the default values
set Branch=master
set Dir=%~dp0
set File=
set GitRepo=https://github.com/bmaltais/kohya_ss.git
set Interactive=0
set NoSetup=0
set Public=0
set Runpod=0
set SetupOnly=0
set SkipSpaceCheck=0
set Update=0
set Verbose=0
set GUI_LISTEN=127.0.0.1
set GUI_USERNAME=
set GUI_PASSWORD=
set GUI_SERVER_PORT=7861
set GUI_INBROWSER=1
set GUI_SHARE=0

rem Load the configuration file from the first existing location
set ConfigFile=
for %%F in (
    "%CD%\install_config.yml"
    "%USERPROFILE%\.kohya_ss\install_config.yml"
    "%~dp0\install_config.yml"
) do (
    if exist "%%F" (
        set ConfigFile=%%F
        goto load_config
    )
)

:load_config
if not "%ConfigFile%"=="" (
    for /f "tokens=1,2 delims=: " %%a in (%ConfigFile%) do (
        if "%%a"=="Branch" set Branch=%%b
        if "%%a"=="Dir" set Dir=%%b
        if "%%a"=="File" set File=%%b
        if "%%a"=="GitRepo" set GitRepo=%%b
        if "%%a"=="Interactive" set Interactive=%%b
        if "%%a"=="NoSetup" set NoSetup=%%b
        if "%%a"=="Public" set Public=%%b
        if "%%a"=="Runpod" set Runpod=%%b
        if "%%a"=="SetupOnly" set SetupOnly=%%b
        if "%%a"=="SkipSpaceCheck" set SkipSpaceCheck=%%b
        if "%%a"=="Update" set Update=%%b
        if "%%a"=="Verbose" set Verbose=%%b
        if "%%a"=="Listen" set LISTEN=%%b
        if "%%a"=="Username" set USERNAME=%%b
        if "%%a"=="Password" set PASSWORD=%%b
        if "%%a"=="ServerPort" set SERVER_PORT=%%b
        if "%%a"=="InBrowser" set INBROWSER=%%b
        if "%%a"=="Share" set SHARE=%%b
    )
)

rem Parse command line arguments and override loaded config file values
:arg_loop
if "%~1"=="" goto arg_end
if /i "%~1"=="--branch" (shift & set Branch=%1) & shift & goto arg_loop
if /i "%~1"=="--dir" (shift & set Dir=%1) & shift & goto arg_loop
if /i "%~1"=="--file" (shift & set File=%1) & shift & goto arg_loop
if /i "%~1"=="--git-repo" (shift & set GitRepo=%1) & shift & goto arg_loop
if /i "%~1"=="--help" goto print_help
if /i "%~1"=="--interactive" (set Interactive=1) & shift & goto arg_loop
if /i "%~1"=="--no-setup" (set NoSetup=1) & shift & goto arg_loop
if /i "%~1"=="--public" (set Public=1) & shift & goto arg_loop
if /i "%~1"=="--runpod" (set Runpod=1) & shift & goto arg_loop
if /i "%~1"=="--setup-only" (set SetupOnly=1) & shift & goto arg_loop
if /i "%~1"=="--skip-space-check" (set SkipSpaceCheck=1) & shift & goto arg_loop
if /i "%~1"=="--update" (set Update=1) & shift & goto arg_loop
if /i "%~1"=="--verbose" (set /A Verbose=Verbose+1) & shift & goto arg_loop
if /i "%~1"=="--listen" (shift & set LISTEN=%1) & shift & goto arg_loop
if /i "%~1"=="--username" (shift & set USERNAME=%1) & shift & goto arg_loop
if /i "%~1"=="--password" (shift & set PASSWORD=%1) & shift & goto arg_loop
if /i "%~1"=="--server-port" (shift & set SERVER_PORT=%1) & shift & goto arg_loop
if /i "%~1"=="--inbrowser" (set INBROWSER=1) & shift & goto arg_loop
if /i "%~1"=="--share" (set SHARE=1) & shift & goto arg_loop
shift
goto arg_loop

:arg_end

:print_help
echo Usage: my_script.bat [OPTIONS]
echo.
echo OPTIONS:
echo --branch           : Specify the Git branch to use. Default is 'master'.
echo --dir              : Specify the working directory. Default is the directory of the script.
echo --file             : Specify the configuration file to be processed.
echo --git-repo         : Specify the Git repository URL. Default is 'https://github.com/bmaltais/kohya_ss.git'.
echo --help             : Display this help.
echo --interactive      : Run in interactive mode.
echo --no-setup         : Skip the setup process.
echo --public           : Run in public mode.
echo --runpod           : Run in Runpod mode.
echo --setup-only       : Only run the setup process, do not launch the application.
echo --skip-space-check : Skip the disk space check.
echo --update           : Run the update process.
echo --verbose          : Increase the verbosity level.
echo --listen           : Specify the GUI listen address. Default is '127.0.0.1'.
echo --username         : Specify the GUI username.
echo --password         : Specify the GUI password.
echo --server-port      : Specify the GUI server port. Default is 7861.
echo --inbrowser        : Open the GUI in the browser.
echo --share            : Enable GUI sharing.
goto :eof

rem we set an Args variable, so we can pass that to the launcher at the end and pass through values
set Args=-b "%Branch%" -d "%Dir%" -f "%File%" -g "%GitRepo%" ^
          -i:%Interactive% -n:%NoSetup% -p:%Public% -r:%Runpod% -s:%SkipSpaceCheck% -v %Verbose% ^
          --setup-only "%SetupOnly%" --listen "%LISTEN%" --username "%USERNAME%" --password "%PASSWORD%" ^
          --server-port %SERVER_PORT% --inbrowser:%INBROWSER% --share:%SHARE%

copy /y "%Dir%\bitsandbytes_windows\*.dll" "%Dir%\venv\Lib\site-packages\bitsandbytes\"
copy /y "%Dir%\bitsandbytes_windows\cextension.py" "%Dir%\venv\Lib\site-packages\bitsandbytes\cextension.py"
copy /y "%Dir%\bitsandbytes_windows\main.py" "%Dir%\venv\Lib\site-packages\bitsandbytes\cuda_setup\main.py"

rem Call launcher.py with the provided arguments
python "%Dir%\launcher.py" %Args%
