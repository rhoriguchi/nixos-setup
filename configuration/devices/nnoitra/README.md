# Nnoitra setup

## [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil)

Run in an elevated PowerShell

```powershell
irm "https://christitus.com/win" | iex
```

Import [iex_26.07.17.json](iex_26.07.17.json)

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
powercfg -change -monitor-timeout-ac 15
powercfg -change -monitor-timeout-dc 5

REM Disable MAC randomization
netsh wlan set profileparameter name="63466727-IoT" Randomization=no
```

## Manual software

Run in an elevated cmd

```cmd
cd %userprofile%/Downloads

curl --location --output NVIDIA_app.exe --url "https://us.download.nvidia.com/nvapp/client/11.0.8.299/NVIDIA_app_v11.0.8.299.exe"

start %userprofile%/Downloads
```

## Update drivers - Snappy Driver Installer

```cmd
cd %userprofile%/Downloads

curl --location --output SDI.7z --url "https://driveroff.net/sdi/SDI_R2601.7z"

start %userprofile%/Downloads
```

## Software

Run in an elevated cmd

```cmd
REM NVIDIA Control Panel
winget install --accept-source-agreements --exact --silent --uninstall-previous 9NF8H0H7WMLT

REM Snipping Tool
winget install --accept-source-agreements --exact --silent --uninstall-previous 9MZ95KL8MR0L

REM Xbox
winget install --accept-source-agreements --exact --silent --uninstall-previous 9MV0B5HZVK9Z

winget install --accept-source-agreements --exact --silent --uninstall-previous AppWork.JDownloader
winget install --accept-source-agreements --exact --silent --uninstall-previous Blitz.Blitz
winget install --accept-source-agreements --exact --silent --uninstall-previous CPUID.HWMonitor
winget install --accept-source-agreements --exact --silent --uninstall-previous Devolutions.UniGetUI
winget install --accept-source-agreements --exact --silent --uninstall-previous Discord.Discord
winget install --accept-source-agreements --exact --silent --uninstall-previous IObit.Uninstaller
winget install --accept-source-agreements --exact --silent --uninstall-previous LocalSend.LocalSend
winget install --accept-source-agreements --exact --silent --uninstall-previous Mojang.MinecraftLauncher
winget install --accept-source-agreements --exact --silent --uninstall-previous Mozilla.Firefox
winget install --accept-source-agreements --exact --silent --uninstall-previous Notepad++.Notepad++
winget install --accept-source-agreements --exact --silent --uninstall-previous RazerInc.RazerInstaller.Synapse4
winget install --accept-source-agreements --exact --silent --uninstall-previous RiotGames.LeagueOfLegends.EUW
winget install --accept-source-agreements --exact --silent --uninstall-previous Tailscale.Tailscale
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

curl --location --output Netdata.msi --url "https://github.com/netdata/netdata/releases/download/v2.9.0/netdata-x64.msi"
start /wait msiexec /quiet /qn /norestart /i Netdata.msi TOKEN="CLAIM_TOKEN" ROOMS="2c7b66ac-c84e-4909-9efe-9f1de72d765a"

del /f Netdata.msi
```

## Tailscale

Run in an elevated cmd

- Replace `PRE_AUTH_KEY` with value form [secrets.nix](../../../secrets.nix).headscale.preAuthKeys.XXLPitu-Nnoitra

```cmd
tailscale login --login-server=https://headscale.00a.ch --auth-key "PRE_AUTH_KEY"

tailscale set --accept-dns=false
tailscale set --accept-routes=false
tailscale set --update-check=false
```

## RustDesk

```cmd
set TMPDIR="%TEMP%\tempdir_%RANDOM%"
mkdir %TMPDIR%
cd /d %TMPDIR%

curl --location --output RustDesk.msi --url "https://github.com/rustdesk/rustdesk/releases/download/1.4.9/rustdesk-1.4.9-x86_64.msi"
start /wait msiexec /quiet /qn /norestart /i RustDesk.msi

del /f RustDesk.msi

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "RustDesk" /t REG_SZ /d "C:\Program Files\RustDesk\rustdesk.exe" /f
"C:\Program Files\RustDesk\rustdesk.exe" --install-service /f
```

## Autostart

Run in an elevated cmd

```cmd
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "com.blitz.app" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Discord" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "org.whispersystems.signal-desktop" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "RiotClient" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Steam" /f

sc config TeamViewer start= disabled
sc config Tailscale start= auto

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "LocalSend" /t REG_SZ /d " C:\Users\ryanh\AppData\Local\Programs\LocalSend\localsend_app.exe --hidden" /f
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
