@echo off
setlocal
set "Cfg=%~1"
if "%Cfg%" NEQ "Release" (
    if "%Cfg%" NEQ "Debug" (
        if "%Cfg%" NEQ "Production" (
            echo ERROR: Specify Release, Debug or Production.
            exit /b 1
        )
    )
)
pushd "%~dp0NVIGI-Plugins"
if errorlevel 1 (
    echo ERROR: Cannot enter the NVIGI-Plugins directory.
    exit /b 1
)

REM Accept only a junction to the sibling Core tree; never replace an existing item.
set "Step=Core junction validation"
powershell.exe -NoProfile -NonInteractive -Command "$ErrorActionPreference = 'Stop'; try { $link = Join-Path (Get-Location).Path 'nvigi_core'; $expected = [IO.Path]::GetFullPath((Join-Path (Get-Location).Path '..\NVIGI-Core')); if (-not (Test-Path -LiteralPath $expected -PathType Container)) { throw 'The sibling NVIGI-Core directory is missing.' }; $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue; if ($null -eq $item) { New-Item -ItemType Junction -Path $link -Target $expected -ErrorAction Stop | Out-Null } else { if ($item.LinkType -ne 'Junction') { throw 'nvigi_core already exists but is not a junction. Move it aside or correct it manually.' }; $target = @($item.Target)[0]; if (-not [IO.Path]::IsPathRooted($target)) { $target = Join-Path (Get-Location).Path $target }; $target = [IO.Path]::GetFullPath($target); if (-not [string]::Equals($target.TrimEnd('\'), $expected.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)) { throw ('nvigi_core points to ' + $target + '; expected ' + $expected + '. Correct it manually.') } }; exit 0 } catch { Write-Host ('ERROR: ' + $_.Exception.Message); exit 1 }"
if errorlevel 1 goto :failed
set "Step=Plugins setup"
call .\setup.bat
if errorlevel 1 goto :failed
set "Step=Plugins build"
call .\build.bat -%Cfg%
if errorlevel 1 goto :failed
set "Step=SDK binary and header copy"
call .\copy_sdk_binaries.bat %Cfg%
if errorlevel 1 goto :failed
set "Step=Third-party runtime copy"
call .\copy_3rd_party_win_x64.bat %Cfg%
if errorlevel 1 goto :failed
popd
exit /b 0

:failed
echo ERROR: %Step% failed. Stopping; later steps were not run.
popd
exit /b 1
