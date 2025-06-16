# NVIDIA In-Game Inference AI Kit
Version 1.2.0 Release

If you are getting started with the NVIDIA In-Game Inference AI SDK, this repo is NOT for you.  Most NVVIGI developers will not need to build the SDK from source; they will be able to use the pre-built SDK package, available from the [NVIDIA In-Game Inference SDK Main Page](https://developer.nvidia.com/rtx/in-game-inferencing).  New NVIGI developers should invariably start with binary packs from that page, as building from source will require components from these binary packs.

The repo includes documentation and scripts to make it easy to pull and build the NVIDIA In-Game Inference SDK from source.  It also includes submodule pointers to all of the components for each release.  When cloning this tree, ensure that submodules are initialized and updated recursively, either during cloning (`--recurse-submodules`) or after (`git submodule update --init --recursive`).

## Required Binaries

In order to build the full source, there are a few binaries that need to be pulled from other locations that we cannot pull via public packman (the automated pulling system that much of NVIGI uses).  All of these libraries are most easily sourced from a package that you will likely have downloaded already; the pre-built NVIGI SDK package.  We recommend downloading it as above for this purpose alone.  The specific DLLs needed are:

- The Microsoft Windows Agility SDK D3D12 core runtime DLL.  Unlike the Agility SDK's headers, which are MIT licensed and pulled automatically during the source build process below, the Agility SDK's DLLs are licensed under a very permissive license that must nonetheless be actively accepted.  The download link for the pre-built NVIGI SDK package includes the required license text in its click-through window prior to downloading, satisfying this requirement.  The DLL required may be found in `nvigi_pack/plugins/sdk/bin/x64/D3D12/D3D12Core.dll`.  Alternatively, the DLL may be downloaded from Microsoft at https://devblogs.microsoft.com/directx/directx12agility/, version 1.615.1 or newer.  This DLL will be mentioned in the description below when it should be copied.
- The NVIGI GGML D3D12 ASR and GPT plugin DLLs.  These are experimental, and are NOT built via this source pack currently.  However, the command-line samples in the SDK and the 3D Sample may use them.  The instructions below will explain where they should be installed.  As a result, you will need the following DLLs from `nvigi_pack/plugins/sdk/bin/x64/`:
	- `nvigi.plugin.asr.ggml.d3d12.dll`
	- `nvigi.plugin.gpt.ggml.d3d12.dll`

## MSVC 2022 Min Prerequisites

There is a min version of the VS2022 C++ compiler tools required to rebuild the plugins; this minimum is set by the compiler used to compile the GGML ASR and GPT thrird-party libraries.  Older versions of the C++ compiler will lead to link errors in the GGML plugins.  Most users who build from source will simply update VS2022 to the latest and never see any issue.

There are several ways to ensure that the right compiler is used:

- Install ONLY the C++/CLI support for v143 build tools 14.43-17.13 or newer and similar MSVC v143 - VS 2022 C++ x64/x86 build tools (Use the Visual Studio Installer to change/verify)
- Ensure your install includes the C++/CLI support for v143 build tools 14.43-17.13 or newer and similar MSVC v143 - VS 2022 C++ x64/x86 build tools AND set them as the default for the project (Use the Visual Studio Installer to change/verify)

To set a desired set of tools for a given project, after the project is generated (make.bat, setup.bat) but before building, create a new file `Directory.Build.props` in the same directory as the project files (`*.sln`, `*.vcxproj*`) and place the following in it:

```xml
<Project>
  <PropertyGroup>
    <VCToolsVersion>14.43.34808</VCToolsVersion>
    <PlatformToolset>v143</PlatformToolset>
  </PropertyGroup>
</Project>
```

Where `14.43.34808` is replaced with the installed tool version that is new enough to meet the above requirements.  The version numbers will match the directory names found in your VS2022 install, e.g. `C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC\*`

##  Build Scripts

The scripts in this pack will pull the NVIGI Core, SDK Plugins and 3D Sample from the public NVIGI GitHib repos, run setup as needed, cross-link them and build them.  Most developers wanting to build source will use this as a starting point, modifying the scripts or copying parts of them into their own build process.

### `01_build_pack_core.bat`

This script sets up and builds all configs of the NVIGI Core (thus also creating a PDK), then packages a Runtime SDK.

#### Prerequisites

This script must be run from a VS2022 Developmer Command Prompt.

### `02_build_pack_plugins.bat`

This script sets up and builds the desired config of the NVIGI SDK Plugins, then packages the headers and binaries.  It also creates a link to the built, sibling Core directory (as a part of the setup step).

#### Prerequisites

This script must be run from a VS2022 Developmer Command Prompt and can only be run after `01_build_pack_core.bat` has been run successfully.

#### Running

The script requires a single argument of `Release`, `Debug` or `Production`, e.g.

```
.\02_build_pack_plugins.bat Release
```

#### Required Post-build Step

After running this for the first time on a tree, the following copies of the aforementioned external DLLs is required:

- Agility SDK `D3D12Core.dll` - copy to SDK bin in `NVIGI-Plugins/bin/x64/D3D12/` (the leaf directory `D3D12` will not exist prior to this)
- Plugin DLLs `nvigi.plugin.asr.ggml.d3d12.dll` and `nvigi.plugin.gpt.ggml.d3d12.dll` - copy to SDK bin in `NVIGI-Plugins/bin/x64/`

These must be done before trying to run the command-line samples or proceeding to the next step tp build the 3D Sample.

### `03_build_sample.bat`

This script sets up and builds the specified config of the NVIGI 3D Sample.  It also creates a link to the built, sibling Core Runtime SDK and Plugins directory (as a part of the setup step).

#### Prerequisites

This script must be run from a VS2022 Developmer Command Prompt and can only be run after `01_build_pack_core.bat` and `02_build_pack_plugins.bat` have been run successfully.

#### Running

The script requires a single argument of `Release`, `Debug` or `Production`, e.g.

```
.\03_build_sample.bat Release
```

Note that no matter which config is given, the SDK and Core DLLs copied into the `_bin` directory will be whatever was built by `02_build_pack_plugins.bat`

### Running the Built 3D Sample

The 3D Sample, by default, expects the `nvigi.models` directory to be located in the `nvigi` root directory.  So the easiest way to run the sample is to:

- Download the `nvigi_pack` binary release (likely already done as above)
- Set up its links with `setup_links.bat`
- Download its models with `download_data.bat`
- And make a link to that, e.g.

```
mklink /j nvigi.models <nvigi_pack>\nvigi.models
```
The 3D Sample should then run successfully by double-clicking the `NVIGISample.exe` in the `_bin` directory.
