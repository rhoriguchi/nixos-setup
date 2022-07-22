# nix-setup

## Switch to unstable package channel

```console
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

## Manual setup

### Laptop

- SSH Keys
- Discord
- Gitkraken
- JetBrains
  - DataGrip
  - IntelliJ IDEA Ultimate
  - PyCharm Professional
  - WebStorm
- Firefox
  - BitWarden
  - Grammarly
  - MetaMask
  - Tab Session Manager
- Nixops
- Postman
- ProtonVPN Gui
- qBittorrent
- Resilio Sync
- GPG Key
- Signal
- Spotify
- Steam
- TeamViewer

#### [Authorize OneDrive](https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#authorize-the-application-with-your-onedrive-account)

### [Encrypting home directory](https://wiki.archlinux.org/title/ECryptfs#Encrypting_a_home_directory)

Temporarily add password to root user and make sure `users.users.root.hashedPassword` is not set.

```nix
users.users.root.password = "asdf1234";
```

Log out of user and open console `CTRL` + `ALT` + `F1` and login to root user.

```console
modprobe ecryptfs
nix-shell -p ecryptfs --run "ecryptfs-migrate-home -u rhoriguchi"
```

Remove `users.users.root.password` option and delete copy of home `/home/rhoriguchi.random_characters`.

### Server

#### Setup Plex over `http://IP:32400/web`

#### Home Assistant

- Create default user
- Delete all areas
- Add integrations
  - Netatmo
  - Shelly
  - Ubiquiti UniFi
- Configure myStrom buttons
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_blue" "http://myStrom-Button-E9DACB.iot/api/v1/device/F4CFA2E9DACB"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_gray" "http://myStrom-Button-E9DA8E.iot/api/v1/device/F4CFA2E9DA8E"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_orange" "http://myStrom-Button-E9DAD9.iot/api/v1/device/F4CFA2E9DAD9"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_purple" "http://myStrom-Button-E9D761.iot/api/v1/device/F4CFA2E9D761"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_white" "http://myStrom-Button-F8CB7A.iot/api/v1/device/CC50E3F8CB7A"`

#### Google Photos Sync

Run the command the service `gphotos-sync.service` calls and authenticate the application with Google.

#### Setup ZFS

```console
zpool create \
  -o ashift=12 \
  -o autotrim=on \
  -O compression=off \
  -O mountpoint=legacy \
  data \
  raidz \
    ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E0ZLJXFX \
    ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E2PN4A53 \
    ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E5JNF5EA

zfs create \
  -o compression=zstd \
  data/backup

zfs create \
  data/sync
```

#### libvirt

##### Initial Windows setup

Uncomment in [libvirtd config](configuration/devices/headless/server/libvirtd/default.nix) the `INITIAL SETUP` block and replace `PATH_TO_ISO` with correct path.

Once Windows is installed run in an elevated cmd.

```txt
cd %userprofile%/Downloads
```

`SPICE Guest Tools` need to be installed manually.

```txt
curl --output spice-guest-tools-latest.exe --url https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe
spice-guest-tools-latest.exe
```

After `SPICE Guest Tools` is installed.

```txt
REM SPICE UsbDk
curl --output UsbDk_1.0.22_x64.msi --url https://www.spice-space.org/download/windows/usbdk/UsbDk_1.0.22_x64.msi
msiexec /i UsbDk_1.0.22_x64.msi /quiet /qn /norestart

REM SPICE WebDAV
curl --output spice-webdavd-x64-latest.msi --url https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-latest.msi
msiexec /i spice-webdavd-x64-latest.msi /quiet /qn /norestart

REM VirtIO Drivers
curl --output virtio-win-gt-x64.msi --url https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.217-2/virtio-win-gt-x64.msi
msiexec /i virtio-win-gt-x64.msi /quiet /qn /norestart

REM VirtIO FS
curl --output winfsp-1.11.22176.msi --url https://github.com/winfsp/winfsp/releases/download/v1.11/winfsp-1.11.22176.msi
msiexec /i winfsp-1.11.22176.msi /quiet /qn /norestart
sc start VirtioFsSvc
```

## Nixops

### Init

```console
nixops create
```

### Info

```console
nixops info
```

### Deploy

```console
nixops deploy
```

### Update channel

```console
nixops ssh-for-each --parallel "nix-channel --update"
```

### Delete garabge

```console
nixops ssh-for-each --parallel "nix-collect-garbage -d"
```
