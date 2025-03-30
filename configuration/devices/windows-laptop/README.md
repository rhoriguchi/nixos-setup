# Windows Laptop setup

## [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil)

Run in an elevated PowerShell

```powershell
irm "https://christitus.com/win" | iex
```

Import [iex.json](iex.json)

- `Tweaks` -> `Run Tweaks`
- `Config` -> `Install Features`

## OS Tweaks

Run in an elevated cmd

```cmd
wmic computersystem where name="%COMPUTERNAME%" call rename name="XXLPitu-Nnoitra"

REM Set timezone
tzutil /s "W. Europe Standard Time"

REM Power tuning
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Windows Explorer tuning
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKEY_CURRENT_USER\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f

REM Windows Taskbar
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f
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
REM NVIDIA Control Panel
winget install --accept-source-agreements --exact --silent --uninstall-previous 9NF8H0H7WMLT

REM Snipping Tool
winget install --accept-source-agreements --exact --silent --uninstall-previous 9MZ95KL8MR0L

REM WhatsApp
winget install --accept-source-agreements --exact --silent --uninstall-previous 9NKSQGP7F2NH

REM Xbox
winget install --accept-source-agreements --exact --silent --uninstall-previous 9MV0B5HZVK9Z

winget install --accept-source-agreements --exact --silent --uninstall-previous Blitz.Blitz
winget install --accept-source-agreements --exact --silent --uninstall-previous Discord.Discord
winget install --accept-source-agreements --exact --silent --uninstall-previous IObit.DriverBooster
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

- Replace `CLAIM_TOKEN` with value form [secrets.nix](../../../secrets.nix).monitoring.claimToken

```cmd
set TMPDIR="%TEMP%\tempdir_%RANDOM%"
mkdir %TMPDIR%
cd /d %TMPDIR%

curl --location --output Netdata.msi --url "https://github.com/netdata/netdata/releases/download/v2.3.0/netdata-x64.msi"
start /wait msiexec /quiet /qn /norestart /i Netdata.msi TOKEN="CLAIM_TOKEN" ROOMS="2c7b66ac-c84e-4909-9efe-9f1de72d765a"

del /f Netdata.msi
```

## Samba share

Manually enter password found in [secrets.nix](../../../secrets.nix).samba.users.password and save credentials

```cmd
net use X: \\XXLPitu-Server.local\Series /user:samba /persistent:yes
```

## Cleanup autostart

Run in an elevated cmd

```cmd
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Discord" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "org.whispersystems.signal-desktop" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "RiotClient" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Spotify" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Steam" /f
sc config TeamViewer start= disabled
```

## Games

### Nexus mods

```cmd
winget install --accept-source-agreements --exact --silent --uninstall-previous NexusMods.Vortex
```

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
