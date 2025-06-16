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
pushd "%~dp0\NVIGI-3d-Sample"
mklink /j nvigi_core ..\NVIGI-Core\_runtime
mklink /j nvigi_plugins ..\NVIGI-Plugins
call .\make.bat
msbuild .\_build\NVIGISample.sln /m /t:Clean,Build /property:Configuration=%Cfg%
popd
