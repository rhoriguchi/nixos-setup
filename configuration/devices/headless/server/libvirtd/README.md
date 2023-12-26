# libvirt

## Initial Windows setup

Uncomment in [guest config](guest.nix) the `INITIAL SETUP` block.

### Install drivers and OS tweaks

Once Windows is installed run in an elevated cmd.

Some tools need to be installed manually.

```txt
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

```txt
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
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f

REM TODO replace is archived
REM Cleanup Windows with https://github.com/Sycnex/Windows10Debloater
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Debloat%20Windows' | iex"
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Disable%20Cortana' | iex"
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Protect%20Privacy' | iex"
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Remove%20Bloatware%20RegKeys' | iex"
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Stop%20Edge%20PDF' | iex"
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Uninstall%20OneDrive' | iex"
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Unpin%20Start' | iex"
```

Restart VM.

## Other Software to install

### Run in an elevated cmd

```txt
cd %userprofile%/Downloads

curl --location --output Firefox.msi --url "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
start /wait msiexec /i Firefox.msi /quiet /qn /norestart
del /f Firefox.msi

curl --location --output Hextech_Repair_tool.msi --url "https://lolstatic-a.akamaihd.net/player-support/tools/hextech-repair-tool/latest/Hextech%20Repair%20Tool.msi"
start /wait msiexec /i Hextech_Repair_tool.msi /quiet /qn /norestart
del /f Hextech_Repair_tool.msi

curl --location --output VLC.msi --url "https://get.videolan.org/vlc/3.0.20/win64/vlc-3.0.20-win64.msi"
start /wait msiexec /i VLC.msi /quiet /qn /norestart
del /f VLC.msi

curl --location --output Blitz_installer.exe --url "https://blitz.gg/download/win"
curl --location --output Discord.exe --url "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x86"
curl --location --output Driver_Booster.exe --url "https://cdn.iobit.com/dl/driver_booster_setup.exe"
curl --location --output IObit_Uninstaller.exe --url "https://cdn.iobit.com/dl/iobituninstaller.exe"
curl --location --output League_of_Legends.exe --url "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.euw.exe"
curl --location --output Minecraft_Launcher.exe --url "https://aka.ms/minecraftClientGameCoreWindows"
curl --location --output Notepad_plus_plus.exe --url "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6/npp.8.6.Installer.x64.exe"
curl --location --output Plex.exe --url "https://downloads.plex.tv/plex-desktop/1.83.1.4061-d3f45728/windows/Plex-1.83.1.4061-d3f45728-x86_64.exe"
curl --location --output Razer_Synapse_legacy.exe --url "https://rzr.to/synapse-pc-download"
curl --location --output Razer_Synapse.exe --url "https://rzr.to/synapse-3-pc-download"
curl --location --output Spotify.exe --url "https://download.scdn.co/SpotifySetup.exe"
curl --location --output Steam_installer.exe --url "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
curl --location --output TeamViewer.exe --url "https://download.teamviewer.com/download/TeamViewer_Setup_x64.exe"

start %userprofile%/Downloads
```

### Dyson Sphere Program

```txt
cd %userprofile%/Downloads

curl --location --output r2modman.zip --url "https://thunderstore.io/package/download/ebkr/r2modman/3.1.45"
mkdir r2modman
tar -xf r2modman.zip -C r2modman
del /f r2modman.zip

start %userprofile%/Downloads
```

#### Mods

- NebulaMultiplayerMod

  ```txt
  ror2mm://v1/install/thunderstore.io/nebula/NebulaMultiplayerMod/0.8.14
  ```

### From Microsoft store

- NVIDIA Control Panel

  ```txt
  ms-windows-store://pdp/?productid=9NF8H0H7WMLT&mode=mini
  ```

- WhatsApp

  ```txt
  ms-windows-store://pdp/?productid=9NKSQGP7F2NH&mode=mini
  ```

- Xbox

  ```txt
  ms-windows-store://pdp/?productid=9MV0B5HZVK9Z&mode=mini
  ```
