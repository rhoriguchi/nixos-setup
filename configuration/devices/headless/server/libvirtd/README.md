# libvirt

## Initial Windows setup

Uncomment in [libvirtd config](default.nix) the `INITIAL SETUP` block and replace `PATH_TO_ISO` with correct path.

- Windows 10: <https://www.microsoft.com/software-download/windows10>
- Windows 11: <https://www.microsoft.com/software-download/windows11>

### Install drivers

Once Windows is installed run in an elevated cmd.

Some tools need to be installed manually.

```txt
cd %userprofile%/Downloads

REM SPICE Guest Tools
curl --location --output spice-guest-tools.exe --url "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe"
start /wait spice-guest-tools.exe
del /f spice-guest-tools.exe

REM Nvidia GeForce Experience
curl --location --output GeForce_Experience.exe --url "https://us.download.nvidia.com/GFE/GFEClient/3.25.1.27/GeForce_Experience_v3.25.1.27.exe"
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

REM SPICE WebDAV
curl --location --output spice-webdavd.msi --url "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-latest.msi"
start /wait msiexec /i spice-webdavd.msi /quiet /qn /norestart
del /f spice-webdavd.msi

REM VirtIO Drivers
curl --location --output virtio-win-gt.msi --url "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.217-2/virtio-win-gt-x64.msi"
start /wait msiexec /i virtio-win-gt.msi /quiet /qn /norestart
del /f virtio-win-gt.msi

REM VirtIO FS
curl --location --output winfsp.msi --url "https://github.com/winfsp/winfsp/releases/download/v1.11/winfsp-1.11.22176.msi"
start /wait msiexec /i winfsp.msi /quiet /qn /norestart
del /f winfsp.msi
sc start VirtioFsSvc

REM Power tuning
powercfg /hibernate off
powercfg -h off
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Cleanup Windows with https://github.com/Sycnex/Windows10Debloater
powershell -command "iwr -useb 'https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Individual%20Scripts/Debloat%20Windows' | iex"
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

Run in an elevated cmd.

```txt
cd %userprofile%/Downloads

curl --location --output Firefox.msi --url "hhttps://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
start /wait msiexec /i Firefox.msi /quiet /qn /norestart
del /f Firefox.msi

curl --location --output Discord.exe --url "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x86"
curl --location --output Driver_Booster.exe --url "https://cdn.iobit.com/dl/driver_booster_setup.exe"
curl --location --output League_of_Legends.exe --url "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.euw.exe"
curl --location --output Razer_Synapse_legacy.exe --url "https://rzr.to/synapse-pc-download"
curl --location --output Steam.exe --url "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"

start %userprofile%/Downloads
```
