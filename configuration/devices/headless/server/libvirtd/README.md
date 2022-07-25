# libvirt

## Initial Windows setup

Uncomment in [libvirtd config](configuration/devices/headless/server/libvirtd/default.nix) the `INITIAL SETUP` block and replace `PATH_TO_ISO` with correct path.

Once Windows is installed run in an elevated cmd.

```txt
cd %userprofile%/Downloads
```

`SPICE Guest Tools` need to be installed manually.

```txt
curl --output spice-guest-tools-latest.exe --url https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe
start /wait spice-guest-tools-latest.exe
```

After `SPICE Guest Tools` is installed.

```txt
REM SPICE UsbDk
curl --output UsbDk_1.0.22_x64.msi --url https://www.spice-space.org/download/windows/usbdk/UsbDk_1.0.22_x64.msi
start /wait msiexec /i UsbDk_1.0.22_x64.msi /quiet /qn /norestart

REM SPICE WebDAV
curl --output spice-webdavd-x64-latest.msi --url https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-latest.msi
start /wait msiexec /i spice-webdavd-x64-latest.msi /quiet /qn /norestart

REM VirtIO Drivers
curl --output virtio-win-gt-x64.msi --url https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.217-2/virtio-win-gt-x64.msi
start /wait msiexec /i virtio-win-gt-x64.msi /quiet /qn /norestart

REM VirtIO FS
curl --output winfsp-1.11.22176.msi --url https://github.com/winfsp/winfsp/releases/download/v1.11/winfsp-1.11.22176.msi
start /wait msiexec /i winfsp-1.11.22176.msi /quiet /qn /norestart
sc start VirtioFsSvc
```
