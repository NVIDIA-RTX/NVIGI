@echo off
setlocal
pushd "%~dp0NVIGI-Core"
if errorlevel 1 (
    echo ERROR: Cannot enter the NVIGI-Core directory.
    exit /b 1
)
set "Step=Core setup"
call .\setup.bat
if errorlevel 1 goto :failed
set "Step=Core build"
call .\build.bat -all
if errorlevel 1 goto :failed
set "Step=Core runtime packaging"
call .\package.bat -config runtime -dir _runtime
if errorlevel 1 goto :failed
popd
exit /b 0

:failed
echo ERROR: %Step% failed. Stopping; later steps were not run.
popd
exit /b 1
