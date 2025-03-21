# Windows Laptop setup

## TODO

- Use device mac for iot wifi
- Use <https://github.com/ChrisTitusTech/winutil> for `OS Tweaks`
- CheatEngine download link seems to fail in cmd
- Autostart
  - Disable
    - riot
    - steam
    - teamviewer
    - discord
- Netdata
  - Windows exporter not showing
  - Figure out windows firewall
- iot -> server
  - 80, 443
  - Minecraft

## OS Tweaks

Run in an elevated cmd

```cmd
wmic computersystem where name="%COMPUTERNAME%" call rename name="XXLPitu-Nnoitra"

REM Power tuning
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Windows Explorer tuning
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f

REM Mouse acceleration
reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
```

## Manual software

Run in an elevated cmd

```cmd
cd %userprofile%/Downloads

curl --location --output NVIDIA_app.exe --url "https://us.download.nvidia.com/nvapp/client/11.0.1.189/NVIDIA_app_v11.0.1.189.exe"
curl --location --output Razer_Synapse_legacy.exe --url "https://rzr.to/synapse-pc-download"

start %userprofile%/Downloads
```

## Software

Run in an elevated cmd

```cmd
REM Xbox
winget install --accept-source-agreements --exact --silent --uninstall-previous 9MV0B5HZVK9Z

REM NVIDIA Control Panel
winget install --accept-source-agreements --exact --silent --uninstall-previous 9NF8H0H7WMLT

REM WhatsApp
winget install --accept-source-agreements --exact --silent --uninstall-previous 9NKSQGP7F2NH

winget install --accept-source-agreements --exact --silent --uninstall-previous Blitz.Blitz
winget install --accept-source-agreements --exact --silent --uninstall-previous Discord.Discord
winget install --accept-source-agreements --exact --silent --uninstall-previous GlennDelahoy.SnappyDriverInstallerOrigin
winget install --accept-source-agreements --exact --silent --uninstall-previous IObit.Uninstaller
winget install --accept-source-agreements --exact --silent --uninstall-previous MartiCliment.UniGetUI
winget install --accept-source-agreements --exact --silent --uninstall-previous Mojang.MinecraftLauncher
winget install --accept-source-agreements --exact --silent --uninstall-previous Mozilla.Firefox
winget install --accept-source-agreements --exact --silent --uninstall-previous Notepad++.Notepad++
winget install --accept-source-agreements --exact --silent --uninstall-previous OpenWhisperSystems.Signal
winget install --accept-source-agreements --exact --silent --uninstall-previous RazerInc.RazerInstaller
winget install --accept-source-agreements --exact --silent --uninstall-previous RiotGames.LeagueOfLegends.EUW
winget install --accept-source-agreements --exact --silent --uninstall-previous Spotify.Spotify
winget install --accept-source-agreements --exact --silent --uninstall-previous TeamViewer.TeamViewer
winget install --accept-source-agreements --exact --silent --uninstall-previous Valve.Steam
winget install --accept-source-agreements --exact --silent --uninstall-previous VideoLAN.VLC
winget install --accept-source-agreements --exact --silent --uninstall-previous WeMod.WeMod
winget install --accept-source-agreements --exact --silent --uninstall-previous WinDirStat.WinDirStat
```

### Netdata

Run in an elevated cmd

```cmd
cd %userprofile%/Downloads

REM Netdata Windows exporter
curl --location --output windows_exporter.msi --url "https://github.com/prometheus-community/windows_exporter/releases/download/v0.30.5/windows_exporter-0.30.5-amd64.msi"
start /wait msiexec /i windows_exporter.msi ADDLOCAL=FirewallException /quiet /qn /norestart
del /f windows_exporter.msi

netsh advfirewall firewall add rule name="Custom_allow_192.168.10.2_to_9182" protocol=TCP dir=in localport=9182 action=allow remoteip=192.168.10.2
netsh advfirewall firewall add rule name="Custom_lock_all_to_9182" protocol=TCP dir=in localport=9182 action=block remoteip=any
```

## Games

### Nexus mods

```cmd
winget install --accept-source-agreements --exact --silent --uninstall-previous NexusMods.Vortex
``

#### Cyberpunk 20777

- [Reset Attributes always available - Redscript](https://www.nexusmods.com/cyberpunk2077/mods/9240)

### R2ModMan

```cmd
winget install --accept-source-agreements --exact --silent --uninstall-previous ebkr.r2modman
```

#### Dyson Sphere Program

- CommonAPI

  ```txt
  ror2mm://v1/install/thunderstore.io/CommonAPI/CommonAPI/1.6.5
  ```

- FactoryLocator

  ```txt
  ror2mm://v1/install/thunderstore.io/starfi5h/FactoryLocator/1.3.8
  ```

- GalacticScale

  ```txt
  ror2mm://v1/install/thunderstore.io/Galactic_Scale/GalacticScale/2.16.6
  ```

- NebulaCompatibilityAssist

  ```txt
  ror2mm://v1/install/thunderstore.io/starfi5h/NebulaCompatibilityAssist/0.4.23
  ```

- NebulaMultiplayerMod

  ```txt
  ror2mm://v1/install/thunderstore.io/nebula/NebulaMultiplayerMod/0.9.12
  ```

- SmartEjectors

  ```txt
  ror2mm://v1/install/thunderstore.io/DanielHeEGG/SmartEjectors/1.3.3
  ```

- SphereEditorTools

  ```txt
  ror2mm://v1/install/thunderstore.io/starfi5h/SphereEditorTools/2.2.3
  ```
