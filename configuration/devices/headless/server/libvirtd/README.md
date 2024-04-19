# libvirt

## Initial Windows setup

Uncomment in [guest config](guest.nix) the `INITIAL SETUP` block.

### Install drivers and OS tweaks

Once Windows is installed run in an elevated cmd.

Some tools need to be installed manually.

```cmd
cd %userprofile%/Downloads

REM SPICE Guest Tools
curl --location --output spice-guest-tools.exe --url "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe"
start /wait spice-guest-tools.exe
del /f spice-guest-tools.exe

REM Nvidia GeForce Experience
curl --location --output GeForce_Experience.exe --url "https://de.download.nvidia.com/GFE/GFEClient/3.27.0.120/GeForce_Experience_v3.27.0.120.exe"
start /wait GeForce_Experience.exe
del /f GeForce_Experience.exe
```

After the manual installation.

```cmd
cd %userprofile%/Downloads

REM SPICE UsbDk
curl --location --output UsbDk.msi --url "https://www.spice-space.org/download/windows/usbdk/UsbDk_1.0.22_x64.msi"
start /wait msiexec /i UsbDk.msi /quiet /qn /norestart
del /f UsbDk.msi

REM VirtIO Drivers
curl --location --output virtio-win-gt.msi --url "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.240-1/virtio-win-gt-x64.msi"
start /wait msiexec /i virtio-win-gt.msi /quiet /qn /norestart
del /f virtio-win-gt.msi

REM VirtIO FS
curl --location --output winfsp.msi --url "https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi"
start /wait msiexec /i winfsp.msi /quiet /qn /norestart
del /f winfsp.msi
sc config VirtioFsSvc start=auto

REM Power tuning
powercfg -hibernate off
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -change -monitor-timeout-ac 15

REM Windows Explorer tuning
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f

REM Mouse acceleration
reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
```

Restart VM.

### Mount Steam folder

```cmd
mkdir -p "C:\Program Files (x86)\Steam\steamapps"
```

Open `Disk Management`, right click drive and select `Change Drive Letter and Paths...` and add the newly created path.

## Other Software to install

Run in an elevated cmd

```cmd
cd %userprofile%/Downloads

curl --location --output Hextech_Repair_tool.msi --url "https://lolstatic-a.akamaihd.net/player-support/tools/hextech-repair-tool/latest/Hextech%20Repair%20Tool.msi"
start /wait msiexec /i Hextech_Repair_tool.msi /quiet /qn /norestart
del /f Hextech_Repair_tool.msi

winget install --silent --accept-source-agreements ^
  Blitz.Blitz ^
  Discord.Discord ^
  IObit.DriverBooster ^
  IObit.Uninstaller ^
  Mojang.MinecraftLauncher ^
  Mozilla.Firefox ^
  Notepad++.Notepad++ ^
  OpenWhisperSystems.Signal ^
  RazerInc.RazerInstaller ^
  RiotGames.LeagueOfLegends.EUW ^
  SomePythonThings.WingetUIStore ^
  TeamViewer.TeamViewer ^
  Valve.Steam ^
  VideoLAN.VLC
```

### Manual

```cmd
cd %userprofile%/Downloads

curl --location --output Cheat_Engine.exe --url "https://d1vdn3r1396bak.cloudfront.net/installer/726575248502658/7285449"
curl --location --output Razer_Synapse_legacy.exe --url "https://rzr.to/synapse-pc-download"

start %userprofile%/Downloads
```

### Microsoft store

Run in an elevated cmd

```cmd
REM NVIDIA Control Panel
winget install --silent --accept-source-agreements 9NF8H0H7WMLT

REM WhatsApp
winget install --silent --accept-source-agreements 9NKSQGP7F2NH

REM Xbox
winget install --silent --accept-source-agreements 9MV0B5HZVK9Z
```

### Dyson Sphere Program

```cmd
cd %userprofile%/Downloads

curl --location --output r2modman.zip --url "https://thunderstore.io/package/download/ebkr/r2modman/3.1.48"
mkdir r2modman
tar -xf r2modman.zip -C r2modman
del /f r2modman.zip

start %userprofile%/Downloads
```

#### Dyson Sphere Program mods

- CommonAPI

  ```txt
  ror2mm://v1/install/thunderstore.io/CommonAPI/CommonAPI/1.6.5
  ```

- FactoryLocator

  ```txt
  ror2mm://v1/install/thunderstore.io/starfi5h/FactoryLocator/1.2.3/
  ```

- GalacticScale

  ```txt
  ror2mm://v1/install/thunderstore.io/Galactic_Scale/GalacticScale/2.13.4
  ```

- NebulaCompatibilityAssist

  ```txt
  ror2mm://v1/install/thunderstore.io/starfi5h/NebulaCompatibilityAssist/0.4.1
  ```

- NebulaMultiplayerMod

  ```txt
  ror2mm://v1/install/thunderstore.io/nebula/NebulaMultiplayerMod/0.9.2
  ```

- SmartEjectors

  ```txt
  ror2mm://v1/install/thunderstore.io/DanielHeEGG/SmartEjectors/1.3.3
  ```

- SphereEditorTools

  ```txt
  ror2mm://v1/install/thunderstore.io/starfi5h/SphereEditorTools/2.2.3
  ```
