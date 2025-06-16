pushd "%~dp0\NVIGI-Core"
call .\setup.bat
call .\build -all
call .\package.bat -config runtime -dir _runtime
popd