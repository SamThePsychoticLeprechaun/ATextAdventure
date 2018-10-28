:: Disable command echoing.
@ECHO OFF

:: Set current working directory to the project directory.
PUSHD "%~dp0"

:: Make sure we don't polute global environment.
SETLOCAL

:: Some defaults we will override with settings chosen by caller.
SET BUILD_CLEAN="false"

:: The parameter lists for CMAKE and MAKE (or equivalent build tool).
SET "CMAKE_PARAMS="
SET "BUILD_PARAMS="

:: Jump to the loop to process parameters passed to this script.
GOTO ParamLoop

:: Define a bunch of helper functions for parameter processing loop.
:Help
ECHO "\n"
ECHO "    /--------------\\ \n    |  Build Help  |\n    \\--------------/\n\n"
ECHO "        Build flags:\n"
ECHO "            --clean             | -c       ---   Clean build, removes all previous artefacts.\n"
ECHO "        CMake flags:\n"
ECHO "            --release           | -r       ---   Compile in release mode.\n"
ECHO "            --debug             | -d       ---   Compile in debug mode.\n"
ECHO "        Make flags:\n"
ECHO "            --verbose           | -v       ---   Run make with verbose set on.\n"
ECHO "\n"
GOTO ParamLoopContinue

:Clean
SET BUILD_CLEAN="true"
GOTO ParamLoopContinue

:Release
SET "CMAKE_PARAMS=%CMAKE_PARAMS% -DCMAKE_BUILD_TYPE=Release"
GOTO ParamLoopContinue

:Debug
SET "CMAKE_PARAMS=%CMAKE_PARAMS% -DCMAKE_BUILD_TYPE=Debug"
GOTO ParamLoopContinue

:Verbose
SET "BUILD_PARAMS=%BUILD_PARAMS% VERBOSE=1"
GOTO ParamLoopContinue

:: Loop over each parameter passed to this script, and appropriately update the earlier-defined variables.
:ParamLoop
    IF "%1"=="-h" (
        GOTO Help
    ) ELSE IF "%1"=="--help" (
        GOTO Help
    ) ELSE IF "%1"=="-c" (
        GOTO Clean
    ) ELSE IF "%1"=="--clean" (
        GOTO Clean
    ) ELSE IF "%1"=="-r" (
        GOTO Release
    ) ELSE IF "%1"=="--release" (
        GOTO Release
    ) ELSE IF "%1"=="-d" (
        GOTO Debug
    ) ELSE IF "%1"=="--debug" (
        GOTO Debug
    ) ELSE IF "%1"=="-v" (
        GOTO Verbose
    ) ELSE IF "%1"=="--verbose" (
        GOTO Verbose
    ) ELSE IF NOT "%1"=="" (
        ECHO "Error: Do not recognise argument %1."
        EXIT /B 1
    ) ELSE (
        GOTO ParamLoopBreak
    )
    :ParamLoopContinue
    SHIFT
GOTO Argloop
:ParamLoopBreak

:: If build directory exists and we want a clean build, delete all the contents of the build directory.
:: In any case, if it doesn't exist, create it.
IF EXIST "build" (
    IF "%BUILD_CLEAN%"=="true" (
        RMDIR build /S /Q
    )
) ELSE (
    MKDIR build
)

:: Construct and call cmake command to generate build configuration.
SET "CMAKE_COMMAND=cmake -H. -Bbuild %CMAKE_PARAMS% -Wno-deprecated"
%CMAKE_COMMAND%

:: Construct and call build command.
SET "BUILD_COMMAND=cmake --build build -- %BUILD_PARAMS%"
%BUILD_COMMAND%

:: Return to terminal's previous working directory.
POPD