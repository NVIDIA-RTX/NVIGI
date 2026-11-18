# NVIDIA In-Game Inference AI Kit
Version 1.8.0 Release

See the [1.8.0 release notes](NVIGI-Plugins/docs/ReleaseNotes.md#180-release) for new features, behavior changes and bug fixes.

If you are getting started with the NVIDIA In-Game Inference AI SDK, this repo is NOT for you.  Most NVIGI developers will not need to build the SDK from source; they will be able to use the pre-built SDK package, available from the [NVIDIA In-Game Inference SDK Main Page](https://developer.nvidia.com/rtx/in-game-inferencing).  New NVIGI developers should invariably start with binary packs from that page, as building from source will require components from these binary packs.

The repo includes documentation and scripts to make it easy to pull and build the NVIDIA In-Game Inference SDK from source.  It also includes submodule pointers to all of the components for each release.  When cloning this tree, ensure that submodules are initialized and updated recursively, either during cloning (`--recurse-submodules`) or after (`git submodule update --init --recursive`).

## Required Binaries

In order to build the full source, there are a few binaries that need to be pulled from other locations that we cannot pull via public packman (the automated pulling system that much of NVIGI uses).  All of these libraries are most easily sourced from a package that you will likely have downloaded already; the pre-built NVIGI SDK package.  We recommend downloading it as above for this purpose alone.  The specific DLLs needed are:

- The Microsoft Windows Agility SDK D3D12 core runtime DLL.  Unlike the Agility SDK's headers, which are MIT licensed and pulled automatically during the source build process below, the Agility SDK's DLLs are licensed under a very permissive license that must nonetheless be actively accepted.  The download link for the pre-built NVIGI SDK package includes the required license text in its click-through window prior to downloading, satisfying this requirement.  The DLL required may be found in `<PATH_TO_NVIGI_SDK_PACK>/bin/x64/D3D12/D3D12Core.dll`.  Alternatively, the DLL may be downloaded from Microsoft at https://devblogs.microsoft.com/directx/directx12agility/, version 1.615.1 or newer.  This DLL will be mentioned in the description below when it should be copied.
- Likewise, the [Microsoft DirectX Shader Compiler](https://github.com/microsoft/DirectXShaderCompiler) is distributed with a permissive license that needs to be accepted. Similarly to the previous item, the pre-built NVIGI SDK package includes the appropriate license text in its click-through window. The relevant DLLs that need to be copied over are `dxcompiler.dll` and `dxil.dll`, and they can be found in `<PATH_TO_NVIGI_SDK_PACK>/bin/x64/`.
- The NVIGI GGML D3D12 ASR and GPT plugin DLLs.  These are experimental, and are NOT built via this source pack currently.  However, the command-line samples in the SDK and the 3D Sample may use them.  The instructions below will explain where they should be installed.  As a result, you will need the following DLLs from `<PATH_TO_NVIGI_SDK_PACK>/bin/x64/`:
	- `nvigi.plugin.asr.ggml.d3d12.dll`
	- `nvigi.plugin.gpt.ggml.d3d12.dll`
- The NVIGI Chatterbox D3D12 TTS plugin DLL. As with the previous item, this plugin DLL is also experimental, not built via this source pack, and usable by SDK samples. You will need to copy the following DLL from `<PATH_TO_NVIGI_SDK_PACK>/bin/x64/`:
  - `nvigi.plugin.tts.chatterbox-ggml.d3d12.dll`

## Required Model Data

In order to run the 3D sample, you will need a model data tree.  Some of this model data involves licensing and thus cannot be posted to public Git servers.  The supported method of getting models is to download the pre-built NVIGI SDK package as above and run its `download_all_data.bat` script.  The models will be placed in `data/nvigi.models` in that package.  Copy that directory to `NVIGI-Plugins/data/nvigi.models` in this source tree, or make a link to it (see [below](#running-the-built-3d-sample)).

Version 1.8.0 also includes an experimental Python model downloader as an alternative.  From the `NVIGI-Plugins` directory, install its dependencies and download models with:

```bat
pip install -r scripts/download_models.requirements.txt
python scripts/download_models.py data/nvigi.models
```

See the [model downloader instructions](NVIGI-Plugins/scripts/download_models.md) for prerequisites and options.  If you encounter problems with this experimental downloader, use the binary package's `download_all_data.bat` script.

## MSVC 2022 Min Prerequisites

There is a min version of the VS2022 C++ compiler tools required to rebuild the plugins; this minimum is set by the compiler used to compile the GGML ASR and GPT third-party libraries.  Older versions of the C++ compiler will lead to link errors in the GGML plugins.  Most users who build from source will simply update VS2022 to the latest and never see any issue.

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

The scripts in this pack build the already initialized NVIGI Core and SDK Plugins submodules, including the 3D Sample.  They run setup to obtain third-party dependencies through Packman, link Plugins to Core and build the components.  Initialize the submodules as described above before running the scripts.  Most developers wanting to build source will use this as a starting point, modifying the scripts or copying parts of them into their own build process.

This public-source build workflow targets Windows x64.  In the NVIGI 1.8.0 RTX Spark Developer Preview, building the full Core libraries and plugins for ARM64 from public source remains unsupported.  Samples supplied with the binary releases can be built for either platform; see [source-build platform support](NVIGI-Plugins/docs/SourceBuild.md) for details.

### `01_build_pack_core.bat`

This script sets up and builds all configs of the NVIGI Core (thus also creating a PDK), then packages a Runtime SDK.

#### Prerequisites

This script must be run from a VS2022 Developer Command Prompt.

### `02_build_pack_plugins.bat`

This script sets up and builds the desired config of the NVIGI SDK Plugins and samples, including the 3D Sample, then copies the headers and binaries to their expected locations.  It also creates a link to the built, sibling Core directory (as a part of the setup step).

#### Prerequisites

This script must be run from a VS2022 Developer Command Prompt and can only be run after `01_build_pack_core.bat` has been run successfully.

#### Running

The script requires a single argument of `Release`, `Debug` or `Production`, e.g.

```
.\02_build_pack_plugins.bat Release
```

#### Runtime copy prerequisites

The Plugins script stops if setup, building or any copy operation fails.  It reuses `NVIGI-Plugins/nvigi_core` only when it is a junction to the sibling `NVIGI-Core` directory; an existing directory or a junction to another location must be corrected manually.

Public Packman setup does not download the DXC or Agility runtime redistributables.  Before running the Plugins script, supply the following files from the binary SDK package or the licensed runtime distributions described in [Required Binaries](#required-binaries):

- `dxcompiler.dll` and `dxil.dll` in `NVIGI-Plugins/external/dxc-redist/bin/x64/`
- `D3D12Core.dll` and `d3d12SDKLayers.dll` in `NVIGI-Plugins/external/agility-sdk-redist/build/native/bin/x64/`

The runtime-copy helper checks that all required source DLLs exist before copying any of them.  If a file is missing or a copy fails, it reports the file and returns an error; supply the missing files or resolve the copy error, then rerun the script.  These redistributables are copied into the selected configuration's output directory automatically.  The experimental plugin DLLs listed below still need to be supplied separately.

#### Required Post-build Step

After building a configuration for the first time, copy `nvigi.plugin.asr.ggml.d3d12.dll`, `nvigi.plugin.gpt.ggml.d3d12.dll` and `nvigi.plugin.tts.chatterbox-ggml.d3d12.dll` from the binary SDK package to `NVIGI-Plugins/bin/x64/<configuration>/`.  Replace `<configuration>` with `Release`, `Debug` or `Production`, matching the configuration passed to the build script.  The DXC and Agility runtime DLLs are copied automatically from the source directories specified above; Agility DLLs are placed in the `D3D12` subdirectory of the selected configuration.

Complete these copies before running the command-line samples or the 3D Sample.  The 3D Sample is already built by `02_build_pack_plugins.bat`; no separate build step is required.

### Running the Built 3D Sample

The 3D Sample searches upward from its executable directory for `data/nvigi.models`, containing the `nvigi.plugin.gpt.ggml` directory.  Place the downloaded models at `NVIGI-Plugins/data/nvigi.models` as described in [Required Model Data](#required-model-data).

If you downloaded models into the binary SDK package, you can create a junction to them instead of copying them.  From the root of this repository, run:

```bat
cd NVIGI-Plugins\data
mklink /j nvigi.models "<PATH_TO_NVIGI_SDK_PACK>\data\nvigi.models"
```

After completing the post-build DLL copies, launch `NVIGI-Plugins/bin/x64/<configuration>/nvigi.3d.exe`, where `<configuration>` matches the configuration you built.  For more sample options, see the [3D Sample documentation](NVIGI-Plugins/docs/Samples3D.md).
