echo off
set Cfg=%1

if "%Cfg%" NEQ "Release" (
    if "%Cfg%" NEQ "Debug" (
        if "%Cfg%" NEQ "Production" (
            echo Script requires a single argument: the build config to build.  Must be Release, Debug or Production
            exit /b 1
        )
    )
)
pushd "%~dp0\NVIGI-Plugins"
mklink /j nvigi_core ..\NVIGI-Core
call .\setup.bat
call .\build.bat -%Cfg%
call .\copy_sdk_binaries.bat %Cfg%
call .\copy_3rd_party.bat
popd
